#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 Tests/Localization/check_catalog.py
build_dir=$(mktemp -d /tmp/autoforecast-localization.XXXXXX)
mkdir -p "$build_dir/Localization.bundle"
xcrun xcstringstool compile Localizable.xcstrings --output-directory "$build_dir/Localization.bundle"
swiftc -module-cache-path "$build_dir/module-cache" -o "$build_dir/localization-tests" \
    AutoForecast/Utility/AppLocalization.swift Tests/Localization/LocalizationRegressionTests.swift
"$build_dir/localization-tests" "$build_dir/Localization.bundle"
