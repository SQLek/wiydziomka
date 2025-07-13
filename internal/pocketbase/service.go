package pocketbase

import (
	"context"

	"github.com/SQLek/wiydziomka/pkg/llm"
)

func ListModels(ctx context.Context, providerId string) ([]llm.Model, error) {
	// This function would typically make an API call to PocketBase to list available models.
	// For now, we return an empty slice and nil error for demonstration purposes.
	return []llm.Model{}, nil
}
