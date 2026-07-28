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
            return "Prima le auto più simili per alimentazione, segmento, motore, anno e prezzo."
        case .closestPrice:
            return "Prima le auto con prezzo di listino più vicino alla tua."
        case .bestRetention:
            return "Prima le auto con la minore svalutazione stimata."
        }
    }

    var resultsDescription: String {
        switch self {
        case .similarityThenPrice:
            return "Ordinate per compatibilità con la tua auto."
        case .closestPrice:
            return "Ordinate per vicinanza al prezzo di listino."
        case .bestRetention:
            return "Ordinate per migliore tenuta del valore stimata."
        }
    }
}
