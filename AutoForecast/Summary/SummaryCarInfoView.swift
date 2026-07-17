//
//  SummaryCarInfoView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct SummaryCarInfoView: View {

    @Environment(\.navigate) private var navigate

    @State private var showProgressOverlay = false
    @State private var progressMessage = "1/2 Recupero le informazioni"
    
    let userCar: UserCar

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Dati Auto")) {
                    infoRow(label: "Brand", value: userCar.brand)
                    infoRow(label: "Modello", value: userCar.model)
                    infoRow(label: "Motore", value: userCar.engine)
                    infoRow(label: "Anno di 1° immatricolazione", value: "\(userCar.registrationYear)")
                    infoRow(label: "Km attuali", value: "\(userCar.actualKm)")
                }

                Section(header: Text("Parametri opzionali")) {
                    infoRow(label: "Versione", value: userCar.version ?? "")
                    infoRow(label: "Colore", value: userCar.color ?? "-")
                    infoRow(label: "Zona", value: userCar.zone ?? "-")
                    infoRow(label: "Manutenzione", value: userCar.certifiedManintenance ?? "-")
                    infoRow(label: "Optionals", value: userCar.optionals.isEmpty ? "-" : userCar.optionals.joined(separator: ", "))
                    infoRow(label: "Numero proprietari", value: userCar.numberOfOwners != nil ? "\(userCar.numberOfOwners!)" : "-")
                }

                Button("CALCOLA") {
                    showProgressOverlay = true
                    progressMessage = "1/2 Recupero le informazioni"

                    // Step 1 → Change message after 2.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        progressMessage = "2/2 Elaborazione..."
                    }

                    // Step 2 → Go to the screen after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showProgressOverlay = false
                        navigate.append(.forecastScreen(userCar))
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(ColorLayout.primary.auto)
            }
            .disabled(showProgressOverlay) // Disabled interaction under overlay
            .blur(radius: showProgressOverlay ? 3 : 0)
            
            if showProgressOverlay {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                AnimatedProgressOverlay(messages: [
                    "Analizzo",
                    "Elaboro dati",
                    "Recupero informazioni"
                ])
            }
        }
        .navigationTitle("Riepilogo")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Reusable row builder
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

struct AnimatedProgressOverlay: View {
    let messages: [String]
    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: 20) {

            ZStack {
                ForEach(messages.indices, id: \.self) { index in
                    if index == currentIndex {
                        Text(messages[index])
                            .foregroundColor(.primary)
                            .font(.headline)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .frame(height: 30)

            InfiniteLinearProgress()
        }
        .padding(40)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 10)
        .onAppear {
            startMessageLoop()
        }
    }

    private func startMessageLoop() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                currentIndex = (currentIndex + 1) % messages.count
            }
        }
    }
}


struct InfiniteLinearProgress: View {
    @State private var offset: CGFloat = -100

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 6)
                .overlay(
                    Capsule()
                        .fill(ColorLayout.primary.auto)
                        .frame(width: 100, height: 6)
                        .offset(x: offset)
                        .animation(
                            Animation.linear(duration: 1.2)
                                .repeatForever(autoreverses: false),
                            value: offset
                        )
                )
                .clipped()
        }
        .frame(width: 250, height: 6)
        .onAppear {
            offset = 250
        }
    }
}

