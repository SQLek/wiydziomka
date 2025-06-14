package main

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"slices"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
)

var validRoles = []string{"user", "assistant", "system", "tool"}

func handleMessage(app core.App, chatId string, collection *core.Collection, isThinking bool) *core.Record {
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
		return nil
	}

	// Check if messages are empty
	if len(messages) == 0 {
		return nil
	}

	var messageContent []map[string]string

	for _, message := range messages {
		role := message.GetString("role")
		if !slices.Contains(validRoles, role) {
			// Skip messages with invalid roles
			// for example 'error'
			continue
		}
		messageContent = append(messageContent, map[string]string{
			"role":    message.GetString("role"),
			"content": message.GetString("text"),
		})
	}

	// check if there is only one message with role "system"
	if len(messageContent) == 1 && messageContent[0]["role"] == "system" {
		return nil
	}

	// Create and configure the HTTP request
	chatRecord, err := app.FindRecordById("chats", chatId)
	if err != nil {
		app.Logger().Error("Error finding chat", "error", err)
	}

	// Expand manually
	expandErrors := app.ExpandRecord(chatRecord, []string{"chats",
		"preferredModel", "preferredModel.provider",
		"thinkingModel", "thinkingModel.provider",
	}, nil)
	if len(expandErrors) > 0 {
		app.Logger().Error("Error expanding chat record:", "error", expandErrors)
	}

	model := chatRecord.ExpandedOne("thinkingModel")
	if notThinking := chatRecord.ExpandedOne("preferredModel"); notThinking != nil && !isThinking {
		// if not thinking model is set, and user does not want to think, use it
		// otherwise use thinking model
		model = notThinking
	}
	provider := model.ExpandedOne("provider")
	baseUrl := provider.GetString("baseUrl")
	// Prepare the request body according to OpenAI API format
	requestBody := map[string]any{
		"model":    model.GetString("ident"),
		"stream":   false,
		"messages": messageContent,
	}

	// Marshal the request body to JSON
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		app.Logger().Error("Error creating JSON request", "error", err)
		return nil
	}

	fullUrl := baseUrl + "/chat/completions"

	req, err := http.NewRequest("POST", fullUrl, bytes.NewBuffer(jsonData))

	if err != nil {
		app.Logger().Error("Error creating HTTP request", "error", err)
		return nil
	}

	providerKey := provider.GetString("apiKey")

	// Add required headers for OpenAI API compatibility
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+providerKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		app.Logger().Error("Error making HTTP request", "error", err)
		return nil
	}
	if c := resp.StatusCode; c < 200 || c >= 300 {
		body, _ := io.ReadAll(resp.Body)
		app.Logger().Error("Error making HTTP request", "status code", c, "body", body)
		return nil
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
		return nil
	}

	// Check for API error response
	if openAIResponse.Error.Message != "" {
		app.Logger().Error("API error", "error", openAIResponse.Error.Message)
		return nil
	}

	// Check if we have any choices
	if len(openAIResponse.Choices) == 0 {
		app.Logger().Error("No response from AI")
		return nil
	}

	record := core.NewRecord(collection)
	record.Set("chat", chatId)
	record.Set("role", "assistant")
	record.Set("text", openAIResponse.Choices[0].Message.Content)

	return record
}

func generateMessage(app core.App, chatId string, isThinking bool) {

	//create new record
	collection, err := app.FindCollectionByNameOrId("messages")
	if err != nil {
		app.Logger().Error("Error finding collection", "error", err)
		return
	}
	record := handleMessage(app, chatId, collection, isThinking)

	if record == nil {
		record = core.NewRecord(collection)
		record.Set("chat", chatId)
		record.Set("role", "error")
		record.Set("text", "I'm sorry, I'm having trouble generating a message. Please try again later.")
	}

	err = app.Save(record)
	if err != nil {
		app.Logger().Error("Error saving record", "error", err)
	}
}
