//
//  ComparisonCandidateDetailSheet.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ComparisonCandidateDetailSheet: View {
    let rankedCandidate: RankedCandidate
    let badges: [ComparisonBadge]
    let selectedAgeOffset: Int
    let referenceTitle: String
    let referenceStartingPrice: Double
    let referenceCurrentPrice: Double

    private var candidateTitle: String {
        "\(rankedCandidate.candidate.car.brand) \(rankedCandidate.candidate.car.model)"
    }

    private var candidateVersion: String {
        let raw = (rankedCandidate.candidate.car.version ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return raw.isEmpty ? "Versione non disponibile" : raw
    }

    private var candidateLoss: Double {
        rankedCandidate.depreciationLoss
    }

    private var referenceLoss: Double {
        max(referenceStartingPrice - referenceCurrentPrice, 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(candidateTitle)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(candidateVersion)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if !badges.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(badges) { badge in
                                        BadgeChip(badge: badge)
                                    }
                                }
                            }
                        }
                    }

                    SectionCard {
                        HStack(spacing: 10) {
                            MetricBox(title: "Listino", value: rankedCandidate.candidate.basePrice.euroString)
                            MetricBox(title: "Valore (\(selectedAgeOffset)a)", value: rankedCandidate.currentValue.euroString)
                            MetricBox(title: "Perdita", value: candidateLoss.euroString, tint: ColorLayout.red.auto)
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Punteggio confronto")
                                .font(.headline)

                            comparisonLine(
                                title: "Pertinenza",
                                value: rankedCandidate.similarityPercent.percentString
                            )
                            comparisonLine(
                                title: "Distanza prezzo",
                                value: rankedCandidate.priceDistance.euroString
                            )
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Curva svalutazione")
                                .font(.headline)

                            DepreciationSparkline(
                                points: rankedCandidate.candidate.data,
                                selectedAgeOffset: selectedAgeOffset,
                                registrationYear: rankedCandidate.candidate.car.year
                            )
                            .frame(height: 70)

                            Text("Indicatore rapido: andamento storico del valore stimato.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(ColorLayout.appBackround.auto.ignoresSafeArea())
            .navigationTitle("Dettaglio confronto")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func comparisonLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}
