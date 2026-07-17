//
//  SplashView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct SplashOverlay: View {
    var onFinish: () -> Void
    
    @State private var scale: CGFloat = 1.04
    @State private var opacity: Double = 1
    
    var body: some View {
        ColorLayout.primary.auto
            .ignoresSafeArea()
            .overlay(
                Image("AutoForecastWhiteLogoAndText")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240)
                    .foregroundColor(ColorLayout.white.auto)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                
                    
            )
            .onAppear {
                withAnimation(.easeOut(duration: 0.35)) {
                    scale = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        opacity = 0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    onFinish()
                }
            }
    }
}


// MARK: - [OLD] Splash con ENTRATA E USCITA PIÚ MINIMALE
//struct SplashView: View {
//    @Bindable private var routeViewModel = RouteViewModel.shared
//    @StateObject private var searchManager = SearchManager() 
//    @AppStorage("welcomeScreenAlreadyShown") var welcomeScreenAlreadyShown = false
//
//    @State private var showSplash = true
//    @State private var logoOffset: CGFloat = 50
//    @State private var logoScale: CGFloat = 1.05
//    @State private var logoOpacity: Double = 1
//
//    var body: some View {
//        ZStack {
//            if welcomeScreenAlreadyShown {
//                NavigationStack(path: $routeViewModel.navPath) {
//                    MainTabView().navigationDestination(for: Route.self) { route in
//                        Routes(route: route)
//                    }
//                }
//                .environment(\.navigate, routeViewModel)
//                .environmentObject(searchManager)
//                
////                MainTabView()
//            } else {
//                WelcomeGalleryView(slides: slides)
//            }
//
//            if showSplash {
//                splashLayer
//            }
//        }
//    }
//
//    private var splashLayer: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    ColorLayout.primary.auto,
//                    ColorLayout.primary.auto
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            Image("AutoForecastWhiteLogoAndText")
//                .resizable()
//                .renderingMode(.template)
//                .foregroundColor(ColorLayout.white.auto)
//                .scaledToFit()
//                .frame(width: 260)
//                .offset(y: logoOffset)
//                .scaleEffect(logoScale)
//                .opacity(logoOpacity)
//        }
//        .onAppear {
//            animateEntrance()
//            animateExit()
//        }
//    }
//
//    private func animateEntrance() {
//        withAnimation(.easeOut(duration: 0.6)) {
//            logoOffset = 0
//            logoScale = 1.0
//        }
//    }
//
//    private func animateExit() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            withAnimation(.easeIn(duration: 0.35)) {
//                logoOffset = -40
//                logoOpacity = 0
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
//            showSplash = false
//        }
//    }
//}

