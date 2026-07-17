//
//  ColorLayout+AutoForecast.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

//public extension ColorLayout {
//
//    static let primary: Colorable = {
//        return ColorLayout(light: "#0056FF", dark: "#0D264E")
//    }()
//    
//    static let primaryDarker: Colorable = {
//        return ColorLayout(light: "#003BB3", dark: "#0A1B3B")
//    }()
//
//}

//// Example Color Palette
//public extension ColorLayout {
//    static let primary: Colorable = {
//        return ColorLayout(light: "#4281A4", dark: "#4281A4")
//    }()
//    
//    static let primaryDarker: Colorable = {
//        return ColorLayout(light: "#0A1B3B", dark: "#0A1B3B")
//    }()
//    
//    // green
//    static let secondary: Colorable = {
//        return ColorLayout(light: "#48A9A6", dark: "#48A9A6")
//    }()
//    
//    //gray
//    static let gray: Colorable = {
//        return ColorLayout(light: "#E4DFDA", dark: "#E4DFDA")
//    }()
//    
//    //ochre
//    static let ochre: Colorable = {
//        return ColorLayout(light: "#D4B483", dark: "#D4B483")
//    }()
//    
//    //red
//    static let red: Colorable = {
//        return ColorLayout(light: "#C1666B", dark: "#C1666B")
//    }()
//}


// Color Palette 1
public extension ColorLayout {

    // MARK: - Primary LIGHT Theme Colors
    /// 4059AD <- TOP ->
    /// 3D5A80
    /// 274C77
    // MARK: - PRIMARY DARK Theme Colors
    /// 6B9AC4 <- TOP ->
    /// 598392
    /// 6FA3B9
    /// 748CAB  <- TOP ->
    /// 597491
    static let primary: Colorable = {
        return ColorLayout(light: "#6B9AC4", dark: "#4059AD")
    }()

    // Light Blue
//    static let secondary: Colorable = {
//        return ColorLayout(light: "#4059AD", dark: "#6B9AC4")
//    }()
    static let secondary: Colorable = {
        return ColorLayout(light: "#6B9AC4", dark: "#6B9AC4")
    }()
    
    // blueGreen
    static let blueGreen: Colorable = {
        return ColorLayout(light: "#97D8C4", dark: "#97D8C4")
    }()
    
    static let green: Colorable = {
        return ColorLayout(light: "#588157", dark: "#588157")
    }()
    
    static let orange: Colorable = {
        return ColorLayout(light: "#E76F51", dark: "#E76F51")
    }()
    
    // Gray --> darker -->
    static let gray1: Colorable = {
        return ColorLayout(light: "#100D0E", dark: "#EFF2F1")
    }()
    
    static let grayContrast1: Colorable = {
        return ColorLayout(light: "#100D0E", dark: "#100D0E")
    }()
    
    static let gray2: Colorable = {
        return ColorLayout(light: "#D2AAD8", dark: "#D2AAD8")
    }()
    
    static let gray3: Colorable = {
        return ColorLayout(light: "#666666", dark: "#666666")
    }()
    
    //ochre
    static let ochre: Colorable = {
        return ColorLayout(light: "#97D8C4", dark: "#F4B942")
    }()
    
    //red
    static let red: Colorable = {
        return ColorLayout(light: "#bc4749", dark: "#bc4749")
    }()
    
    // white
    static let white: Colorable = {
        return ColorLayout(light: "#000000", dark: "#FFFFFF")
    }()
    
    
    // white
    static let black: Colorable = {
        return ColorLayout(light: "#000000", dark: "#000000")
    }()
    
    
    
    
    static let appBackround: Colorable = {
        return ColorLayout(light: "#000000", dark: "#F2F2F6")
    }()
    
    static let cardRowBackgroud: Colorable = {
        return ColorLayout(light: "#1C1C1E", dark: "#FFFFFF")
    }()
    
    //1C1C1E
    
//    static let cardRowValueItems: Colorable = {
//        return ColorLayout(light: "#598392", dark: "#4059AD")
//    }()
}
