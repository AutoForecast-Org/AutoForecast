//
//  Comparison+DepreciationEngine.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

extension DepreciationEngine {
    func makeVirtualUserCar(from car: Car, filters: ComparisonFilters) -> UserCar {
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = max(currentYear - car.year, 1)
        let fuel = searchManager.coefficientFuelTypes.first { $0.fuel.lowercased() == car.fuel.lowercased() } ?? defaultFuel
        return UserCar(
            brand: car.brand,
            model: car.model,
            engine: car.engine,
            registrationYear: car.year,
            actualKm: age * fuel.averageKmByYears, // km avg, neutral coeff
            version: car.version,
            color: nil,
            zone: filters.zone,// optional: if the user apply the zone, the zone will apply to competitors
            certifiedManintenance: nil,
            optionals: [],
            numberOfOwners: nil
        )
    }
}

extension DepreciationEngine {
    /// Segment normalization
    private func normalizedSegment(_ category: String) -> String {
        let upper = category.uppercased()
        if upper.hasSuffix("-SUV") {
            return String(upper.dropLast(4))
        }
        return upper
    }

    func generateComparison(
        referenceUserCar: UserCar,
        referenceBasePrice: Double,
        delta: Double = 3000,
        maxResults: Int = 5,
        filters: ComparisonFilters
    ) -> ComparisonResult {

        // Reference vehicle category and fuel type, using the primary forecast's fallback logic.
        let referenceCars = resolveCar(userCar: referenceUserCar)
        let referenceCategory = referenceCars.first?.category ?? defaultCategory.category
        let referenceFuel = referenceCars.first?.fuel ?? defaultFuel.fuel
        let referenceSegment = normalizedSegment(referenceCategory)

        let lowerBound = referenceBasePrice - delta
        let upperBound = referenceBasePrice + delta

        let pool = searchManager.carsDataset.filter { car in
            guard let price = car.price else { return false }
            guard Double(price) >= lowerBound && Double(price) <= upperBound else { return false }

            //Model distinct from the reference model (mandatory)
            guard car.model.lowercased() != referenceUserCar.model.lowercased() else { return false }

            // same fuel (mandatory)
            guard car.fuel.lowercased() == referenceFuel.lowercased() else { return false }

            // same segment, C ≡ C-SUV ecc. (mandatory)
            guard let carCategory = car.category, normalizedSegment(carCategory) == referenceSegment else {
                return false
            }

            // Optional year of registration refinement
            if let maxDelta = filters.maxRegistrationYearDelta {
                guard abs(car.year - referenceUserCar.registrationYear) <= maxDelta else { return false }
            }

            return true
        }

        // One result per model: selects the match closest in price to the reference.
        var bestPerModel: [String: Car] = [:]
        for car in pool {
            let key = "\(car.brand.lowercased())|\(car.model.lowercased())"
            let carDelta = abs(Double(car.price ?? 0) - referenceBasePrice)
            let bestDelta = bestPerModel[key].map { abs(Double($0.price ?? 0) - referenceBasePrice) }
                ?? .greatestFiniteMagnitude
            if carDelta < bestDelta {
                bestPerModel[key] = car
            }
        }

        let selected = bestPerModel.values
            .sorted { abs(Double($0.price ?? 0) - referenceBasePrice) < abs(Double($1.price ?? 0) - referenceBasePrice) }
            .prefix(maxResults)

        let candidates: [ComparisonCandidate] = selected.map { car in
            let virtual = makeVirtualUserCar(from: car, filters: filters)
            let base = resolvePurchasePrice(userCar: virtual)
            let data = generateDepreciationData(userCar: virtual, basePrice: base)
            return ComparisonCandidate(car: car, virtualUserCar: virtual, basePrice: base, data: data)
        }

        return ComparisonResult(candidates: candidates)
    }
}
