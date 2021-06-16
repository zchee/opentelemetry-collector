module github.com/zchee/opentelemetry-collectors/otelcol-datadog

go 1.16

require (
	github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter v0.28.0
	go.opentelemetry.io/collector v0.28.0
)

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/common => github.com/open-telemetry/opentelemetry-collector-contrib/internal/common v0.28.0

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter => github.com/DataDog/opentelemetry-collector-contrib/exporter/datadogexporter v0.0.0-20210614204930-e1492a1ed241
