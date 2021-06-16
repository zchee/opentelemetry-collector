# ----------------------------------------------------------------------------
# Go

GO_PATH  ?= $(shell go env GOPATH)
GO_OS    ?= $(shell go env GOOS)
GO_ARCH  ?= $(shell go env GOARCH)
CGO_ENABLED ?= 0

PKG := $(subst $(GO_PATH)/src/,,$(CURDIR))

GO_FLAGS ?= -trimpath

GO_GCFLAGS=
# https://tip.golang.org/doc/diagnostics.html#debugging
GO_GCFLAGS_DEBUG=all=-N -l -dwarflocationlists=true -e -smallframes

GO_LDFLAGS=-s -w
GO_LDFLAGS_STATIC="-extldflags=-static -static-pie -fno-PIC"
GO_LDFLAGS_DEBUG=all=-compressdwarf=false

GO_BUILDTAGS=
ifeq (${CGO_ENABLED},0)
	GO_BUILDTAGS=osusergo netgo
endif
GO_BUILDTAGS_STATIC=static
GO_INSTALLSUFFIX_STATIC=-installsuffix='netgo'
GO_FLAGS +=-tags='$(subst $(space),$(comma),${GO_BUILDTAGS})'

ifneq (${GO_GCFLAGS},)
	GO_FLAGS+=-gcflags='${GO_GCFLAGS}'
endif
ifneq (${GO_LDFLAGS},)
	GO_FLAGS+=-ldflags='${GO_LDFLAGS}'
endif

GO_LINT_FLAGS ?=
GO_LINT_PACKGAGES ?= ./...

TOOLS_DIR := ${CURDIR}/tools
TOOLS_BIN := ${TOOLS_DIR}/bin
TOOLS := $(shell cd ${TOOLS_DIR} && go list -v -x -f '{{ join .Imports " " }}' -tags=tools)

JOBS := $(shell getconf _NPROCESSORS_CONF)
ifeq ($(CIRCLECI),true)
ifeq (${GO_OS},linux)
	# https://circleci.com/changelog#container-cgroup-limits-now-visible-inside-the-docker-executor
	JOBS := $(shell echo $$(($$(cat /sys/fs/cgroup/cpu/cpu.shares) / 1024)))
	GO_TEST_FLAGS+=-p=${JOBS} -cpu=${JOBS}
endif
endif

COLLECTORS := otelcol-datadog

# ----------------------------------------------------------------------------
# targets

all: ${COLLECTORS}

##@ collector

.PHONY: otelcol-datadog
otelcol-datadog: bin/otelcol-datadog fmt
otelcol-datadog: PKG=$(subst $(GO_PATH)/src/,,$(CURDIR))/otelcol-datadog

bin/otelcol-datadog:  ## Build otelcol-datadog collector
bin/otelcol-datadog: tools/opentelemetry-collector-builder ./config/otelcol-datadog.yaml
	${TOOLS_BIN}/opentelemetry-collector-builder --go $(shell which go) --config ./config/otelcol-datadog.yaml


##@ fmt, lint

.PHONY: lint
lint: lint/golangci-lint  ## Run all linters.

.PHONY: lint/golangci-lint
lint/golangci-lint: tools/golangci-lint .golangci.yml  ## Run golangci-lint.
	${TOOLS_BIN}/golangci-lint -j ${JOBS} run $(strip ${GO_LINT_FLAGS}) ${GO_LINT_PACKGAGES}

.PHONY: fmt
fmt: tools/goimports tools/gofumpt  ## Run goimports and gofumpt.
	find ${GO_PATH}/src/${PKG} -type f -name '*.go' -not -path './vendor/*' | xargs -P ${JOBS} ${TOOLS_BIN}/goimports -local=${PKG} -w
	find ${GO_PATH}/src/${PKG} -type f -name '*.go' -not -path './vendor/*' | xargs -P ${JOBS} ${TOOLS_BIN}/gofumpt -s -extra -w


##@ tools

.PHONY: tools
tools: tools/bin/''  ## Install tools

tools/%:  ## install an individual dependent tool
	@${MAKE} tools/bin/$* 1>/dev/null

tools/bin/%: ${TOOLS_DIR}/go.mod ${TOOLS_DIR}/go.sum
	@cd tools; \
	  for t in ${TOOLS}; do \
			if [ -z '$*' ] || [ $$(basename $$t) = '$*' ]; then \
				echo "Install $$t ..." >&2; \
				GOBIN=${TOOLS_BIN} CGO_ENABLED=0 go install -mod=mod $(strip ${GO_FLAGS}) "$${t}"; \
			fi \
	  done


##@ clean

.PHONY: clean
clean:  ## Cleanups binaries and extra files in the package.
	@$(RM) -r ./bin *.out *.test *.prof trace.txt ${TOOLS_BIN} $(foreach col,${COLLECTORS},${CURDIR}/${col}/${col})


# ----------------------------------------------------------------------------
##@ help

.PHONY: help
help:  ## Show make target help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[33m<target>\033[0m\n"} /^[a-zA-Z_0-9\/_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: env env/%
env:  ## Print the value of MAKEFILE_VARIABLE. Use `make env/MAKEFILE_VARIABLE`.
env/%:
	@echo $($*)
