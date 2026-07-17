//
//  DepreciationPoint.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct DepreciationPoint: Identifiable, Codable, Equatable {
    public let id: UUID
    public let year: Int
    public let value: Double
    
    public init(id: UUID = UUID(), year: Int, value: Double) {
        self.id = id
        self.year = year
        self.value = value
    }
}

public let depreciationData: [DepreciationPoint] = [
    .init(year: 0, value: 45000),
    .init(year: 1, value: 38000),
    .init(year: 2, value: 34000),
    .init(year: 3, value: 31000),
    .init(year: 4, value: 28000),
    .init(year: 5, value: 25000),
    .init(year: 6, value: 22000),
    .init(year: 7, value: 19000),
    .init(year: 8, value: 16000),
    .init(year: 9, value: 14000),
    .init(year: 10, value: 12000)
]
