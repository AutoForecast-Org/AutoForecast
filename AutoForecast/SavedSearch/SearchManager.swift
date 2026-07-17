//
//  SearchManager.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
class SearchManager: ObservableObject {
    @Published var savedSearches: [SavedSearch] = []
    @Published var lastSearch: SavedSearch? = nil

    private let storageKey = "savedSearches"
    private let lastKey = "lastSearch"

    @Published var isDataLoaded: Bool = false
    
    @Published var carsDataset: [Car] = []

    @Published var coefficientCarCategories: [CoefficientCarCategory] = []
    @Published var coefficientColors: [CoefficientColor] = []
    @Published var coefficientDepreciationOverYears: [CoefficientDepreciationOverYears] = []
    @Published var coefficientFuelTypes: [CoefficientFuelType] = []
    @Published var coefficientLocations: [CoefficientLocation] = []
    @Published var coefficientMaintenances: [CoefficientMaintenance] = []
    @Published var coefficientNumberOfOwners: [CoefficientNumberOfOwners] = []
    @Published var coefficientOptionals: [CoefficientOptional] = []

    private let client: SupabaseClient

    init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://mxfghxnyhrxsorxjztpz.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14ZmdoeG55aHJ4c29yeGp6dHB6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzOTczNDIsImV4cCI6MjA5ODk3MzM0Mn0.Xj5dURaQdObe5IwW2fRCF8bP0mJRGAhpqxG2VAFucyA"
        )
        load()
    }
    
    // MARK: - Cars DATASET (dedicated, not generic)
    func fetchCars(completion: @escaping (Result<[Car], Error>) -> Void) {
        Task {
            do {
                let response = try await client
                    .from("CarValues")
                    .select()
                    .execute()

                let decodedCars = try JSONDecoder().decode([Car].self, from: response.data)

                await MainActor.run {
                    self.carsDataset = decodedCars
                }

                completion(.success(decodedCars))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// - Returns: `.saved` if already saved, `.duplicate` if already exist, `.replaced` if overwritten.
    @discardableResult
    func saveSearch(_ search: SavedSearch, forceReplace: Bool = false) -> SaveResult {
        if let index = savedSearches.firstIndex(where: { $0.isDuplicate(of: search) }) {
            if forceReplace {
                savedSearches[index] = search
                lastSearch = search
                persist()
                return .replaced
            } else {
                return .duplicate
            }
        }

        if savedSearches.count >= 4 {
            savedSearches.removeFirst()
        }
        savedSearches.append(search)
        lastSearch = search
        persist()
        return .saved
    }

    func delete(_ search: SavedSearch) {
        if let index = savedSearches.firstIndex(where: { $0.id == search.id }) {
            savedSearches.remove(at: index)

            if lastSearch?.id == search.id {
                lastSearch = savedSearches.last
            }

            persist()
        }
    }

    func persist() {
        if let data = try? JSONEncoder().encode(savedSearches) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        if let data = try? JSONEncoder().encode(lastSearch) {
            UserDefaults.standard.set(data, forKey: lastKey)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        savedSearches.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SavedSearch].self, from: data) {
            self.savedSearches = decoded
        }
        if let data = UserDefaults.standard.data(forKey: lastKey),
           let decoded = try? JSONDecoder().decode(SavedSearch.self, from: data) {
            self.lastSearch = decoded
        }
    }

    enum SaveResult {
        case saved, duplicate, replaced
    }
}


extension SearchManager {
    func fetchTable<T: Decodable>(_ tableName: String, as type: T.Type) async throws -> [T] {
        let response = try await client
            .from(tableName)
            .select()
            .execute()

        return try JSONDecoder().decode([T].self, from: response.data)
    }
    
    @MainActor
    func fetchAllData() async {
        do {
            async let cars = fetchTable("CarValues", as: Car.self)
            async let categories = fetchTable("CoefficientCarCategory", as: CoefficientCarCategory.self)
            async let colors = fetchTable("CoefficientColor", as: CoefficientColor.self)
            async let depreciation = fetchTable("CoefficientDepreciationOverYears", as: CoefficientDepreciationOverYears.self)
            async let fuelTypes = fetchTable("CoefficientFuelType", as: CoefficientFuelType.self)
            async let locations = fetchTable("CoefficientLocation", as: CoefficientLocation.self)
            async let maintenances = fetchTable("CoefficientMaintenance", as: CoefficientMaintenance.self)
            async let owners = fetchTable("CoefficientNumberOfOwners", as: CoefficientNumberOfOwners.self)
            async let optionals = fetchTable("CoefficientOptional", as: CoefficientOptional.self)

            // Await ALL AT ONCE, in parallel
            self.carsDataset = try await cars
            self.coefficientCarCategories = try await categories
            self.coefficientColors = try await colors
            self.coefficientDepreciationOverYears = try await depreciation
            self.coefficientFuelTypes = try await fuelTypes
            self.coefficientLocations = try await locations
            self.coefficientMaintenances = try await maintenances
            self.coefficientNumberOfOwners = try await owners
            self.coefficientOptionals = try await optionals
            
            print("ALL coefficient tables fetched successfully")

            self.isDataLoaded = true

        } catch {
            print("Error fetching all data: \(error)")
            self.isDataLoaded = false
        }
    }
}
