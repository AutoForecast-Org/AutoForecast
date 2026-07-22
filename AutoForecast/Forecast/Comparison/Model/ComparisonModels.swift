//
//  ComparisonCandidate.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import Foundation

struct ComparisonCandidate: Identifiable {
    let id = UUID()
    let car: Car
    let virtualUserCar: UserCar
    var basePrice: Double = 0
    var data: [DepreciationPoint] = []
}
