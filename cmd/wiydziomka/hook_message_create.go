package main

import (
	"encoding/json"

	"github.com/pocketbase/pocketbase/core"
)

func hookMessageCreate(e *core.RecordRequestEvent) error {

	// TODO: We insert message
	if err := e.Next(); err != nil {
		return err
	}

	var body struct {
		IsThinking bool `json:"isThinking"`
	}
	json.NewDecoder(e.RequestEvent.Request.Body).Decode(&body)

	go generateMessage(e.App, e.Record.GetString("chat"), body.IsThinking)

	return nil
}
