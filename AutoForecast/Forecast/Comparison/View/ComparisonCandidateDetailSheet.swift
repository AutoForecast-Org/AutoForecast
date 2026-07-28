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
    @Environment(\.dismiss) private var dismiss
    let selectedAgeOffset: Int
    let referenceTitle: String
    let referenceVersion: String?
    let referenceFuel: String?
    let referenceEngine: String
    let referenceRegistrationYear: Int
    let referenceStartingPrice: Double
    let referenceCurrentPrice: Double
    let referencePoints: [DepreciationPoint]

    private var candidateTitle: String {
        "\(rankedCandidate.candidate.car.brand) \(rankedCandidate.candidate.car.model)"
    }

    private var candidateVersion: String {
        let raw = (rankedCandidate.candidate.car.version ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return raw.isEmpty ? "Versione non disponibile" : raw
    }

    private var referenceVersionText: String {
        let raw = (referenceVersion ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return raw.isEmpty ? "Versione non disponibile" : raw
    }

    private var candidateValueChange: Double {
        rankedCandidate.currentValue - rankedCandidate.candidate.basePrice
    }

    private var candidateValueChangeRatio: Double? {
        let startingPrice = rankedCandidate.candidate.basePrice
        guard startingPrice > 0 else { return nil }
        return candidateValueChange / startingPrice
    }

    private var candidateValueChangePercentText: String {
        signedPercentText(candidateValueChangeRatio)
    }

    private var comparisonYear: Int {
        rankedCandidate.candidate.car.year + selectedAgeOffset
    }

    private var comparisonYearText: String {
        String(comparisonYear)
    }

    private var referenceComparisonYear: Int {
        referenceRegistrationYear + selectedAgeOffset
    }

    private var referenceValueChange: Double {
        referenceCurrentPrice - referenceStartingPrice
    }

    private var referenceValueChangeRatio: Double? {
        guard referenceStartingPrice > 0 else { return nil }
        return referenceValueChange / referenceStartingPrice
    }

    private var referenceValueChangePercentText: String {
        signedPercentText(referenceValueChangeRatio)
    }

    private var retentionDeltaPercentPoints: Double? {
        guard let candidate = candidateValueChangeRatio, let reference = referenceValueChangeRatio else { return nil }
        return (candidate - reference) * 100
    }

    private var retentionComparisonState: RetentionComparisonState {
        guard let delta = retentionDeltaPercentPoints, delta.isFinite else {
            return .insufficientData
        }
        if delta > 0.1 { return .candidateWins(deltaPercentPoints: delta) }
        if delta < -0.1 { return .referenceWins(deltaPercentPoints: abs(delta)) }
        return .tie
    }

    private var retentionWinner: RetentionWinner? {
        switch retentionComparisonState {
        case .candidateWins:
            return .candidate
        case .referenceWins:
            return .reference
        case .tie, .insufficientData:
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Confronto")
                                .font(.headline)
                            Spacer()
                            Text("A \(selectedAgeOffset) anni")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(alignment: .top, spacing: 10) {
                            vehicleColumn(
                                role: "COMPETITOR",
                                title: candidateTitle,
                                version: candidateVersion,
                                fuel: rankedCandidate.candidate.car.fuel,
                                engine: rankedCandidate.candidate.car.engine,
                                registrationYear: rankedCandidate.candidate.car.year,
                                comparisonYear: comparisonYear,
                                startingPrice: rankedCandidate.candidate.basePrice,
                                currentPrice: rankedCandidate.currentValue,
                                change: candidateValueChange,
                                changePercent: candidateValueChangePercentText,
                                accent: ColorLayout.ochre.auto,
                                isWinner: retentionWinner == .candidate
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 6) {
                                Text("VS")
                                    .font(.caption2.weight(.black))
                                    .foregroundColor(.secondary)
                                    .padding(7)
                                    .background(Color.secondary.opacity(0.12), in: Circle())

                                Rectangle()
                                    .fill(Color.secondary.opacity(0.20))
                                    .frame(width: 1)
                                    .frame(maxHeight: .infinity)
                            }

                            vehicleColumn(
                                role: "LA TUA AUTO",
                                title: referenceTitle,
                                version: referenceVersionText,
                                fuel: referenceFuel,
                                engine: referenceEngine,
                                registrationYear: referenceRegistrationYear,
                                comparisonYear: referenceComparisonYear,
                                startingPrice: referenceStartingPrice,
                                currentPrice: referenceCurrentPrice,
                                change: referenceValueChange,
                                changePercent: referenceValueChangePercentText,
                                accent: ColorLayout.primary.auto,
                                isWinner: retentionWinner == .reference
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Divider()
                        .padding(.top, 16)

                    retentionSummary
                        .padding(.vertical, 16)

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Andamento a confronto")
                            .font(.headline)

                        HStack(spacing: 12) {
                            chartLegend(title: "La tua auto", color: ColorLayout.primary.auto)
                            chartLegend(title: "Competitor", color: ColorLayout.ochre.auto)
                        }

                        DepreciationComparisonSparkline(
                            referencePoints: referencePoints,
                            referenceRegistrationYear: referenceRegistrationYear,
                            candidatePoints: rankedCandidate.candidate.data,
                            candidateRegistrationYear: rankedCandidate.candidate.car.year,
                            selectedAgeOffset: selectedAgeOffset,
                            referenceColor: ColorLayout.primary.auto,
                            candidateColor: ColorLayout.ochre.auto
                        )
                        .frame(height: 130)

                        Text("Valori stimati alla stessa età del veicolo. I punti evidenziano l'anno selezionato.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(ColorLayout.cardRowBackgroud.auto.ignoresSafeArea())
            .navigationTitle("Dettaglio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi", systemImage: "xmark") {
                        dismiss()
                    }
                    .accessibilityLabel("Chiudi dettaglio confronto")
                }
            }
        }
    }

    @ViewBuilder
    private var retentionSummary: some View {
        switch retentionComparisonState {
        case .candidateWins(let delta):
            retentionSummaryContent(
                title: "\(candidateTitle) mantiene meglio il valore",
                detail: "Rispetto al listino, ha una tenuta superiore di \(percentPointsText(delta)) rispetto a \(referenceTitle)."
            )
        case .referenceWins(let delta):
            retentionSummaryContent(
                title: "\(referenceTitle) mantiene meglio il valore",
                detail: "Rispetto al listino, ha una tenuta superiore di \(percentPointsText(delta)) rispetto a \(candidateTitle)."
            )
        case .tie:
            retentionSummaryContent(
                title: "Le due auto mantengono il valore in modo simile",
                detail: "La differenza stimata è inferiore a 0,1 punti percentuali."
            )
        case .insufficientData:
            retentionSummaryContent(
                title: "Confronto della tenuta non disponibile",
                detail: "Servono prezzo iniziale e valore stimato validi per entrambe le auto."
            )
        }
    }

    private func retentionSummaryContent(
        title: String,
        detail: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TENUTA DEL VALORE")
                .font(.caption2.weight(.bold))
                .foregroundColor(.secondary)
   
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func vehicleColumn(
        role: String,
        title: String,
        version: String,
        fuel: String?,
        engine: String,
        registrationYear: Int,
        comparisonYear: Int,
        startingPrice: Double,
        currentPrice: Double,
        change: Double,
        changePercent: String,
        accent: Color,
        isWinner: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(role)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(accent)

                if isWinner {
                    Image(systemName: "trophy.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(ColorLayout.green.auto)
                        .accessibilityLabel("Vincitore per tenuta del valore")
                }
            }
            Text(title)
                .font(.subheadline.weight(.bold))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            Text(version)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)

            vehicleSpecification(icon: "fuelpump.fill", value: fuel, fallback: "Alimentazione N/D")
            vehicleSpecification(icon: "gearshape.2.fill", value: engine, fallback: "Motore N/D")

            Text("\(registrationYear) → \(comparisonYear)")
                .font(.caption2)
                .foregroundColor(.secondary)

            compactMetric(title: "Listino", value: startingPrice.euroString)
            compactMetric(title: "Valore stimato", value: currentPrice.euroString, valueColor: accent)
            compactMetric(title: "% svalutazione", value: changePercent, valueColor: valueChangeColor(change))
            compactMetric(title: "Scostamento dal listino", value: change.signedEuroString, valueColor: valueChangeColor(change))
        }
        .padding(8)
        .background {
            if isWinner {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(ColorLayout.green.auto.opacity(0.10))
            }
        }
        .overlay {
            if isWinner {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ColorLayout.green.auto.opacity(0.45), lineWidth: 1)
            }
        }
    }

    private func vehicleSpecification(icon: String, value: String?, fallback: String) -> some View {
        let text = value?.trimmingCharacters(in: .whitespacesAndNewlines)

        return Label(text?.isEmpty == false ? text! : fallback, systemImage: icon)
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(2)
    }

    private func compactMetric(title: String, value: String, valueColor: Color = .primary) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private func chartLegend(title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func valueChangeColor(_ change: Double) -> Color {
        if change > 0.01 { return ColorLayout.green.auto }
        if change < -0.01 { return ColorLayout.red.auto }
        return .secondary
    }

    private func signedPercentText(_ ratio: Double?) -> String {
        guard let ratio else { return "-" }
        return signedNumberText(ratio * 100, suffix: "%")
    }

    private func percentPointsText(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) punti percentuali"
    }

    private func signedNumberText(_ value: Double, suffix: String) -> String {
        let sign = value >= 0 ? "+" : "-"
        return "\(sign)\(abs(value).formatted(.number.precision(.fractionLength(1))))\(suffix)"
    }
}

private enum RetentionComparisonState {
    case candidateWins(deltaPercentPoints: Double)
    case referenceWins(deltaPercentPoints: Double)
    case tie
    case insufficientData
}

private enum RetentionWinner: Equatable {
    case candidate
    case reference
}
