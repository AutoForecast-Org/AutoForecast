//
//  DepreciationTrend.swift
//
//  Copyright (c) 2026 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftUI

public enum DepreciationTrend {
    case growing
    case stable
    case slowDepreciation
    case fastDepreciation

    var title: String {
        switch self {
        case .growing:
            return "Incremento di valore"
        case .stable:
            return "Mantiene il valore"
        case .slowDepreciation:
            return "Svalutazione lenta"
        case .fastDepreciation:
            return "Svalutazione veloce"
        }
    }

    var description: String {
        switch self {
        case .growing:
            return "La tua auto potrebbe aumentare di valore nel tempo"
        case .stable:
            return "La tua auto mantiene bene il suo valore"
        case .slowDepreciation:
            return "La tua auto si svaluta lentamente"
        case .fastDepreciation:
            return "La tua auto si svaluta rapidamente"
        }
    }

    var systemImage: String {
        switch self {
        case .growing:
            return "arrow.up.right"
        case .stable:
            return "arrow.right"
        case .slowDepreciation:
            return "arrow.down.right"
        case .fastDepreciation:
            return "arrow.down"
        }
    }

    var color: Color {
        switch self {
        case .growing:
            return ColorLayout.green.auto
        case .stable:
            return ColorLayout.primary.auto
        case .slowDepreciation:
            return ColorLayout.orange.auto
        case .fastDepreciation:
            return ColorLayout.red.auto
        }
    }

    static func from(annualChange: Double) -> DepreciationTrend {
        switch annualChange {
        case let x where x > 0.01:
            return .growing
        case -0.01...0.01:
            return .stable
        case -0.06...(-0.01):
            return .slowDepreciation
        default:
            return .fastDepreciation
        }
    }
}
