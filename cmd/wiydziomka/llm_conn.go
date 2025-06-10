package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
)

func handleMessage(app core.App, chatId string) {
	chat, err := app.FindRecordById("chats", chatId)
	if err != nil {
		fmt.Printf("Error finding chat: %v\n", err)
		return
	}

	messages, err := app.FindRecordsByFilter(
		"messages",
		"chat = {:chatId}",
		"-created",
		100,
		0,
		dbx.Params{
			"chatId": chatId,
		},
		dbx.Params{
			"persona": "persona",
		},
		dbx.Params{
			"useWith": "useWith",
		},
		dbx.Params{
			"provider": "provider",
		},
	)

	if err != nil {
		fmt.Printf("Error finding chat: %v\n", err)
		return
	}

	var messageContent []map[string]string

	for _, message := range messages {
		messageContent = append(messageContent, map[string]string{
			"role":    message.GetString("role"),
			"content": message.GetString("content"),
		})
	}
	fmt.Printf("chat: %v\n", chat)
	// Create and configure the HTTP request

	persona := chat.ExpandedOne("persona")
	fmt.Printf("persona: %v\n", persona)
	models := persona.ExpandedAll("useWith")
	// TODO search isPreferred = true
	// TODO if not found, search isDefault = true
	model := models[0]
	provider := model.ExpandedOne("provider")
	baseUrl := provider.GetString("baseUrl")

	// Prepare the request body according to OpenAI API format
	requestBody := map[string]interface{}{
		"model":  model.GetString("ident"),
		"stream": false,
	}

	// Marshal the request body to JSON
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		fmt.Printf("Error creating JSON request: %v\n", err)
		return
	}

	req, err := http.NewRequest("POST", baseUrl, bytes.NewBuffer(jsonData))

	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
		return
	}

	providerKey := provider.GetString("apiKey")
	// Add required headers for OpenAI API compatibility
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+providerKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Error making request: %v\n", err)
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
		fmt.Printf("Error decoding response: %v\n", err)
		return
	}

	// Check for API error response
	if openAIResponse.Error.Message != "" {
		fmt.Printf("API error: %s\n", openAIResponse.Error.Message)
		return
	}

	// Check if we have any choices
	if len(openAIResponse.Choices) == 0 {
		fmt.Printf("No response from AI\n")
		return
	}

	//create new record
	collection, err := app.FindCollectionByNameOrId("messages")
	if err != nil {
		fmt.Printf("Error finding collection: %v\n", err)
		return
	}

	record := core.NewRecord(collection)
	record.Set("chat", chatId)
	record.Set("role", "assistant")
	record.Set("content", openAIResponse.Choices[0].Message.Content)

	err = app.Save(record)
	if err != nil {
		fmt.Printf("Error saving record: %v\n", err)
		return
	}
}
