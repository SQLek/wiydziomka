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
			"createRule": "@request.auth.verified = true && (@request.body.preferredModel:isset = true || @request.body.thinkingModel::isset = true) && @request.body.user = @request.auth.id && @request.body.persona:isset = true"
		}`), &collection); err != nil {
			return err
		}

		// add field
		if err := collection.Fields.AddMarshaledJSONAt(5, []byte(`{
			"cascadeDelete": false,
			"collectionId": "pbc_3552922951",
			"hidden": false,
			"id": "relation1956606570",
			"maxSelect": 1,
			"minSelect": 0,
			"name": "preferredModel",
			"presentable": false,
			"required": false,
			"system": false,
			"type": "relation"
		}`)); err != nil {
			return err
		}

		// add field
		if err := collection.Fields.AddMarshaledJSONAt(6, []byte(`{
			"cascadeDelete": false,
			"collectionId": "pbc_3552922951",
			"hidden": false,
			"id": "relation2957824107",
			"maxSelect": 1,
			"minSelect": 0,
			"name": "thinkingModel",
			"presentable": false,
			"required": false,
			"system": false,
			"type": "relation"
		}`)); err != nil {
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
			"createRule": "@request.auth.verified = true"
		}`), &collection); err != nil {
			return err
		}

		// remove field
		collection.Fields.RemoveById("relation1956606570")

		// remove field
		collection.Fields.RemoveById("relation2957824107")

		return app.Save(collection)
	})
}
