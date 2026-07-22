//
//  ComparisonBadge.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

enum ComparisonBadge: String, Identifiable {
    case convenient
    case stable

    var id: String { rawValue }

    var title: String {
        switch self {
        case .convenient: return "Piu conveniente"
        case .stable: return "Piu stabile"
        }
    }

    var icon: String {
        switch self {
        case .convenient: return "eurosign.circle.fill"
        case .stable: return "waveform.path.ecg"
        }
    }

    var tint: Color {
        switch self {
        case .convenient: return ColorLayout.green.auto
        case .stable: return ColorLayout.primary.auto
        }
    }
}
