//
//  OptionalParametersView.swift
//
//  Copyright (c) 2026 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct OptionalParametersView: View {

    @Environment(\.navigate) private var navigate
    @State var userCar: UserCar

    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                OptionalInfoView(
                    selectedBrand: .constant(userCar.brand),
                    selectedModel: .constant(userCar.model),
                    selectedEngine: .constant(userCar.engine),
                    availableVersions: availableVersions,
                    selectedVersion: Binding(
                        get: { userCar.version },
                        set: { userCar.version = $0 }
                    ),
                    selectedColor: Binding(
                        get: { userCar.color },
                        set: { userCar.color = $0 }
                    ),
                    selectedZone: Binding(
                        get: { userCar.zone },
                        set: { userCar.zone = $0 }
                    ),
                    numberOfOwners: Binding(
                        get: { userCar.numberOfOwners ?? 1 },
                        set: { userCar.numberOfOwners = $0 }
                    ),
                    selectedMaintenance: Binding(
                        get: { userCar.certifiedManintenance },
                        set: { userCar.certifiedManintenance = $0 }
                    ),
                    selectedOptionals: Binding(
                        get: { userCar.optionals },
                        set: { userCar.optionals = $0 }
                    ),
                    colors: availableColors,
                    zones: availableZones,
                    ownersRange: availableOwners,
                    maintenanceOptions: availableMaintenanceOptions,
                    optionals: availableOptionals
                )
                
                Button(action: {
                    navigate.append(.summaryView(userCar))
                }) {
                    Text("LET'S GO!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorLayout.primary.auto)
                        .foregroundColor(ColorLayout.white.auto)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(ColorLayout.appBackround.auto)
        .navigationTitle("Parametri opzionali")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Computed helpers
    var availableVersions: [String] {
        searchManager.carsDataset
            .filter {
                $0.brand == userCar.brand &&
                $0.model == userCar.model &&
                $0.engine == userCar.engine &&
                $0.year == userCar.registrationYear
            }
            .compactMap { $0.version }
            .sorted()
    }

    var availableColors: [String] {
        Array(Set(searchManager.coefficientColors.map { $0.color })).sorted()
    }

    var availableZones: [String] {
        Array(Set(searchManager.coefficientLocations.map { $0.location })).sorted()
    }

    var availableOwners: ClosedRange<Int> {
        let values = searchManager.coefficientNumberOfOwners.map { $0.owners }
        return (values.min() ?? 1)...(values.max() ?? 1)
    }

    var availableMaintenanceOptions: [String] {
        Array(Set(searchManager.coefficientMaintenances.map { $0.maintenance })).sorted()
    }

    var availableOptionals: [String] {
        Array(Set(searchManager.coefficientOptionals.map { $0.optional })).sorted()
    }
}

