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

    private var retentionDeltaText: String {
        guard let delta = retentionDeltaPercentPoints else { return "-" }
        return signedNumberText(delta, suffix: " p.p.")
    }

    private var retentionDeltaColor: Color {
        guard let delta = retentionDeltaPercentPoints else { return .secondary }
        if delta > 0.1 { return ColorLayout.green.auto }
        if delta < -0.1 { return ColorLayout.red.auto }
        return .secondary
    }

    private var retentionWinner: RetentionWinner? {
        guard let delta = retentionDeltaPercentPoints else { return nil }
        if delta > 0.1 { return .candidate }
        if delta < -0.1 { return .reference }
        return nil
    }

    private var retentionInsightText: String {
        guard let delta = retentionDeltaPercentPoints else { return "Non ci sono dati sufficienti per stabilire quale auto mantenga meglio il valore." }
        if delta > 0.1 { return "La candidata mantiene meglio il valore della tua auto di riferimento." }
        if delta < -0.1 { return "La tua auto di riferimento mantiene meglio il valore della candidata." }
        return "Le due auto mantengono il valore in modo molto simile."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionCard(
                        contentPadding: EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 12),
                        horizontalMargin: 0
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Confronto valore")
                                .font(.headline)
                                Spacer()
                                Text("A \(selectedAgeOffset) anni")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            HStack(alignment: .top, spacing: 10) {
                                vehicleColumn(
                                    role: "CANDIDATA",
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
                                    isRetentionWinner: retentionWinner == .candidate
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
                                    isRetentionWinner: retentionWinner == .reference
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider()

                            comparisonLine(
                                title: "Differenza mantenimento valore",
                                value: retentionDeltaText,
                                valueColor: retentionDeltaColor
                            )

                            Text(retentionInsightText)
                                .font(.caption)
                                .foregroundColor(retentionDeltaColor)
                        }
                    }

                    SectionCard(
                        contentPadding: EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 12),
                        horizontalMargin: 0
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Andamento a confronto")
                                .font(.headline)

                            HStack(spacing: 12) {
                                chartLegend(title: "La tua auto", color: ColorLayout.primary.auto)
                                chartLegend(title: "Candidata", color: ColorLayout.ochre.auto)
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
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 12)
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
        isRetentionWinner: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(role)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(accent)

                Image(systemName: "trophy.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(ColorLayout.green.auto)
                    .frame(width: 12)
                    .opacity(isRetentionWinner ? 1 : 0)
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
            if isRetentionWinner {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(ColorLayout.green.auto.opacity(0.10))
            }
        }
        .overlay {
            if isRetentionWinner {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ColorLayout.green.auto.opacity(0.45), lineWidth: 1.5)
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

    private func signedNumberText(_ value: Double, suffix: String) -> String {
        let sign = value >= 0 ? "+" : "-"
        return "\(sign)\(abs(value).formatted(.number.precision(.fractionLength(1))))\(suffix)"
    }
}

private enum RetentionWinner {
    case candidate
    case reference
}
