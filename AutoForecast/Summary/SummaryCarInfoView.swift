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
    func infoRow(label: LocalizedStringResource, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

struct AnimatedProgressOverlay: View {
    let messages: [LocalizedStringResource]
    @State private var currentIndex = 0
    @State private var showCard = false
    @State private var breathe = false
    @State private var messageTask: Task<Void, Never>? = nil

    private let phaseDuration: Double = 2.2

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                ZStack {
                    ForEach(messages.indices, id: \.self) { index in
                        if index == currentIndex {
                            Text(messages[index])
                                .foregroundStyle(.primary)
                                .font(.headline.weight(.semibold))
                                .id(index)
                                .transition(
                                    .asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.98)).combined(with: .move(edge: .bottom)),
                                        removal: .opacity.combined(with: .scale(scale: 1.01)).combined(with: .move(edge: .top))
                                    )
                                )
                        }
                    }
                }
                .frame(height: 30)

                Text("Sto preparando la previsione")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            InfiniteLinearProgress()
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.18),
                                    ColorLayout.primary.auto.opacity(0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.1
                        )
                )
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
        )
        .shadow(color: .black.opacity(0.22), radius: 28, x: 0, y: 16)
        .shadow(color: ColorLayout.primary.auto.opacity(0.14), radius: 14, x: 0, y: 4)
        .scaleEffect(showCard ? (breathe ? 1.0 : 0.988) : 0.95)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.56, dampingFraction: 0.88), value: showCard)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: breathe)
        .onAppear {
            showCard = true
            breathe = true
            startMessageLoop()
        }
        .onDisappear {
            messageTask?.cancel()
            messageTask = nil
        }
    }

    private func startMessageLoop() {
        guard !messages.isEmpty else { return }
        messageTask?.cancel()

        messageTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(phaseDuration * 1_000_000_000))
                if Task.isCancelled { break }

                await MainActor.run {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0.2)) {
                        currentIndex = (currentIndex + 1) % messages.count
                    }
                }
            }
        }
    }
}


struct InfiniteLinearProgress: View {
    @State private var beamOffset: CGFloat = -150

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.primary.opacity(0.14))
                .frame(height: 8)

            // Single moving beam: gradient body + integrated gloss to keep everything synchronized.
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorLayout.primary.auto.opacity(0.34),
                                ColorLayout.primary.auto,
                                ColorLayout.primary.auto.opacity(0.62)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.5),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.vertical, 1)
            }
            .frame(width: 132, height: 8)
            .offset(x: beamOffset)
            .shadow(color: ColorLayout.primary.auto.opacity(0.18), radius: 2, x: 0, y: 0)
        }
        .frame(width: 250, height: 8)
        .clipped()
        .onAppear {
            withAnimation(.linear(duration: 1.35).repeatForever(autoreverses: false)) {
                beamOffset = 250
            }
        }
    }
}
