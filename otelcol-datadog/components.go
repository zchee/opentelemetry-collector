// Copyright 2020 OpenTelemetry Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/consumer/consumererror"

	// extensions
	bearertokenauthextension "go.opentelemetry.io/collector/extension/bearertokenauthextension"
	healthcheckextension "go.opentelemetry.io/collector/extension/healthcheckextension"
	oidcauthextension "go.opentelemetry.io/collector/extension/oidcauthextension"
	pprofextension "go.opentelemetry.io/collector/extension/pprofextension"
	zpagesextension "go.opentelemetry.io/collector/extension/zpagesextension"

	// receivers
	otlpreceiver "go.opentelemetry.io/collector/receiver/otlpreceiver"

	// exporters
	datadogexporter "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter"
	fileexporter "go.opentelemetry.io/collector/exporter/fileexporter"
	jaegerexporter "go.opentelemetry.io/collector/exporter/jaegerexporter"
	loggingexporter "go.opentelemetry.io/collector/exporter/loggingexporter"

	// processors
	batchprocessor "go.opentelemetry.io/collector/processor/batchprocessor"
)

func components() (component.Factories, error) {
	var errs []error
	var err error
	var factories component.Factories
	factories = component.Factories{}

	extensions := []component.ExtensionFactory{
		bearertokenauthextension.NewFactory(),
		healthcheckextension.NewFactory(),
		oidcauthextension.NewFactory(),
		pprofextension.NewFactory(),
		zpagesextension.NewFactory(),
	}
	for _, ext := range factories.Extensions {
		extensions = append(extensions, ext)
	}
	factories.Extensions, err = component.MakeExtensionFactoryMap(extensions...)
	if err != nil {
		errs = append(errs, err)
	}

	receivers := []component.ReceiverFactory{
		otlpreceiver.NewFactory(),
	}
	for _, rcv := range factories.Receivers {
		receivers = append(receivers, rcv)
	}
	factories.Receivers, err = component.MakeReceiverFactoryMap(receivers...)
	if err != nil {
		errs = append(errs, err)
	}

	exporters := []component.ExporterFactory{
		datadogexporter.NewFactory(),
		fileexporter.NewFactory(),
		jaegerexporter.NewFactory(),
		loggingexporter.NewFactory(),
	}
	for _, exp := range factories.Exporters {
		exporters = append(exporters, exp)
	}
	factories.Exporters, err = component.MakeExporterFactoryMap(exporters...)
	if err != nil {
		errs = append(errs, err)
	}

	processors := []component.ProcessorFactory{
		batchprocessor.NewFactory(),
	}
	for _, pr := range factories.Processors {
		processors = append(processors, pr)
	}
	factories.Processors, err = component.MakeProcessorFactoryMap(processors...)
	if err != nil {
		errs = append(errs, err)
	}

	return factories, consumererror.Combine(errs)
}
