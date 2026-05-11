package main

import (
	"fmt"
	"net/url"
)

func main() {
	base, _ := url.Parse("https://gcp-logos-mcp-71857982597.europe-north2.run.app/sse")
	rel, _ := url.Parse("https://gcp-logos-mcp-71857982597.europe-north2.run.app/messages/?session_id=123")
	fmt.Println(base.ResolveReference(rel).String())
}
