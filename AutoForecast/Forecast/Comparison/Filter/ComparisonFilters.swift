//
//  ComparisonFilters.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//


struct ComparisonFilters: Equatable {
    var maxRegistrationYearDelta: Int? = nil
    var zone: String? = nil
    var numberOfOwners: Int? = nil
}

struct ComparisonResult {
    var candidates: [ComparisonCandidate]
}
