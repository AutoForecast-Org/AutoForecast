//
//  DepreciationEngine.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

@MainActor
struct DepreciationEngine {

    let searchManager: SearchManager

    let defaultPrice: Double = 20000

    let defaultFuel = CoefficientFuelType(
        fuel: "Benzina",
        description: "Benzina",
        averageKmByYears: 7000,
        coefficient: 1.0
    )

    let defaultCategory = CoefficientCarCategory(
        category: "A",
        description: "Citycar",
        length: "< 3,70 m",
        coefficient: 1.0
    )

    // MARK: - KM COEFFICIENT
    func kmCoefficient(
        isOptimisticCurve: Bool = false,
        isPessimisticCurve: Bool = false,
        registrationYear: Int,
        currentKm: Int,
        averageKmPerYear: Int
    ) -> Double {

        if isOptimisticCurve {
            return Double(1.05)
        }

        if isPessimisticCurve {
            return Double(0.90)
        }

        let currentYear = Calendar.current.component(.year, from: Date())
        let age = max(currentYear - registrationYear, 1)

        let expectedKm = age * averageKmPerYear
        let deltaKm = currentKm - expectedKm

        let steps = Double(deltaKm) / 1000.0
        let coefficient = 1.0 - (steps * 0.003)

        return max(coefficient, 0.7)
    }

    // MARK: - CAR RESOLUTION
    func resolveCar(userCar: UserCar) -> [Car] {

        let cars = searchManager.carsDataset.filter {
            $0.brand.lowercased() == userCar.brand.lowercased() &&
            $0.model.lowercased() == userCar.model.lowercased() &&
            $0.engine.lowercased() == userCar.engine.lowercased() &&
            $0.year == userCar.registrationYear
        }

        if let version = userCar.version {
            return cars.filter { $0.version?.lowercased() == version.lowercased() }
        }

        return cars
    }

    func resolvePurchasePrice(userCar: UserCar) -> Double {

        let cars = resolveCar(userCar: userCar)

        if !cars.isEmpty {
            let sumPrice = cars.reduce(0.0) { $0 + Double($1.price ?? 0) }
            return sumPrice / Double(cars.count)
        }

        // 🔁 fallback: stesso modello, anno più vicino
        let fallback = searchManager.carsDataset
            .filter {
                $0.brand.lowercased() == userCar.brand.lowercased() &&
                $0.model.lowercased() == userCar.model.lowercased() &&
                $0.engine.lowercased() == userCar.engine.lowercased()
            }
            .min(by: {
                abs($0.year - userCar.registrationYear) < abs($1.year - userCar.registrationYear)
            })

        if let fallbackPrice = fallback?.price {
            return Double(fallbackPrice)
        } else {
            return defaultPrice
        }
    }

    // MARK: - COEFFICIENTS (BASE)
    func resolveCoefficients(userCar: UserCar) -> (
        category: CoefficientCarCategory,
        fuel: CoefficientFuelType,
        location: CoefficientLocation?,
        maintenance: CoefficientMaintenance?,
        owners: CoefficientNumberOfOwners?,
        optionals: [CoefficientOptional]
    )? {

        let cars = resolveCar(userCar: userCar)
        guard let car = cars.first else { return nil }

        let fuel = searchManager.coefficientFuelTypes.first {
            $0.fuel.lowercased() == car.fuel.lowercased()
        } ?? defaultFuel

        let category: CoefficientCarCategory = {
            guard let categoryKey = car.category else { return defaultCategory }
            return searchManager.coefficientCarCategories.first {
                $0.category.lowercased() == categoryKey.lowercased()
            } ?? defaultCategory
        }()

        let location: CoefficientLocation? =
            userCar.zone.flatMap { zone in
                searchManager.coefficientLocations.first {
                    $0.location.lowercased() == zone.lowercased()
                }
            }

        let maintenance: CoefficientMaintenance? =
            userCar.certifiedManintenance.flatMap { key in
                searchManager.coefficientMaintenances.first {
                    $0.maintenance.lowercased() == key.lowercased()
                }
            }

        let owners: CoefficientNumberOfOwners? =
            userCar.numberOfOwners.flatMap { value in
                searchManager.coefficientNumberOfOwners.first {
                    $0.owners == value
                }
            }

        let optionals = searchManager.coefficientOptionals.filter {
            userCar.optionals.contains($0.optional)
        }

        return (category, fuel, location, maintenance, owners, optionals)
    }

    // MARK: - COEFFICIENTS (OPTIMISTIC)
    func resolveOptimisticCoefficients(userCar: UserCar) -> (
        category: CoefficientCarCategory,
        fuel: CoefficientFuelType,
        location: CoefficientLocation?,
        maintenance: CoefficientMaintenance?,
        owners: CoefficientNumberOfOwners?,
        optionals: [CoefficientOptional]
    )? {

        let cars = resolveCar(userCar: userCar)
        guard let car = cars.first else { return nil }

        let fuel = searchManager.coefficientFuelTypes.first {
            $0.fuel.lowercased() == car.fuel.lowercased()
        } ?? defaultFuel

        let category: CoefficientCarCategory = {
            guard let categoryKey = car.category else { return defaultCategory }
            return searchManager.coefficientCarCategories.first {
                $0.category.lowercased() == categoryKey.lowercased()
            } ?? defaultCategory
        }()

        let location = searchManager.coefficientLocations.max { $0.coefficient < $1.coefficient }
        let maintenance = searchManager.coefficientMaintenances.max { $0.coefficient < $1.coefficient }
        let owners = searchManager.coefficientNumberOfOwners.max { $0.coefficient < $1.coefficient }

        var optionals: [CoefficientOptional] = []
        if let optional = searchManager.coefficientOptionals.max(by: { $0.coefficient < $1.coefficient }) {
            optionals = [optional]
        }

        return (category, fuel, location, maintenance, owners, optionals)
    }

