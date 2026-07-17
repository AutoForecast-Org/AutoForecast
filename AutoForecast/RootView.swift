//
//  RootView.swift
//
//  Copyright (c) 2026 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct RootView: View {
    @Bindable private var routeViewModel = RouteViewModel.shared
    @StateObject private var searchManager = SearchManager()

    @AppStorage("welcomeScreenAlreadyShown")
    private var welcomeScreenAlreadyShown = false

    @State private var showSplash = true

    var body: some View {
        ZStack {
            mainContent

            if showSplash {
                SplashOverlay {
                    showSplash = false
                }
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if welcomeScreenAlreadyShown {
            NavigationStack(path: $routeViewModel.navPath) {
                MainTabView()
                    .navigationDestination(for: Route.self) { route in
                        Routes(route: route)
                    }
            }
            .environment(\.navigate, routeViewModel)
            .environmentObject(searchManager)
        } else {
            WelcomeGalleryView(slides: slides)
        }
    }
}
