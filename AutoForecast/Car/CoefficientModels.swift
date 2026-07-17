//
//  CoefficientModels.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

struct CoefficientCarCategory: Codable, Identifiable {
    var id: Int?
    let category: String
    let description: String
    let length: String
    let coefficient: Float
}

struct CoefficientColor: Codable, Identifiable {
    var id: Int?
    let color: String
    let coefficient: Float
}

struct CoefficientDepreciationOverYears: Codable, Identifiable {
    var id: Int?
    let year: Int
    let coefficient: Float
}

struct CoefficientFuelType: Codable, Identifiable {
    var id: Int?
    let fuel: String
    let description: String
    let averageKmByYears: Int
    let coefficient: Float
}

struct CoefficientLocation: Codable, Identifiable {
    var id: Int?
    let location: String
    let coefficient: Float
}

struct CoefficientMaintenance: Codable, Identifiable {
    var id: Int?
    let maintenance: String
    let coefficient: Float
}

struct CoefficientNumberOfOwners: Codable, Identifiable {
    var id: Int?
    let owners: Int
    let coefficient: Float
}

struct CoefficientOptional: Codable, Identifiable {
    var id: Int?
    let optional: String
    let coefficient: Float
}
