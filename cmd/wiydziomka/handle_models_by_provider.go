package main

import (
	"net/http"

	"github.com/SQLek/wiydziomka/internal/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

//https://pocketbase.io/docs/go-routing/#registering-new-routes
// /api/models-by-provider/{providerId}

func HandleModelByProvider(e *core.RequestEvent) error {
	providerId := e.Request.PathValue("providerId")
	if providerId == "" {
		return e.Error(http.StatusBadRequest, "Provider ID is required", nil)
	}
	models, err := pocketbase.ListModels(e.Request.Context(), providerId)
	if err != nil {
		return err
	}
	return e.JSON(http.StatusOK, models)
}
