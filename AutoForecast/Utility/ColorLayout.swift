//
//  ColorLayourt.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

import SwiftUI

public protocol Colorable {
    var light: Color { get set }
    var dark: Color { get set }
    var auto: Color { get }
    var autoInverted: Color { get }
}

public struct ColorLayout: Colorable {
    
    public var light: Color
    public var dark: Color
    
    
    public var auto: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .light
            ? UIColor(self.dark)
            : UIColor(self.light)
        })
    }
    
    
    public var autoInverted: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .light
            ? UIColor(self.light)
            : UIColor(self.dark)
        })
    }
    
    public init(light: String, dark: String) {
        self.light = Color(hex: light)
        self.dark = Color(hex: dark)
    }
}

public struct AdaptiveColor: View {
    let light: Color
    let dark: Color
    
    @Environment(\.colorScheme) private var scheme
    
    public var body: some View {
        (scheme == .light ? light : dark)
    }
    
    public init(light: Color, dark: Color) {
        self.light = light
        self.dark = dark
    }
}
