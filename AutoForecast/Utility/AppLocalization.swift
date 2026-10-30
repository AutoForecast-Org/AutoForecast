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
