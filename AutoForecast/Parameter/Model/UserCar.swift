//
//  UserCar.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

struct UserCar: Hashable{
    var brand: String
    var model: String
    var engine: String
    var registrationYear: Int
    var actualKm: Int
    // NOT MANDATORY
    var version: String?
    var color: String?
    var zone: String?
    var certifiedManintenance: String?
    var optionals: [String]
    var numberOfOwners: Int?
}

struct UserCarForecast {
    var userCar: UserCar
    // OTHER DATA
    var data: [DepreciationPoint]
    var optimisticData: [DepreciationPoint]
    var pessimisticData: [DepreciationPoint]
    var purchasePrice: Double
    var isExmample: Bool
    var isSaved: Bool
}
