#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
build_dir=$(mktemp -d /tmp/autoforecast-tests.XXXXXX)
swiftc -module-cache-path "$build_dir/module-cache" -o "$build_dir/forecast-tests" \
    AutoForecast/Car/Car.swift \
    AutoForecast/Car/CoefficientModels.swift \
    AutoForecast/Parameter/Model/UserCar.swift \
    AutoForecast/Forecast/Model/DepreciationPoint.swift \
    AutoForecast/Forecast/Engine/DepreciationEngine.swift \
    AutoForecast/Forecast/AI/ForecastScenarioAdjustment.swift \
    AutoForecast/Forecast/AI/AIForecastService.swift \
    Tests/Forecast/SearchManagerStub.swift \
    Tests/Forecast/ForecastRegressionTests.swift
"$build_dir/forecast-tests"
