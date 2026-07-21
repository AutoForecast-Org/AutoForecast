//
//  AutoForecastApp.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

@main
struct AutoForecastApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("appLanguage") private var appLanguage: String = "it"
    
    var body: some Scene {
//        WindowGroup {
//            RootView()
//        }
        LaunchScreen(config: .init(
            backgroundColor: ColorLayout.primary.auto,
            logoBackgroundColor: ColorLayout.white.auto
        )) {
            Image("AutoForecastWhiteLogoAndText")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 240)
                .foregroundColor(ColorLayout.white.auto)
        } rootContent: {
            RootView()
                .environment(\.locale, .init(identifier: appLanguage))
        }
    }
    
}
