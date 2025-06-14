package migrations

import (
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
		{"gpt-4.1", "gpt-4.1", "openai", false},
		{"gpt-4o-mini", "4o-mini", "openai", true},
		{"llama-3.1-8b-instant", "llama-3.1-8b-instant", "groq", false},
		{"qwen-qwq-32b", "qwen-qwq-32b", "groq", true},
		{"llama3.2:3b", "lllama3.2:3b", "ollama", false},
		{"deepseek-r1:8b", "deepseek-r1:8b", "ollama", true},
		{"DeepHermes 3 Mistral 24B", "nousresearch/deephermes-3-mistral-24b-preview:free", "openrouter", false},
		{"Phi 4 Reasoning", "microsoft/phi-4-reasoning:free", "openrouter", true},
	}
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("models")
		if err != nil {
			return err
		}
		for _, d := range defaults {
			rec := core.NewRecord(collection)
			rec.Set("name", d.Name)
			rec.Set("ident", d.Ident)
			rec.Set("provider", d.Provider)
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
