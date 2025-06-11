package main

import (
	"time"

	"github.com/pocketbase/pocketbase/core"
)

func hookSoftDelete(e *core.RecordRequestEvent) error {
	if e.Collection.Name != "chats" {
		return nil
	}

	e.App.Logger().Info(
		"Soft delete triggered",
		"collection", e.Collection.Name,
		"id", e.Record.Id,
	)

	e.Record.Set("deleted", time.Now())
	e.App.Save(e.Record)

	return nil
}
