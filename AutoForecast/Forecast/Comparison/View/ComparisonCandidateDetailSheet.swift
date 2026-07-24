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

    private var candidateLossRatio: Double? {
        let startingPrice = rankedCandidate.candidate.basePrice
        guard startingPrice > 0 else { return nil }
        return max(candidateLoss / startingPrice, 0)
    }

    private var candidateLossPercentText: String {
        guard let ratio = candidateLossRatio else { return "-" }
        return ratio.formatted(.percent.precision(.fractionLength(1)))
    }

    private var comparisonYear: Int {
        rankedCandidate.candidate.car.year + selectedAgeOffset
    }

    private var valueLabelText: String {
        "Valore \(comparisonYear)"
    }

    private var comparisonYearText: String {
        String(comparisonYear)
    }

    private var referenceLoss: Double {
        max(referenceStartingPrice - referenceCurrentPrice, 0)
    }

    private var referenceLossRatio: Double? {
        guard referenceStartingPrice > 0 else { return nil }
        return max(referenceLoss / referenceStartingPrice, 0)
    }

    private var referenceLossPercentText: String {
        guard let ratio = referenceLossRatio else { return "-" }
        return ratio.formatted(.percent.precision(.fractionLength(1)))
    }

    private var depreciationDeltaPercentPoints: Double? {
        guard let candidate = candidateLossRatio, let reference = referenceLossRatio else { return nil }
        return (candidate - reference) * 100
    }

    private var depreciationDeltaText: String {
        guard let delta = depreciationDeltaPercentPoints else { return "-" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(delta.formatted(.number.precision(.fractionLength(1)))) p.p."
    }

    private var depreciationDeltaColor: Color {
        guard let delta = depreciationDeltaPercentPoints else { return .secondary }
        if delta > 0.1 { return ColorLayout.red.auto }
        if delta < -0.1 { return ColorLayout.green.auto }
        return .secondary
    }

    private var depreciationInsightText: String {
        guard let delta = depreciationDeltaPercentPoints else { return "Confronto non disponibile" }
        if delta > 0.1 { return "Questa auto svaluta piu della tua auto di riferimento." }
        if delta < -0.1 { return "Questa auto svaluta meno della tua auto di riferimento." }
        return "Svalutazione in linea con la tua auto di riferimento."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(candidateTitle)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(candidateVersion)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Anno di riferimento: \(comparisonYearText) (eta veicolo: \(selectedAgeOffset) anni)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if !badges.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(badges) { badge in
                                        BadgeChip(badge: badge)
                                    }
                                }
                            }

                            Divider()

                            HStack(spacing: 10) {
                                MetricBox(title: "Listino", value: rankedCandidate.candidate.basePrice.euroString)
                                MetricBox(title: valueLabelText, value: rankedCandidate.currentValue.euroString)
                                MetricBox(title: "Perdita", value: candidateLossPercentText, tint: ColorLayout.red.auto)
                            }
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Confronto svalutazione")
                                .font(.headline)
                            
                            Text(referenceTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)

                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Candidata")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    comparisonLine(
                                        title: "% svalutazione",
                                        value: candidateLossPercentText
                                    )
                                    comparisonLine(
                                        title: "Perdita",
                                        value: candidateLoss.euroString
                                    )
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Riferimento")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    comparisonLine(
                                        title: "% svalutazione",
                                        value: referenceLossPercentText
                                    )
                                    comparisonLine(
                                        title: "Perdita",
                                        value: referenceLoss.euroString
                                    )
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider()

                            comparisonLine(
                                title: "Differenza",
                                value: depreciationDeltaText,
                                valueColor: depreciationDeltaColor
                            )

                            Text(depreciationInsightText)
                                .font(.caption)
                                .foregroundColor(depreciationDeltaColor)
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

    private func comparisonLine(title: String, value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}
