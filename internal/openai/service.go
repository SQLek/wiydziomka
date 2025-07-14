package openai

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/SQLek/wiydziomka/pkg/llm"
)

type Service struct {
	baseUrl  string
	apiKey   string
	provider string
}

func NewService(baseUrl, apiKey, provider string) *Service {
	return &Service{
		baseUrl:  baseUrl,
		apiKey:   apiKey,
		provider: provider,
	}
}

func (s *Service) ListModels(ctx context.Context) ([]llm.Model, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", s.baseUrl+"/models", nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+s.apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	var models []llm.Model

	switch s.provider {
	case "OpenAI":
		// OpenAI response structure
		var openAIResp struct {
			Data []llm.OpenAIModel `json:"data"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&openAIResp); err != nil {
			return nil, fmt.Errorf("failed to decode OpenAI response: %w", err)
		}

		for _, m := range openAIResp.Data {
			model := llm.Model{
				Name:       m.ID, // OpenAI doesn't provide a separate name, so use ID
				ExternalId: m.ID,
				ProviderId: s.provider,
			}
			models = append(models, model)
		}

	case "Groq":
		// Groq response structure
		var groqResp struct {
			Data []llm.GroqModel `json:"data"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&groqResp); err != nil {
			return nil, fmt.Errorf("failed to decode Groq response: %w", err)
		}

		for _, m := range groqResp.Data {
			model := llm.Model{
				Name:       m.ID, // Groq uses ID as name
				ExternalId: m.ID,
				ProviderId: s.provider,
			}
			models = append(models, model)
		}

	case "Open Router":
		// Open Router response structure
		var openRouterResp struct {
			Data []llm.OpenRouterModel `json:"data"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&openRouterResp); err != nil {
			return nil, fmt.Errorf("failed to decode Open Router response: %w", err)
		}

		for _, m := range openRouterResp.Data {
			model := llm.Model{
				Name:       m.Name,
				ExternalId: m.ID,
				ProviderId: s.provider,
			}
			models = append(models, model)
		}

	case "Ollama":
		// Ollama response structure
		var ollamaResp struct {
			Models []llm.OllamaModel `json:"models"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&ollamaResp); err != nil {
			return nil, fmt.Errorf("failed to decode Ollama response: %w", err)
		}

		for _, m := range ollamaResp.Models {
			model := llm.Model{
				Name:       m.ID, // Ollama uses ID as name
				ExternalId: m.ID,
				ProviderId: s.provider,
			}
			models = append(models, model)
		}

	case "LM Studio":
		// LM Studio response structure (similar to OpenAI)
		var lmStudioResp struct {
			Data []struct {
				ID      string `json:"id"`
				Object  string `json:"object"`
				Created int64  `json:"created"`
				OwnedBy string `json:"owned_by"`
			} `json:"data"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&lmStudioResp); err != nil {
			return nil, fmt.Errorf("failed to decode LM Studio response: %w", err)
		}

		for _, m := range lmStudioResp.Data {
			model := llm.Model{
				Name:       m.ID, // LM Studio uses ID as name
				ExternalId: m.ID,
				ProviderId: s.provider,
			}
			models = append(models, model)
		}

	default:
		return nil, fmt.Errorf("unsupported provider: %s", s.provider)
	}

	return models, nil
}
