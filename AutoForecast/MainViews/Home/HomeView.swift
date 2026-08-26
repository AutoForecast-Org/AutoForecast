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
    @EnvironmentObject private var authStore: AuthStore
    @State private var isProfilePresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                WavesBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        Spacer(minLength: 40)
                        
                        HomeHeroMarkView()
                        
//                        Text("AUTOFORECAST")
//                            .font(.caption.weight(.semibold))
//                            .foregroundColor(.secondary)
//                            .tracking(4)
                        
                        Spacer(minLength: 16)
                        
                        Text("Prevedi il valore futuro della tua auto ")
//                        Text("Prevedi il valore futuro dell'auto")
                            .font(.largeTitle.weight(.bold))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Stima il valore nel tempo e gestisci le tue valutazioni in modo strutturato")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer(minLength: 16)
                        
                        HomeEvaluationButtonView(isEnabled: searchManager.isDataLoaded)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: 520)
                        
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
        .overlay(alignment: .topTrailing) {
            Button {
                isProfilePresented = true
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(ColorLayout.white.auto)
                    .padding(12)
                    .background(ColorLayout.primary.auto, in: Circle())
            }
            .accessibilityLabel("Apri profilo utente")
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .sheet(isPresented: $isProfilePresented) {
            ProfileView()
                .environmentObject(authStore)
        }
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
//private struct HomeHeaderIconVIew: View {
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(
//                    LinearGradient(colors: [
//                        ColorLayout.primary.auto,
//                        ColorLayout.primary.auto
//                    ],
//                                   startPoint: .leading,
//                                   endPoint: .trailing)
//                )
//                .frame(width: 200, height: 200)
//                .shadow(radius: 8)
//            
//            Image("AutoForecastWhiteLogoAndText")
//                .resizable()
//                .renderingMode(.template)
//                .foregroundColor(ColorLayout.white.auto)
//                .scaledToFit()
//                .frame(height: 170)
//
//        }
//    }
//}

// MARK: - HERO MARK
public struct HomeHeroMarkView: View {
    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ColorLayout.primary.auto.opacity(1.0),
                            ColorLayout.primary.auto.opacity(0.78)
                        ],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: 160
                    )
                )
                .frame(width: 214, height: 214)
                .shadow(color: ColorLayout.primary.auto.opacity(0.28), radius: 22, x: 0, y: 12)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                }

            Image("AutoForecastWhiteLogoAndText")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(ColorLayout.white.auto)
                .scaledToFit()
                .frame(width: 170)
                .padding(.horizontal, 22)
                .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 8)
        }
        .padding(.top, 4)
    }
}

// MARK: - EVALUATION BUTTON
//private struct HomeEvaluationButtonView: View {
//    var isEnabled: Bool
//    @Environment(\.navigate) private var navigate
//
//    var body: some View {
//        Button {
//            navigate.append(.parametersView)
//        } label: {
//            Label("START", systemImage: "chart.line.text.clipboard")
//                .font(.headline)
//                .foregroundColor(ColorLayout.white.auto)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(
//                    LinearGradient(colors: [
//                        ColorLayout.primary.auto,
//                        ColorLayout.primary.auto],
//                                   startPoint: .leading,
//                                   endPoint: .trailing)
//                )
//                .cornerRadius(18)
//                .shadow(radius: 8, y: 4)
//        }
//        .padding(.horizontal, 32)
//        .disabled(!isEnabled)
//        .opacity(isEnabled ? 1.0 : 0.5) // Optionally make it look disabled
//    }
//}


// MARK: - EVALUATION BUTTON
private struct HomeEvaluationButtonView: View {
    var isEnabled: Bool
    @Environment(\.navigate) private var navigate

    var body: some View {
        Button {
            guard isEnabled else { return }
            navigate.append(.parametersView)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isEnabled ? "sparkles" : "hourglass")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 2) {
//                    Text(isEnabled ? "Inizia la previsione" : "Caricamento dati...")
                    Text(isEnabled ? "Inizia la previsione" : "Caricamento dati...")
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
//                        .tracking(4)

//                    Text(isEnabled ? "Personalizza il profilo della tua auto" : "Preparazione dei dati in corso")
                    Text(isEnabled ? "Scopri la proiezione per la tua auto" : "Preparazione dei dati in corso")
                        .font(.caption)
                        .foregroundColor(ColorLayout.white.auto.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .opacity(0.95)
            }
            .foregroundColor(ColorLayout.white.auto)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        ColorLayout.primary.auto,
                        ColorLayout.primary.auto.opacity(0.84)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: ColorLayout.primary.auto.opacity(0.30), radius: 16, x: 0, y: 10)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.74)
        .padding(.horizontal, 12)
    }
}

