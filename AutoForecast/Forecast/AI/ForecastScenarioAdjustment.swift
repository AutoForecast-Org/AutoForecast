import Foundation

/// Applies the existing engine's multiplicative coefficients to an AI-generated base curve.
/// Known parameters are already reflected in the base; only missing optionals vary.
struct ForecastScenarioAdjustment {
    struct Factor {
        let parameter: String
        let optimistic: Double
        let pessimistic: Double
    }

    let factors: [Factor]
    var missingParameters: [String] { factors.map(\.parameter) }
    var optimisticMultiplier: Double { factors.reduce(1) { $0 * $1.optimistic } }
    var pessimisticMultiplier: Double { factors.reduce(1) { $0 * $1.pessimistic } }

    @MainActor
    init(userCar: UserCar, searchManager: SearchManager) throws {
        var missing: [Factor] = []
        func append(_ parameter: String, isMissing: Bool, coefficients: [Float]) throws {
            guard isMissing else { return }
            guard coefficients.allSatisfy({ $0.isFinite && $0 > 0 }) else {
                let labels: [String: String.LocalizationValue] = [
                    "color": "Colore", "zone": "Zona geografica",
                    "certifiedMaintenance": "Manutenzione",
                    "numberOfOwners": "Numero di proprietari", "optionals": "Optionals"
                ]
                let label = AppLocalization.string(labels[parameter] ?? "Parametri opzionali")
                throw AIForecastError.requestFailed(AppLocalization.string("Coefficienti remoti non validi per \(label)."))
            }
            // 1 is the existing neutral fallback. Empty tables leave the curve unchanged.
            // The neutral base is included so a missing factor cannot invert the scenarios.
            missing.append(Factor(parameter: parameter,
                                  optimistic: max(1, Double(coefficients.max() ?? 1)),
                                  pessimistic: min(1, Double(coefficients.min() ?? 1))))
        }

        try append("color", isMissing: userCar.color.forecastValue == nil,
                   coefficients: searchManager.coefficientColors.map(\.coefficient))
        try append("zone", isMissing: userCar.zone.forecastValue == nil,
                   coefficients: searchManager.coefficientLocations.map(\.coefficient))
        try append("certifiedMaintenance", isMissing: userCar.certifiedManintenance.forecastValue == nil,
                   coefficients: searchManager.coefficientMaintenances.map(\.coefficient))
        try append("numberOfOwners", isMissing: userCar.numberOfOwners == nil,
                   coefficients: searchManager.coefficientNumberOfOwners.map(\.coefficient))
        // The current UserCar contract represents unselected optionals as [].
        // As in resolveOptimistic/PessimisticCoefficients, pick one catalog extremum,
        // rather than inventing a bundle of all potentially incompatible accessories.
        try append("optionals", isMissing: userCar.optionals.isEmpty,
                   coefficients: searchManager.coefficientOptionals.map(\.coefficient))
        factors = missing
        guard optimisticMultiplier.isFinite, pessimisticMultiplier.isFinite,
              pessimisticMultiplier > 0 else {
            throw AIForecastError.requestFailed(AppLocalization.string("Prodotto dei coefficienti remoti non valido."))
        }
    }

    func optimisticSeries(from base: [DepreciationPoint]) -> [DepreciationPoint] {
        apply(optimisticMultiplier, to: base)
    }

    func pessimisticSeries(from base: [DepreciationPoint]) -> [DepreciationPoint] {
        apply(pessimisticMultiplier, to: base)
    }

    private func apply(_ multiplier: Double, to base: [DepreciationPoint]) -> [DepreciationPoint] {
        if multiplier == 1 { return base }
        return base.map { DepreciationPoint(year: $0.year, value: $0.value * multiplier) }
    }
}

extension Optional where Wrapped == String {
    var forecastValue: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        return value
    }
}
