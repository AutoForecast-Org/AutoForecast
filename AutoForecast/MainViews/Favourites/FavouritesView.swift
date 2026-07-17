//
//  FavouritesView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var searchManager: SearchManager

    private var exampleForecast = ForecastView(
        userCarForecast: UserCarForecast(
            userCar: UserCar(
                brand: "Tesla",
                model: "Model 3",
                engine: "Electric",
                registrationYear: 2021,
                actualKm: 30000,
                version: "Long Range",
                color: "Bianco",
                zone: "Nord",
                certifiedManintenance: "Certificata da casa madre",
                optionals: [],
                numberOfOwners: 1
            ),
            data: generateDepreciationData(purchasePrice: 55000),
            optimisticData: generateOptimisticData(purchasePrice: 55000),
            pessimisticData: generatePessimisticData(purchasePrice: 55000),
            purchasePrice: 65000,
            isExmample: true,
            isSaved: false
        )
    )

    var body: some View {
        VStack(spacing: 0) {

            // HEADER
            Text("Il tuo garage")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 12)

            if searchManager.savedSearches.isEmpty {
                emptyState
            } else {
                favouritesList
            }
        }
        .background(ColorLayout.appBackround.auto)
    }
    
    private var favouritesList: some View {
        List {
            ForEach(searchManager.savedSearches) { search in
                NavigationLink {
                    forecastView(for: search)
                } label: {
                    FavouritesRow(search: search)
                        .padding(.vertical, 8)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete { indexSet in
                indexSet
                    .map { searchManager.savedSearches[$0] }
                    .forEach(searchManager.delete)
            }
            .onMove { indices, newOffset in
                searchManager.move(from: indices, to: newOffset)
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("Ancora nessuna valutazione è stata effettuata")
                .font(.subheadline)
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink {
                exampleForecast
            } label: {
                Text("Guarda un esempio →")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(ColorLayout.primary.auto)
            }

            Spacer()
        }
    }
    
    private func forecastView(for search: SavedSearch) -> some View {
        ForecastView(
            userCarForecast: UserCarForecast(
                userCar: UserCar(
                    brand: search.brand,
                    model: search.model,
                    engine: search.engine,
                    registrationYear: Int(search.registrationYear),
                    actualKm: search.actualKm,
                    version: search.version,
                    color: search.color,
                    zone: search.zone,
                    certifiedManintenance: search.certifiedManintenance,
                    optionals: search.optionals,
                    numberOfOwners: search.numberOfOwners
                ),
                data: search.data,
                optimisticData: search.optimisticData,
                pessimisticData: search.pessimisticData,
                purchasePrice: search.purchasePrice,
                isExmample: false,
                isSaved: true
            )
        )
    }
}

// MARK: - Depreciation function
func generateDepreciationData(purchasePrice: Double) -> [DepreciationPoint] {
    
    let startYear = 2021
    
    return (0...20).map { offset in
        let year = startYear + offset
        let value = purchasePrice * pow(0.9, Double(offset))
        return DepreciationPoint(year: year, value: value)
    }
}

func generateOptimisticData(purchasePrice: Double) -> [DepreciationPoint] {
    let startYear = 2021
    let yearlyFactor = 0.94     // cala del 6%/anno invece del 10%
    
    return (0...20).map { offset in
        let year = startYear + offset
        let value = purchasePrice * pow(yearlyFactor, Double(offset))
        return DepreciationPoint(year: year, value: value)
    }
}

func generatePessimisticData(purchasePrice: Double) -> [DepreciationPoint] {
    let startYear = 2021
    let yearlyFactor = 0.86     // cala del 14%/anno invece del 10%
    
    return (0...20).map { offset in
        let year = startYear + offset
        let value = purchasePrice * pow(yearlyFactor, Double(offset))
        return DepreciationPoint(year: year, value: value)
    }
}

