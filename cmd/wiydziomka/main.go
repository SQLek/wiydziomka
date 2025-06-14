package main

import (
	"os"
	"path/filepath"
	"strings"

	_ "github.com/SQLek/wiydziomka/cmd/wiydziomka/migrations"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

func main() {
	app := pocketbase.New()

	app.OnRecordDeleteRequest("chats").BindFunc(hookSoftDelete)
	app.OnRecordCreateRequest("messages").BindFunc(hookMessageCreate)

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: isInDev(),
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
