package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/openai/openai-go"
	"github.com/openai/openai-go/option"
)

type AvailableModel struct {
	Identifier   string
	Name         string `json:"name"`
	Architecture struct {
		Modality         string   `json:"modality"`
		InputModalities  []string `json:"input_modalities"`
		OutputModalities []string `json:"output_modalities"`
	}
}

func getAvailableModels(providerKey string, baseURL string) ([]openai.Model, error) {

	opts := []option.RequestOption{option.WithAPIKey(providerKey)}
	if baseURL != "" {
		opts = append(opts, option.WithBaseURL(baseURL))
	}

	client := openai.NewClient(opts...)
	ctx := context.Background()
	resp, err := client.Models.List(ctx, opts...)
	if err != nil {
		return nil, err
	}

	return resp.Data, nil
}

func openrouterModels(models []openai.Model, providerKey string, baseURL string) []AvailableModel {
	models, err := getAvailableModels(providerKey, baseURL)
	if err != nil {
		return nil
	}

	var AvailableModels []AvailableModel

	for _, model := range models {
		var modelData AvailableModel
		architectureBytes := []byte(model.JSON.ExtraFields["architecture"].Raw())

		modelData.Name = model.JSON.ExtraFields["name"].Raw()
		modelData.Identifier = model.ID

		err = json.Unmarshal(architectureBytes, &modelData.Architecture)
		if err != nil {
			log.Fatal(err)
		}
		AvailableModels = append(AvailableModels, modelData)

	}

	return AvailableModels
}
