//
//  MainTabView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            // 1. HOME
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // 2. PREFERITI
            FavouritesView()
                .tabItem {
                    Label("Garage", systemImage: "door.garage.closed")
                }
            
            // 3. IMPOSTAZIONI
            SettingsView()
                .tabItem {
                    Label("Impostazioni", systemImage: "gearshape.fill")
                }
        }
        .accentColor(ColorLayout.primary.auto)
    }
}


