package migrations

import (
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	// Supported models slice
	defaults := []struct {
		Name        string
		Ident       string
		Provider    string
		IsPreferred bool
		IsThinking  bool
	}{
		{"gpt-4.1", "gpt-4.1", "OpenAI", true, false},
		{"gpt-4o-mini", "4o-mini", "OpenAI", false, true},
		{"llama-3.1-8b-instant", "llama-3.1-8b-instant", "Groq", true, false},
		{"qwen-qwq-32b", "qwen-qwq-32b", "Groq", false, true},
		{"llama3.2:3b", "lllama3.2:3b", "Ollama", true, false},
		{"deepseek-r1:8b", "deepseek-r1:8b", "Ollama", false, true},
		{"Llama 3.3 8B", "meta-llama/llama-3.3-8b-instruct:free", "Open Router", true, false},
		{"QwQ 32B", "qwen/qwq-32b:free", "Open Router", false, true},
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
			rec.Set("isPreferred", d.IsPreferred)
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
					"name":        model.Name,
					"ident":       model.Ident,
					"provider":    model.Provider,
					"isThinking":  model.IsThinking,
					"isPreferred": model.IsPreferred,
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
