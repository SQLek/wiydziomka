package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	// Supported personas slice
	defaults := []struct {
		Name         string
		SystemPrompt string
	}{
		{"Joyful",
			`You're an joyful and helpful assistant.
			Respond concise and truthfully.
			You may use some feline behaviors.
			Your physical form is of magical book.
			Respond in same language as user.`},
		{"Balanced",
			`You're an helpful and truthful assistant.
			Answer specifically and get straight to the point, without beating around the bush.
			Your physical form is of a book. You may also use bear characteristics.
			Respond in same language as user.`},
		{"Formal",
			`You're an helpful and truthful assistant.
			Respond briefly, concisely, and in the same language as the user.
			Your physical form is a technologically advanced book.
			Use formal language whenever possible.`},
	}

	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("personas")
		if err != nil {
			return err
		}
		for _, d := range defaults {
			rec := core.NewRecord(collection)
			rec.Set("name", d.Name)
			rec.Set("systemPrompt", d.SystemPrompt)
			if err := app.Save(rec); err != nil {
				return err
			}
		}

		return nil
	}, func(app core.App) error {
		for _, persona := range defaults {
			record, err := app.FindFirstRecordByFilter(
				"personas",
				"name = {:name} || systemPrompt = {:systemPrompt}",
				map[string]interface{}{
					"name":         persona.Name,
					"systemPrompt": persona.SystemPrompt,
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
