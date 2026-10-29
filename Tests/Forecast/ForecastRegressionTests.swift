import Foundation

@main
struct ForecastRegressionTests {
    @MainActor
    static func main() async throws {
        let manager = SearchManager()
        manager.coefficientMaintenances = [
            .init(maintenance: "Casa madre", coefficient: 1.1),
            .init(maintenance: "Nessuna documentazione", coefficient: 0.8)
        ]
        manager.coefficientColors = [.init(color: "Nero", coefficient: 1.05), .init(color: "Altro", coefficient: 0.9)]
        manager.coefficientLocations = [.init(location: "Nord", coefficient: 1.02)]
        manager.coefficientNumberOfOwners = [.init(owners: 1, coefficient: 1.03)]
        manager.coefficientOptionals = [.init(optional: "Tetto", coefficient: 1.1), .init(optional: "Altro", coefficient: 1.2)]
        var car = UserCar(brand: "Test", model: "Auto", engine: "Benzina", registrationYear: 2020,
                          actualKm: 60000, version: nil, color: "Nero", zone: "Nord",
                          certifiedManintenance: "Casa madre", optionals: ["Tetto"], numberOfOwners: 1)
        // Increasing values are valid: appreciation must survive validation and adjustment.
        let base = [DepreciationPoint(year: 2020, value: 20000), .init(year: 2021, value: 25000)]
        let complete = try ForecastScenarioAdjustment(userCar: car, searchManager: manager)
        precondition(complete.factors.isEmpty) // Missing version has no scenario coefficient.
        precondition(complete.optimisticSeries(from: base) == base)
        precondition(complete.pessimisticSeries(from: base) == base)

        car.certifiedManintenance = nil
        let missing = try ForecastScenarioAdjustment(userCar: car, searchManager: manager)
        precondition(missing.missingParameters == ["certifiedMaintenance"])
        precondition(abs(missing.optimisticMultiplier - Double(Float(1.1))) < 0.00001)
        precondition(abs(missing.pessimisticMultiplier - Double(Float(0.8))) < 0.00001)
        precondition(missing.pessimisticSeries(from: base)[1].value > missing.pessimisticSeries(from: base)[0].value)
        car.color = "  "
        let multiple = try ForecastScenarioAdjustment(userCar: car, searchManager: manager)
        precondition(abs(multiple.optimisticMultiplier - Double(Float(1.1)) * Double(Float(1.05))) < 0.00001)
        precondition(abs(multiple.pessimisticMultiplier - Double(Float(0.8)) * Double(Float(0.9))) < 0.00001)
        car.optionals = []
        let accessories = try ForecastScenarioAdjustment(userCar: car, searchManager: manager)
        // Keep the existing engine's single best accessory, not the product of all accessories.
        precondition(abs(accessories.factors.first { $0.parameter == "optionals" }!.optimistic - Double(Float(1.2))) < 0.00001)
        precondition(accessories.factors.first { $0.parameter == "optionals" }!.pessimistic == 1)

        manager.coefficientMaintenances = []
        car.color = "Nero"
        car.optionals = ["Tetto"]
        let noCatalog = try ForecastScenarioAdjustment(userCar: car, searchManager: manager)
        precondition(noCatalog.optimisticMultiplier == 1 && noCatalog.pessimisticMultiplier == 1)
        for bad in [Float.nan, .infinity, 0, -1] {
            manager.coefficientMaintenances = [.init(maintenance: "Invalid", coefficient: bad)]
            do {
                _ = try ForecastScenarioAdjustment(userCar: car, searchManager: manager)
                preconditionFailure("Invalid coefficient accepted")
            } catch AIForecastError.requestFailed { }
        }
        manager.coefficientMaintenances = []

        let input = AIForecastInput(vehicle: .init(car), referencePurchasePrice: 20000,
            analysisYears: 1, annualMileageKm: 10000)
        let payload = try JSONSerialization.jsonObject(with: JSONEncoder().encode(input)) as! [String: Any]
        precondition(Set(payload.keys) == Set(["vehicle", "referencePurchasePrice", "analysisYears", "annualMileageKm"]))
        precondition(payload["model"] == nil && payload["messages"] == nil)
        let vehicle = payload["vehicle"] as! [String: Any]
        precondition(vehicle["certifiedMaintenance"] == nil)
        precondition(vehicle["optionals"] as? [String] == ["Tetto"])
        let valid = try ForecastOutputValidator.makeForecast(.init(data: base), input: input, userCar: car, adjustment: missing)
        precondition(valid.purchasePrice == 20000)
        for bad in [Array(base.reversed()), [base[0], base[0]], [base[0]], base + [base[1]],
                    [.init(year: 2020, value: -1), base[1]], [.init(year: 2020, value: .nan), base[1]]] {
            do {
                _ = try ForecastOutputValidator.makeForecast(.init(data: bad), input: input, userCar: car, adjustment: missing)
                preconditionFailure("Invalid output accepted")
            } catch AIForecastError.invalidResponse { }
        }
        let outputData = Data("{\"data\":[{\"year\":2020,\"value\":20000},{\"year\":2021,\"value\":25000}]}".utf8)
        let decoded = try JSONDecoder().decode(AIForecastOutput.self, from: outputData)
        var calls = 0
        let service = AIForecastService { submitted in
            calls += 1
            precondition(submitted.vehicle.brand == car.brand)
            return decoded
        }
        let generated = try await service.generateForecast(for: car, searchManager: manager, years: 1)
        precondition(calls == 1)
        precondition(generated.data.map(\.value) == [20000, 25000])
        precondition(generated.optimisticData == generated.data && generated.pessimisticData == generated.data)
        let invalidService = AIForecastService { _ in AIForecastOutput(data: []) }
        do {
            _ = try await invalidService.generateForecast(for: car, searchManager: manager, years: 1)
            preconditionFailure("Invalid backend output accepted")
        } catch AIForecastError.invalidResponse { }
        let error = ForecastBackendError.map(statusCode: 429, data: Data("{\"code\":\"quota_exceeded\"}".utf8))
        guard case .quotaExceeded = error else { preconditionFailure("Quota not mapped") }
        guard case .authenticationRequired = ForecastBackendError.map(statusCode: 401, data: Data()) else { preconditionFailure("Auth not mapped") }
        let redacted = ForecastBackendError.map(statusCode: 500, data: Data("sensitive-upstream-error".utf8))
        precondition(!redacted.localizedDescription.contains("sensitive-upstream-error"))
        print("PASS: missing-only coefficient scenarios, appreciation, invalid catalog/series rejection, backend payload, typed decoding, auth/quota/safe error handling")
    }
}
