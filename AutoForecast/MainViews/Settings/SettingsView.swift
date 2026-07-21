//
//  SettingsView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("appTheme") private var appTheme: ThemeOption = .system
    @AppStorage("appLanguage") private var appLanguage: String = "it"
    
    @State private var showEnglishComingSoon = false
    
    var body: some View {
        VStack {
            Text("Impostazioni")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 24)
                .background(ColorLayout.appBackround.auto)
            
            Form {
                // MARK: - Aspetto
                Section(header: Text("Aspetto")) {
                    Picker("Tema", selection: $appTheme) {
                        Text("Automatico").tag(ThemeOption.system)
                        Text("Chiaro").tag(ThemeOption.light)
                        Text("Scuro").tag(ThemeOption.dark)
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - Generale
                Section(header: Text("Generale")) {
                    Picker("Lingua", selection: $appLanguage) {
                        Text("Italiano").tag("it")
                        Text("English").tag("en")
                    }
                    .onChange(of: appLanguage) { oldValue, newValue in
                        if newValue == "en" {
                            showEnglishComingSoon = true
                        }
                    }
                }

                // MARK: - Supporto
                Section(header: Text("Supporto")) {
                    NavigationLink {
                        FAQView()
                    } label: {
                        Label("FAQ / Centro assistenza", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        Label("Invia feedback", systemImage: "envelope")
                    }
                }
                
                // MARK: - Info App
                Section(header: Text("Informazioni sull'applicazione")) {
                    HStack {
                        Text("Versione")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.buildNumber)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Impostazioni")
        }
        .background(ColorLayout.appBackround.auto)
        .preferredColorScheme(appTheme.colorScheme)
        .alert("Language Notice", isPresented: $showEnglishComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The English translation is currently work in progress and may contain minor errors. We are actively working to improve it.")
        }
    }
}

// MARK: - ThemeOption
enum ThemeOption: String, Codable, CaseIterable {
    case system, light, dark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark:  return .dark
        }
    }
}

// MARK: - Helpers
extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

