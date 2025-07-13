package openai

import (
	"context"

	"github.com/SQLek/wiydziomka/pkg/llm"
)

type Service struct {
	baseUrl string
	apiKey  string
}

func NewService(baseUrl, apiKey string) *Service {
	return &Service{
		baseUrl: baseUrl,
		apiKey:  apiKey,
	}
}

func (s *Service) ListModels(ctx context.Context) ([]llm.Model, error) {
	// This function would typically make an API call to OpenAI to list available models.
	// For now, we return an empty slice and nil error for demonstration purposes.
	return []llm.Model{}, nil
}
