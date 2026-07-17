//
//  ForecastScreen.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ForecastScreen: View {
    
    var userCar: UserCar
    
    @EnvironmentObject var searchManager: SearchManager
    
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
    
    var body: some View {
        VStack(spacing: 20) {
            ForecastView(
                userCarForecast: UserCarForecast(
                    userCar: userCar,
                    data: generateDepreciationData(
                        userCar: userCar,
                        basePrice: resolvePurchasePrice(
                            userCar: userCar,
                            searchManager: searchManager
                        ),
                        searchManager: searchManager
                    ),
                    optimisticData: generateOptimisticData(
                        userCar: userCar,
                        basePrice: resolvePurchasePrice(
                            userCar: userCar,
                            searchManager: searchManager
                        ),
                        searchManager: searchManager
                    ),
                    pessimisticData: generatePessimisticData(
                        userCar: userCar,
                        basePrice: resolvePurchasePrice(
                            userCar: userCar,
                            searchManager: searchManager
                        ),
                        searchManager: searchManager
                    ),
                    purchasePrice: resolvePurchasePrice(
                        userCar: userCar,
                        searchManager: searchManager
                    ),
                    isExmample: false,
                    isSaved: false
                )
            )
        }
        .navigationTitle("Previsione")
        .navigationBarTitleDisplayMode(.inline)
    }

    func kmCoefficient(
        isOptimisticCurve: Bool = false,
        isPessimisticCurve: Bool = false,
        registrationYear: Int,
        currentKm: Int,
        averageKmPerYear: Int
    ) -> Double {

        if isOptimisticCurve {
            return Double (1.05)
        }
        
        if isPessimisticCurve {
            return Double (0.90)
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = max(currentYear - registrationYear, 1)

        let expectedKm = age * averageKmPerYear
        let deltaKm = currentKm - expectedKm

        let steps = Double(deltaKm) / 1000.0
        let coefficient = 1.0 - (steps * 0.003)

        // opzionale: clamp per evitare valori irreali
        return max(coefficient, 0.7)
    }
    
    func resolveCar(
        userCar: UserCar,
        searchManager: SearchManager
    ) -> [Car] {
        
        let cars = searchManager.carsDataset.filter {
            $0.brand.lowercased() == userCar.brand.lowercased() &&
            $0.model.lowercased() == userCar.model.lowercased() &&
            $0.engine.lowercased() == userCar.engine.lowercased() &&
            $0.year == userCar.registrationYear
        }
        
        if let version = userCar.version {
            var filteredCars: [Car] = []
            filteredCars = cars.filter { $0.version?.lowercased() == version.lowercased() }
            return filteredCars
        }
            
        return cars
    }
    
    func resolvePurchasePrice(
        userCar: UserCar,
        searchManager: SearchManager
    ) -> Double {
        
        let cars = resolveCar(
            userCar: userCar,
            searchManager: searchManager
        )
        
        if !cars.isEmpty {
            var averagePrice: Double = 0.0
            var sumPrice: Double = 0.0
            cars.forEach { car in
                if let price = car.price {
                    sumPrice += Double(price)
                }
            }
            averagePrice = sumPrice / Double(cars.count)
            return averagePrice
        }

        // 🔁 fallback: stesso modello, anno più vicino
        let fallback = searchManager.carsDataset
            .filter {
                $0.brand.lowercased() == userCar.brand.lowercased() &&
                $0.model.lowercased() == userCar.model.lowercased() &&
                $0.engine.lowercased() == userCar.engine.lowercased()
            }
            .min(by: {
                abs($0.year - userCar.registrationYear) <
                abs($1.year - userCar.registrationYear)
            })

        if let fallbackPrice = fallback?.price {
            return Double(fallbackPrice)
        } else {
            return Double(defaultPrice)
        }
    }
    
    // MARK: - DATA
    func generateDepreciationData(
        userCar: UserCar,
        basePrice: Double,
        searchManager: SearchManager,
        years: Int = 20
    ) -> [DepreciationPoint] {

        guard let resolved = resolveCoefficients(
            userCar: userCar,
            searchManager: searchManager
        ) else {
            return []
        }

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

            return DepreciationPoint(
                year: startYear + offset,
                value: value
            )
        }
    }
    
    func resolveCoefficients(
        userCar: UserCar,
        searchManager: SearchManager
    ) -> (
        category: CoefficientCarCategory,
        fuel: CoefficientFuelType,
        location: CoefficientLocation?,
        maintenance: CoefficientMaintenance?,
        owners: CoefficientNumberOfOwners?,
        optionals: [CoefficientOptional]
    )? {

        // 1️⃣ Car dal dataset (OBBLIGATORIO)
        let cars = resolveCar(
            userCar: userCar,
            searchManager: searchManager
        )
        
        guard cars.isEmpty == false else {
            return nil
        }
        
        let car = cars.first!

        // 2️⃣ Fuel (OBBLIGATORIO con fallback)
        let fuel = searchManager.coefficientFuelTypes.first {
            $0.fuel.lowercased() == car.fuel.lowercased()
        } ?? defaultFuel

        // 3️⃣ Categoria (OBBLIGATORIA con fallback)
        let category: CoefficientCarCategory = {
            guard let categoryKey = car.category else {
                return defaultCategory
            }

            return searchManager.coefficientCarCategories.first {
                $0.category.lowercased() == categoryKey.lowercased()
            } ?? defaultCategory
        }()

        // 4️⃣ Location (OPZIONALE)
        let location: CoefficientLocation? =
            userCar.zone.flatMap { zone in
                searchManager.coefficientLocations.first {
                    $0.location.lowercased() == zone.lowercased()
                }
            }

        // 5️⃣ Manutenzione (OPZIONALE)
        let maintenance: CoefficientMaintenance? =
            userCar.certifiedManintenance.flatMap { key in
                searchManager.coefficientMaintenances.first {
                    $0.maintenance.lowercased() == key.lowercased()
                }
            }

        // 6️⃣ Numero proprietari (OPZIONALE)
        let owners: CoefficientNumberOfOwners? =
            userCar.numberOfOwners.flatMap { value in
                searchManager.coefficientNumberOfOwners.first {
                    $0.owners == value
                }
            }

        // 7️⃣ Optionals (OPZIONALI)
        let optionals = searchManager.coefficientOptionals.filter {
            userCar.optionals.contains($0.optional)
        }

        return (
            category: category,
            fuel: fuel,
            location: location,
            maintenance: maintenance,
            owners: owners,
            optionals: optionals
        )
    }
    
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
        var coefficientLocation: Double = 1.0
        if let location = coefficients.location {
            coefficientLocation = Double(location.coefficient)
        }
        var coefficientMaintenance: Double = 1.0
        if let maintenance = coefficients.maintenance {
            coefficientMaintenance = Double(maintenance.coefficient)
        }
        var coefficientOwners: Double = 1.0
        if let owners = coefficients.owners {
            coefficientOwners = Double(owners.coefficient)
        }
        
        let totalMultiplier = coefficientCategory * coefficientFuel * coefficientLocation * coefficientMaintenance * coefficientOwners * optionalsMultiplier * kmCoeff

        let returnValue = max(
            basePrice * Double(timeCoeff) * totalMultiplier,
            0
        )
        return returnValue
    }
    
    // MARK: - OPTIMISTIC DATA
    func generateOptimisticData(
        userCar: UserCar,
        basePrice: Double,
        searchManager: SearchManager,
        years: Int = 20
    ) -> [DepreciationPoint] {

        guard let resolved = resolveOptimisticCoefficients(
            userCar: userCar,
            searchManager: searchManager
        ) else {
            return []
        }

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

            return DepreciationPoint(
                year: startYear + offset,
                value: value
            )
        }
    }
    
    func resolveOptimisticCoefficients(
        userCar: UserCar,
        searchManager: SearchManager
    ) -> (
        category: CoefficientCarCategory,
        fuel: CoefficientFuelType,
        location: CoefficientLocation?,
        maintenance: CoefficientMaintenance?,
        owners: CoefficientNumberOfOwners?,
        optionals: [CoefficientOptional]
    )? {

        // 1️⃣ Car dal dataset (OBBLIGATORIO)
        let cars = resolveCar(
            userCar: userCar,
            searchManager: searchManager
        )
        
        guard cars.isEmpty == false else {
            return nil
        }
        
        let car = cars.first!

        // 2️⃣ Fuel (OBBLIGATORIO con fallback)
        let fuel = searchManager.coefficientFuelTypes.first {
            $0.fuel.lowercased() == car.fuel.lowercased()
        } ?? defaultFuel

        // 3️⃣ Categoria (OBBLIGATORIA con fallback)
        let category: CoefficientCarCategory = {
            guard let categoryKey = car.category else {
                return defaultCategory
            }

            return searchManager.coefficientCarCategories.first {
                $0.category.lowercased() == categoryKey.lowercased()
            } ?? defaultCategory
        }()

        // 4️⃣ Location (1.03 MAX)
        let location = searchManager.coefficientLocations.max {
            $0.coefficient < $1.coefficient
        }

        // 5️⃣ Manutenzione (1.03 MAX)
        let maintenance = searchManager.coefficientMaintenances.max {
            $0.coefficient < $1.coefficient
        }

        // 6️⃣ Numero proprietari (1.02 MAX)
        let owners = searchManager.coefficientNumberOfOwners.max {
            $0.coefficient < $1.coefficient
        }

        // 7️⃣ Optionals (1.5 MAX)
        var optionals: [CoefficientOptional] = []
        let optional = searchManager.coefficientOptionals.max {
            $0.coefficient < $1.coefficient
        }
        if let optional = optional {
            optionals = [optional]
        }

        return (
            category: category,
            fuel: fuel,
            location: location,
            maintenance: maintenance,
            owners: owners,
            optionals: optionals
        )
    }

    // MARK: - PESSIMISTIC DATA
    func generatePessimisticData(
        userCar: UserCar,
        basePrice: Double,
        searchManager: SearchManager,
        years: Int = 20
    ) -> [DepreciationPoint] {

        guard let resolved = resolvePessimisticCoefficients(
            userCar: userCar,
            searchManager: searchManager
        ) else {
            return []
        }

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

            return DepreciationPoint(
                year: startYear + offset,
                value: value
            )
        }
    }
    
    func resolvePessimisticCoefficients(
        userCar: UserCar,
        searchManager: SearchManager
    ) -> (
        category: CoefficientCarCategory,
        fuel: CoefficientFuelType,
        location: CoefficientLocation?,
        maintenance: CoefficientMaintenance?,
        owners: CoefficientNumberOfOwners?,
        optionals: [CoefficientOptional]
    )? {

        // 1️⃣ Car dal dataset (OBBLIGATORIO)
        let cars = resolveCar(
            userCar: userCar,
            searchManager: searchManager
        )
        
        guard cars.isEmpty == false else {
            return nil
        }
        
        let car = cars.first!

        // 2️⃣ Fuel (OBBLIGATORIO con fallback)
        let fuel = searchManager.coefficientFuelTypes.first {
            $0.fuel.lowercased() == car.fuel.lowercased()
        } ?? defaultFuel

        // 3️⃣ Categoria (OBBLIGATORIA con fallback)
        let category: CoefficientCarCategory = {
            guard let categoryKey = car.category else {
                return defaultCategory
            }

            return searchManager.coefficientCarCategories.first {
                $0.category.lowercased() == categoryKey.lowercased()
            } ?? defaultCategory
        }()

        // 4️⃣ Location
        let location = searchManager.coefficientLocations.min {
            $0.coefficient < $1.coefficient
        }

        // 5️⃣ Manutenzione
        let maintenance = searchManager.coefficientMaintenances.min {
            $0.coefficient < $1.coefficient
        }

        // 6️⃣ Numero proprietari
        let owners = searchManager.coefficientNumberOfOwners.min {
            $0.coefficient < $1.coefficient
        }

        // 7️⃣ Optionals (1.5 MAX)
        var optionals: [CoefficientOptional] = []
        let optional = searchManager.coefficientOptionals.min {
            $0.coefficient < $1.coefficient
        }
        if let optional = optional {
            optionals = [optional]
        }

        return (
            category: category,
            fuel: fuel,
            location: location,
            maintenance: maintenance,
            owners: owners,
            optionals: optionals
        )
    }

}
