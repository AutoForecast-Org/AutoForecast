//
//  AppLocalization.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

/// Foundation-generated messages must follow the in-app language picker as SwiftUI does.
enum AppLocalization {
    static var locale: Locale {
        Locale(identifier: language)
    }

    private static var language: String {
        UserDefaults.standard.string(forKey: "appLanguage") == "en" ? "en" : "it"
    }

    static func string(_ value: String.LocalizationValue, bundle sourceBundle: Bundle = .main) -> String {
        let bundle = sourceBundle.path(forResource: language, ofType: "lproj")
            .flatMap(Bundle.init(path:)) ?? sourceBundle
        return String(localized: value, bundle: bundle, locale: locale)
    }
}
