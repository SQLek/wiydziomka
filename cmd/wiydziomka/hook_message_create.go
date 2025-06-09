package main

import "github.com/pocketbase/pocketbase/core"

func hookMessageCreate(e *core.RecordRequestEvent) error {

	// TODO: We insert message
	e.Next() // add checking error
	// we return newly created message
	// frontend will subscribe to new messages
	// so no need to wait for LLM to respond

	// TODO: in goroutine or something we chat complete.
	// there is only one provider, lest use it for now.
	// add TODO: tag od issue to add provider selection
	// we use model with isPreferred = true for now.
	// add TODO: as above

	return nil
}
