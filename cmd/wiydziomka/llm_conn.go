package main

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
)

func handleMessage(app core.App, chatId string) {
	messages, err := app.FindRecordsByFilter(
		"messages",
		"chat = {:chatId}",
		"created",
		100,
		0,
		dbx.Params{
			"chatId": chatId,
		},
	)

	if err != nil {
		app.Logger().Error("Error finding chat", "error", err)
		return
	}

	// Check if messages are empty
	if len(messages) == 0 {
		return
	}

	var messageContent []map[string]string

	for _, message := range messages {
		messageContent = append(messageContent, map[string]string{
			"role":    message.GetString("role"),
			"content": message.GetString("text"),
		})
	}

	// check if there is only one message with role "system"
	if len(messageContent) == 1 && messageContent[0]["role"] == "system" {
		return
	}

	// Create and configure the HTTP request
	chatRecord, err := app.FindRecordById("chats", chatId)
	if err != nil {
		app.Logger().Error("Error finding chat", "error", err)
	}

	// Expand manually
	expandErrors := app.ExpandRecord(chatRecord, []string{"persona", "persona.useWith", "persona.useWith.provider"}, nil)
	if len(expandErrors) > 0 {
		app.Logger().Error("Error expanding chat record:", "error", expandErrors)
		log.Fatal(expandErrors)
	}

	persona := chatRecord.ExpandedOne("persona")
	models := persona.ExpandedAll("useWith")
	// TODO search isPreferred = true
	// TODO if not found, search isDefault = true
	model := models[0]
	provider := model.ExpandedOne("provider")
	baseUrl := provider.GetString("baseUrl")
	// Prepare the request body according to OpenAI API format
	requestBody := map[string]interface{}{
		"model":    model.GetString("ident"),
		"stream":   false,
		"messages": messageContent,
	}

	// Marshal the request body to JSON
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		app.Logger().Error("Error creating JSON request", "error", err)
		return
	}

	fullUrl := baseUrl + "/chat/completions"

	req, err := http.NewRequest("POST", fullUrl, bytes.NewBuffer(jsonData))

	if err != nil {
		app.Logger().Error("Error creating HTTP request", "error", err)
		return
	}

	providerKey := provider.GetString("apiKey")

	// Add required headers for OpenAI API compatibility
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+providerKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		app.Logger().Error("Error making HTTP request", "error", err)
		return
	}
	defer resp.Body.Close()

	// Define OpenAI response structure
	var openAIResponse struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
		Error struct {
			Message string `json:"message"`
		} `json:"error"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&openAIResponse); err != nil {
		app.Logger().Error("Error decoding response", "error", err)
		return
	}

	// Check for API error response
	if openAIResponse.Error.Message != "" {
		app.Logger().Error("API error", "error", openAIResponse.Error.Message)
		return
	}

	// Check if we have any choices
	if len(openAIResponse.Choices) == 0 {
		app.Logger().Error("No response from AI")
		return
	}

	//create new record
	collection, err := app.FindCollectionByNameOrId("messages")
	if err != nil {
		app.Logger().Error("Error finding collection", "error", err)
		return
	}

	record := core.NewRecord(collection)
	record.Set("chat", chatId)
	record.Set("role", "assistant")
	record.Set("text", openAIResponse.Choices[0].Message.Content)

	err = app.Save(record)
	if err != nil {
		app.Logger().Error("Error saving record", "error", err)
		return
	}
}
