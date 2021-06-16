// SPDX-FileCopyrightText: 2021 The opentelemetry-collector Authors
// SPDX-License-Identifier: BSD-3-Clause

//go:build tools
// +build tools

// Package tools manages tools using during development.
package tools

import (
	// builder
	_ "github.com/open-telemetry/opentelemetry-collector-builder"

	// formatter, linter
	_ "github.com/golangci/golangci-lint/cmd/golangci-lint"
	_ "golang.org/x/tools/cmd/goimports"
	_ "gotest.tools/gotestsum"
	_ "mvdan.cc/gofumpt"
)
