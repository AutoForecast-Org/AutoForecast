//
//  HomeView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var searchManager: SearchManager
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                WavesBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        Spacer(minLength: 40)
                        
                        HomeHeaderIconVIew()
                        
                        Spacer(minLength: 50)
                        
                        Text("PREVISIONE DEL VALORE FUTURO DELL'AUTO")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Stima il valore nel tempo e gestisci le tue valutazioni in modo strutturato")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer(minLength: 50)
                        
                        HomeEvaluationButtonView(isEnabled: searchManager.isDataLoaded)
                        
                        Text("Basato su modelli di svalutazione e algoritmi di apprendimento automatico")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
            }
        }
        .background(ColorLayout.appBackround.auto)
        .navigationBarHidden(true)
        .onAppear {
            // Fetch only once
            if !searchManager.isDataLoaded {
                Task {
                    await searchManager.fetchAllData()
                }
            }
            
        }
    }
}

//struct HomeWavesAndHeaderSection: View {
//    var body: some View {
//        ZStack {
//            WavesBackground()
//            
//            VStack(spacing: 24) {
//                HomeHeaderIconVIew()
//                
//                Text("Auto Forecast")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//            }
//        }
//    }
//}

//struct HomeContentSection: View {
//    var isStartEnabled: Bool
//    
//    var body: some View {
//        VStack(spacing: 24) {
//            Text("PREVISIONE DEL VALORE FUTURO DELL'AUTO")
//                .font(.title)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            
//            Text("Stima il valore nel tempo e gestisci le tue valutazioni in modo strutturato")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 32)
//            
//            HomeEvaluationButtonView(isEnabled: isStartEnabled)
//            
//            Text("Basato su modelli di svalutazione e algoritmi di apprendimento automatico")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 32)
//            Spacer()
//        }
//    }
//}

// MARK: - HEADER ICON
private struct HomeHeaderIconVIew: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: [
                        ColorLayout.primary.auto,
                        ColorLayout.primary.auto
                    ],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .frame(width: 200, height: 200)
                .shadow(radius: 8)
            
            Image("AutoForecastWhiteLogoAndText")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(ColorLayout.white.auto)
                .scaledToFit()
                .frame(height: 170)

        }
    }
}

// MARK: - EVALUATION BUTTON
private struct HomeEvaluationButtonView: View {
    var isEnabled: Bool
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        Button {
            navigate.append(.parametersView)
        } label: {
            Label("START", systemImage: "chart.line.text.clipboard")
                .font(.headline)
                .foregroundColor(ColorLayout.white.auto)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [
                        ColorLayout.primary.auto,
                        ColorLayout.primary.auto],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .cornerRadius(18)
                .shadow(radius: 8, y: 4)
        }
        .padding(.horizontal, 32)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5) // Optionally make it look disabled
    }
}




