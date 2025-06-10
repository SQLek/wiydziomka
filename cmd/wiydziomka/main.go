package main

import (
	"log"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/SQLek/wiydziomka/migrations"

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
		log.Fatal(err)
	}
}

func isInDev() bool {
	file := filepath.Base(os.Args[0])
	if strings.HasPrefix(file, "__debug_bin") {
		return true
	}

	// TODO: detect go run

	return false
}