    // MARK: - COEFFICIENTS (PESSIMISTIC)
    func resolvePessimisticCoefficients(userCar: UserCar) -> (
        category: CoefficientCarCategory,
        fuel: CoefficientFuelType,
        location: CoefficientLocation?,
        maintenance: CoefficientMaintenance?,
        owners: CoefficientNumberOfOwners?,
        optionals: [CoefficientOptional]
    )? {

        let cars = resolveCar(userCar: userCar)
        guard let car = cars.first else { return nil }

        let fuel = searchManager.coefficientFuelTypes.first {
            $0.fuel.lowercased() == car.fuel.lowercased()
        } ?? defaultFuel

        let category: CoefficientCarCategory = {
            guard let categoryKey = car.category else { return defaultCategory }
            return searchManager.coefficientCarCategories.first {
                $0.category.lowercased() == categoryKey.lowercased()
            } ?? defaultCategory
        }()

        let location = searchManager.coefficientLocations.min { $0.coefficient < $1.coefficient }
        let maintenance = searchManager.coefficientMaintenances.min { $0.coefficient < $1.coefficient }
        let owners = searchManager.coefficientNumberOfOwners.min { $0.coefficient < $1.coefficient }

        var optionals: [CoefficientOptional] = []
        if let optional = searchManager.coefficientOptionals.min(by: { $0.coefficient < $1.coefficient }) {
            optionals = [optional]
        }

        return (category, fuel, location, maintenance, owners, optionals)
    }

    // MARK: - RESIDUAL VALUE
    func calculateResidualValue(
        userCar: UserCar,
        basePrice: Double,
        yearOffset: Int,
        isOptimisticValues: Bool,
        isPessimisticValues: Bool,
        coefficients: (
            category: CoefficientCarCategory,
            fuel: CoefficientFuelType,
            location: CoefficientLocation?,
            maintenance: CoefficientMaintenance?,
            owners: CoefficientNumberOfOwners?,
            optionals: [CoefficientOptional]
        ),
        depreciationCoefficients: [CoefficientDepreciationOverYears]
    ) -> Double {

        let timeCoeff = depreciationCoefficients
            .first(where: { $0.year == yearOffset })?
            .coefficient ?? 0

        let kmCoeff = kmCoefficient(
            isOptimisticCurve: isOptimisticValues,
            isPessimisticCurve: isPessimisticValues,
            registrationYear: userCar.registrationYear,
            currentKm: userCar.actualKm,
            averageKmPerYear: coefficients.fuel.averageKmByYears
        )

        let optionalsMultiplier = coefficients.optionals
            .map { Double($0.coefficient) }
            .reduce(1.0, *)

        let coefficientCategory = Double(coefficients.category.coefficient)
        let coefficientFuel = Double(coefficients.fuel.coefficient)
        let coefficientLocation = coefficients.location.map { Double($0.coefficient) } ?? 1.0
        let coefficientMaintenance = coefficients.maintenance.map { Double($0.coefficient) } ?? 1.0
        let coefficientOwners = coefficients.owners.map { Double($0.coefficient) } ?? 1.0

        let totalMultiplier = coefficientCategory * coefficientFuel * coefficientLocation * coefficientMaintenance * coefficientOwners * optionalsMultiplier * kmCoeff

        return max(basePrice * Double(timeCoeff) * totalMultiplier, 0)
    }

    // MARK: - DATA (BASE)
    func generateDepreciationData(userCar: UserCar, basePrice: Double, years: Int = 20) -> [DepreciationPoint] {
        guard let resolved = resolveCoefficients(userCar: userCar) else { return [] }
        let startYear = userCar.registrationYear

        return (0...years).map { offset in
            let value = calculateResidualValue(
                userCar: userCar,
                basePrice: basePrice,
                yearOffset: offset,
                isOptimisticValues: false,
                isPessimisticValues: false,
                coefficients: resolved,
                depreciationCoefficients: searchManager.coefficientDepreciationOverYears
            )
            return DepreciationPoint(year: startYear + offset, value: value)
        }
    }

    // MARK: - DATA (OPTIMISTIC)
    func generateOptimisticData(userCar: UserCar, basePrice: Double, years: Int = 20) -> [DepreciationPoint] {
        guard let resolved = resolveOptimisticCoefficients(userCar: userCar) else { return [] }
        let startYear = userCar.registrationYear

        return (0...years).map { offset in
            let value = calculateResidualValue(
                userCar: userCar,
                basePrice: basePrice,
                yearOffset: offset,
                isOptimisticValues: true,
                isPessimisticValues: false,
                coefficients: resolved,
                depreciationCoefficients: searchManager.coefficientDepreciationOverYears
            )
            return DepreciationPoint(year: startYear + offset, value: value)
        }
    }

    // MARK: - DATA (PESSIMISTIC)
    func generatePessimisticData(userCar: UserCar, basePrice: Double, years: Int = 20) -> [DepreciationPoint] {
        guard let resolved = resolvePessimisticCoefficients(userCar: userCar) else { return [] }
        let startYear = userCar.registrationYear

        return (0...years).map { offset in
            let value = calculateResidualValue(
                userCar: userCar,
                basePrice: basePrice,
                yearOffset: offset,
                isOptimisticValues: false,
                isPessimisticValues: true,
                coefficients: resolved,
                depreciationCoefficients: searchManager.coefficientDepreciationOverYears
            )
            return DepreciationPoint(year: startYear + offset, value: value)
        }
    }
}
