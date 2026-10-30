import Foundation

@main
struct LocalizationRegressionTests {
    static func main() throws {
        let bundle = Bundle(path: CommandLine.arguments[1])!
        let original = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
        defer { UserDefaults.standard.setVolatileDomain(original, forName: UserDefaults.argumentDomain) }
        func language(_ value: String) {
            UserDefaults.standard.setVolatileDomain(["appLanguage": value], forName: UserDefaults.argumentDomain)
        }
        func check(_ actual: String, _ expected: String) {
            precondition(actual == expected, "Expected '\(expected)', got '\(actual)'")
        }
        language("en")
        let brand = "Fiat"
        let model = "Panda"
        check(AppLocalization.string("\(brand) \(model)", bundle: bundle), "Fiat Panda")
        check(AppLocalization.string("Valore odierno", bundle: bundle), "Current value")
        check(AppLocalization.string("Valore anno \(String(2039))", bundle: bundle), "Value in 2039")
        check(AppLocalization.string("\(1) anni", bundle: bundle), "1 year")
        check(AppLocalization.string("\(2) anni", bundle: bundle), "2 years")
        check(AppLocalization.string("\(0) auto salvate", bundle: bundle), "0 saved cars")
        check(AppLocalization.string("\(1) auto salvate", bundle: bundle), "1 saved car")
        check(AppLocalization.string("\(2) auto salvate", bundle: bundle), "2 saved cars")
        check(AppLocalization.string("\(1) selezionati", bundle: bundle), "1 selected")
        check(AppLocalization.string("Passo \(1) di \(4)", bundle: bundle), "Step 1 of 4")
        check(AppLocalization.string("Accedi nuovamente per generare una previsione.", bundle: bundle), "Sign in again to generate a forecast.")
        language("it")
        check(AppLocalization.string("Valore odierno", bundle: bundle), "Valore odierno")
        check(AppLocalization.string("\(1) anni", bundle: bundle), "1 anno")
        check(AppLocalization.string("\(2) anni", bundle: bundle), "2 anni")
        check(AppLocalization.string("\(1) auto salvate", bundle: bundle), "1 auto salvata")
        check(AppLocalization.string("\(2) auto salvate", bundle: bundle), "2 auto salvate")
        check(AppLocalization.string("\(1) selezionati", bundle: bundle), "1 selezionato")
        check(AppLocalization.string("\(2) selezionati", bundle: bundle), "2 selezionati")
        check(AppLocalization.string("Piu stabile", bundle: bundle), "Più stabile")
        print("PASS: compiled catalog, in-app language switching, plural forms and formatted placeholders")
    }
}
