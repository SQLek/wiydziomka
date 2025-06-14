package main

import (
	"os"
	"path/filepath"
	"strings"

	"github.com/SQLek/wiydziomka/build"
	_ "github.com/SQLek/wiydziomka/cmd/wiydziomka/migrations"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

func main() {
	app := pocketbase.New()

	app.OnRecordDeleteRequest("chats").BindFunc(hookSoftDelete)
	app.OnRecordCreateRequest("messages").BindFunc(hookMessageCreate)

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: isInDev(),
	})

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// serves static files from the provided dir (if exists)
		se.Router.GET("/{path...}", apis.Static(build.WebFs(), false))
		return se.Next()
	})

	if err := app.Start(); err != nil {
		app.Logger().Error("Error starting PocketBase", "error", err)
	}
}

func isInDev() bool {
	file := filepath.Base(os.Args[0])
	if strings.HasPrefix(file, "__debug_bin") {
		return true
	}

	if strings.HasPrefix(os.Args[0], os.TempDir()) {
		return true
	}

	return false
}
