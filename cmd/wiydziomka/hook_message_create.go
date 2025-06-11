package main

import "github.com/pocketbase/pocketbase/core"

func hookMessageCreate(e *core.RecordRequestEvent) error {

	// TODO: We insert message
	if err := e.Next(); err != nil {
		return err
	}

	go handleMessage(e.App, e.Record.GetString("chat"))

	return nil
}
