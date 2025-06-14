package migrations

import (
	"encoding/json"

	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_3861817060")
		if err != nil {
			return err
		}

		// update collection data
		if err := json.Unmarshal([]byte(`{
			"createRule": "@request.auth.verified = true && (@request.body.preferredModel:isset = true || @request.body.thinkingModel:isset = true) && @request.body.user = @request.auth.id && @request.body.persona:isset = true"
		}`), &collection); err != nil {
			return err
		}

		return app.Save(collection)
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_3861817060")
		if err != nil {
			return err
		}

		// update collection data
		if err := json.Unmarshal([]byte(`{
			"createRule": "@request.auth.verified = true && (@request.body.preferredModel:isset = true || @request.body.thinkingModel::isset = true) && @request.body.user = @request.auth.id && @request.body.persona:isset = true"
		}`), &collection); err != nil {
			return err
		}

		return app.Save(collection)
	})
}
