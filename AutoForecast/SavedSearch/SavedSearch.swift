//
//  SavedSearch.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import Foundation

struct SavedSearch: Identifiable, Codable, Equatable {
    let id: UUID
    let brand: String
    let model: String
    let engine: String
    let registrationYear: Int
    let actualKm: Int
    // NOT MANDATORY
    let version: String?
    let color: String?
    let zone: String?
    let certifiedManintenance: String?
    let optionals: [String]
    let numberOfOwners: Int?
    let purchasePrice: Double
    let data: [DepreciationPoint]
    let optimisticData: [DepreciationPoint]
    let pessimisticData: [DepreciationPoint]
    let createdAt: Date
    
    init(brand: String,
         model: String,
         engine: String,
         registrationYear: Int,
         actualKm: Int,
         // NOT MANDATORY
         version: String?,
         color: String?,
         zone: String?,
         certifiedManintenance: String?,
         optionals: [String],
         numberOfOwners: Int,
         purchasePrice: Double,
         data: [DepreciationPoint],
         optmisticData: [DepreciationPoint],
         pessimisticData: [DepreciationPoint]
    ) {
        self.id = UUID()
        self.brand = brand
        self.model = model
        self.engine = engine
        self.registrationYear = registrationYear
        self.actualKm = actualKm
        self.version = version
        self.color = color
        self.zone = zone
        self.certifiedManintenance = certifiedManintenance
        self.optionals = optionals
        self.numberOfOwners = numberOfOwners
        self.purchasePrice = purchasePrice
        self.data = data
        self.optimisticData = optmisticData
        self.pessimisticData = pessimisticData
        self.createdAt = Date()
    }
}

extension SavedSearch {
    func isDuplicate(of other: SavedSearch) -> Bool {
        return brand == other.brand &&
        model == other.model &&
        engine == other.engine &&
        registrationYear == other.registrationYear &&
        actualKm == other.actualKm &&
        version == other.version &&
        color == other.color &&
        zone == other.zone &&
        certifiedManintenance == other.certifiedManintenance &&
        optionals == other.optionals &&
        numberOfOwners == other.numberOfOwners &&
        purchasePrice == other.purchasePrice
    }
}
