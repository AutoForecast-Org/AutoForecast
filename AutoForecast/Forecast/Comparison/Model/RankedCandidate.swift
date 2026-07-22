//
//  RankedCandidate.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

struct RankedCandidate: Identifiable {
    let candidate: ComparisonCandidate
    let similarityScore: Double
    let priceDistance: Double
    let currentValue: Double
    let stabilityIndex: Double

    var id: UUID { candidate.id }

    var depreciationLoss: Double {
        max(candidate.basePrice - currentValue, 0)
    }

    var similarityPercent: Double {
        min(max(similarityScore / 9.0, 0), 1)
    }
}
