package build

import (
	"embed"
	"io/fs"
)

//go:embed web
var webFS embed.FS

func WebFs() fs.FS {
	fs, err := fs.Sub(webFS, "web")
	if err != nil {
		panic(err)
	}
	return fs
}
