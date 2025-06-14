package migrations

import (
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	// Supported models slice
	defaults := []struct {
		Name       string
		Ident      string
		Provider   string
		IsThinking bool
	}{
		{"gpt-4.1", "gpt-4.1", "OpenAI", false},
		{"gpt-4o-mini", "4o-mini", "OpenAI", true},
		{"llama-3.1-8b-instant", "llama-3.1-8b-instant", "Groq", false},
		{"qwen-qwq-32b", "qwen-qwq-32b", "Groq", true},
		{"llama3.2:3b", "lllama3.2:3b", "Ollama", false},
		{"deepseek-r1:8b", "deepseek-r1:8b", "Ollama", true},
		{"DeepHermes 3 Mistral 24B", "nousresearch/deephermes-3-mistral-24b-preview:free", "Open Router", false},
		{"Phi 4 Reasoning", "microsoft/phi-4-reasoning:free", "Open Router", true},
	}
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("models")
		if err != nil {
			return err
		}

		for _, d := range defaults {

			provider, err := app.FindFirstRecordByFilter(
				"providers", "name = {:name}",
				dbx.Params{"name": d.Provider},
			)
			if err != nil {
				return err
			}

			rec := core.NewRecord(collection)
			rec.Set("name", d.Name)
			rec.Set("ident", d.Ident)
			rec.Set("provider", provider.Get("id"))
			rec.Set("isThinking", d.IsThinking)
			if err := app.Save(rec); err != nil {
				return err
			}
		}

		return nil
	}, func(app core.App) error {
		for _, model := range defaults {
			record, err := app.FindFirstRecordByFilter(
				"models",
				"name = {:name} || ident = {:ident} || provider = {:provider} || isThinking = {:isThinking}",
				map[string]interface{}{
					"name":       model.Name,
					"ident":      model.Ident,
					"provider":   model.Provider,
					"isThinking": model.IsThinking,
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
