//
//  Color+Helper.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public extension Color {
    
    init(sentence: String) {
        let hash = abs(sentence.hashValue)
        
        let red = Double((hash & 0xFF0000) >> 16) / 255.0
        let green = Double((hash & 0x00FF00) >> 8) / 255.0
        let blue = Double(hash & 0x0000FF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6: // RRGGBB
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1.0
        case 8: // AARRGGBB
            a = Double((rgb & 0xFF000000) >> 24) / 255
            r = Double((rgb & 0x00FF0000) >> 16) / 255
            g = Double((rgb & 0x0000FF00) >> 8) / 255
            b = Double(rgb & 0x000000FF) / 255
        default:
            r = 1.0; g = 0.0; b = 0.0; a = 1.0 // fallback
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
