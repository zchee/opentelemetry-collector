module github.com/zchee/opentelemetry-collectors/tools

go 1.16

require (
	github.com/golangci/golangci-lint v1.40.1
	github.com/open-telemetry/opentelemetry-collector-builder v0.27.0
	golang.org/x/tools v0.1.4-0.20210616015516-463a76b3dc75
	gotest.tools/gotestsum v1.6.4
	mvdan.cc/gofumpt v0.1.1
)

// hack until open-telemetry/opentelemetry-collector-builder supports v0.28.0.
// github.com/zchee/opentelemetry-collector-builder optimize-skaffold
replace github.com/open-telemetry/opentelemetry-collector-builder => github.com/zchee/opentelemetry-collector-builder v0.27.1-0.20210616062143-d6406b0a3ef7
