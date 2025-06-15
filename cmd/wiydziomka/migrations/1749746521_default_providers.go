package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	// Supported providers slice
	defaults := []struct {
		Name    string
		BaseUrl string
		IsLocal bool
	}{
		{"OpenAI", "https://api.openai.com/v1", false},
		{"Groq", "https://api.groq.com/openai/v1", false},
		{"Open Router", "https://openrouter.ai/api/v1", false},
		{"Ollama", "http://localhost:11435/v1", true},
		{"LM Studio", "http://localhost:1234/v1", true},
	}

	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("providers")
		if err != nil {
			return err
		}

		for _, d := range defaults {
			rec := core.NewRecord(collection)
			rec.Set("name", d.Name)
			rec.Set("baseUrl", d.BaseUrl)
			rec.Set("isLocal", d.IsLocal)
			if err := app.Save(rec); err != nil {
				return err
			}
		}

		return nil
	}, func(app core.App) error {
		for _, provider := range defaults {
			// we only remove providers that were added by this migration
			record, err := app.FindFirstRecordByFilter(
				"providers",
				"name = {:name} || name = {:baseUrl}",
				map[string]interface{}{
					"name":    provider.Name,
					"baseUrl": provider.BaseUrl,
				},
			)
			if err != nil {
				return err
			}

			if err := app.Delete(record); err != nil {
				return err
			}
		}
		return nil
	})
}
