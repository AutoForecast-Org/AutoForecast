//
//  ComparisonSortMode.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

enum ComparisonSortMode: String, CaseIterable, Identifiable {
    case similarityThenPrice
    case closestPrice
    case bestRetention

    var id: String { rawValue }

    var label: String {
        switch self {
        case .similarityThenPrice: return "Pertinenza"
        case .closestPrice: return "Prezzo"
        case .bestRetention: return "Tenuta"
        }
    }

    var helperText: String {
        switch self {
        case .similarityThenPrice:
            return "Priorita a somiglianza (fuel/segmento/motore), poi prezzo vicino."
        case .closestPrice:
            return "Mostra prima i modelli piu vicini al prezzo di acquisto."
        case .bestRetention:
            return "Mostra prima i modelli con minore perdita di valore stimata."
        }
    }
}
