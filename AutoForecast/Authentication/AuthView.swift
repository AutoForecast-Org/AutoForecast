//
//  AuthView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authStore: AuthStore

    var body: some View {
        ZStack {
            WavesBackground()

            ScrollView {
                VStack(spacing: 16) {
                    
                    Spacer(minLength: 40)

                    HomeHeroMarkView()
                    
                    Spacer(minLength: 16)

                    Text("Benvenuto")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Accedi con il tuo Apple Account per sbloccare tutte le funzionalità di AutoForecast e stimare il valore futuro della tua auto, oppure guarda il report d'esempio nel Garage.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 12) {
                        SocialSignInButton(title: "Continua con Apple", icon: "apple.logo") {
                            await authStore.signInWithApple()
                        }
                    }
                    .padding(.horizontal, 32)

                    if let errorMessage = authStore.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Text("Grazie alla funzione 'Nascondi la mia email' di Apple, puoi accedere in modo totalmente anonimo senza condividere il tuo indirizzo con noi.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

//                    Spacer(minLength: 32)
                }
            }

            if authStore.isAuthenticating {
                Color.black.opacity(0.12)
                    .ignoresSafeArea()
                ProgressView("Accesso in corso…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .background(ColorLayout.appBackround.auto)
    }
}

private struct SocialSignInButton: View {
    let title: String
    let icon: String
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            Label(title, systemImage: icon)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(Color.primary)
                .background(ColorLayout.cardRowBackgroud.auto, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
//                .foregroundColor(ColorLayout.white.auto)
//                .background(ColorLayout.primary.auto, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                }
        }
        .accessibilityHint("Apre l'autenticazione con \(title.replacingOccurrences(of: "Continua con ", with: ""))")
    }
}
