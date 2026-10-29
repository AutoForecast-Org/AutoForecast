// The command-line regression suite only needs the dataset, not Supabase or UI state.
@MainActor
final class SearchManager {
    var carsDataset: [Car] = []
    var coefficientCarCategories: [CoefficientCarCategory] = []
    var coefficientColors: [CoefficientColor] = []
    var coefficientDepreciationOverYears: [CoefficientDepreciationOverYears] = []
    var coefficientFuelTypes: [CoefficientFuelType] = []
    var coefficientLocations: [CoefficientLocation] = []
    var coefficientMaintenances: [CoefficientMaintenance] = []
    var coefficientNumberOfOwners: [CoefficientNumberOfOwners] = []
    var coefficientOptionals: [CoefficientOptional] = []
}

// The real Supabase adapter is compiled by the Xcode app build. Regression tests inject a backend.
@MainActor
enum SupabaseForecastClient {
    static func generateForecast(_ input: AIForecastInput) async throws -> AIForecastOutput {
        fatalError("Regression tests must inject their backend")
    }
}
