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

import Foundation

enum ComparisonSortMode: String, CaseIterable, Identifiable {
    case similarityThenPrice
    case closestPrice
    case bestRetention

    var id: String { rawValue }

    var label: String {
        switch self {
        case .similarityThenPrice: return AppLocalization.string("Pertinenza")
        case .closestPrice: return AppLocalization.string("Prezzo")
        case .bestRetention: return AppLocalization.string("Tenuta")
        }
    }

    var helperText: String {
        switch self {
        case .similarityThenPrice:
            return AppLocalization.string("Prima le auto più simili per alimentazione, segmento, motore, anno e prezzo.")
        case .closestPrice:
            return AppLocalization.string("Prima le auto con prezzo di listino più vicino alla tua.")
        case .bestRetention:
            return AppLocalization.string("Prima le auto con la minore svalutazione stimata.")
        }
    }

    var resultsDescription: String {
        switch self {
        case .similarityThenPrice:
            return AppLocalization.string("Ordinate per compatibilità con la tua auto.")
        case .closestPrice:
            return AppLocalization.string("Ordinate per vicinanza al prezzo di listino.")
        case .bestRetention:
            return AppLocalization.string("Ordinate per migliore tenuta del valore stimata.")
        }
    }
}
