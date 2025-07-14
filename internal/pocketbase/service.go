package pocketbase

import (
	"context"

	"github.com/SQLek/wiydziomka/pkg/llm"
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
)

func ListModels(ctx context.Context, app core.App, providerId string) ([]llm.Model, error) {
	// Find all models that belong to the specified provider
	records, err := app.FindRecordsByFilter(
		"models",
		"provider = {:providerId}",
		"created",
		100,
		0,
		dbx.Params{
			"providerId": providerId,
		},
	)

	if err != nil {
		return nil, err
	}

	// Convert records to llm.Model structs
	var models []llm.Model
	for _, record := range records {
		model := llm.Model{
			ID:         record.GetString("id"),
			Name:       record.GetString("name"),
			ExternalId: record.GetString("ident"),
			ProviderId: record.GetString("provider"),
		}
		models = append(models, model)
	}

	return models, nil
}
