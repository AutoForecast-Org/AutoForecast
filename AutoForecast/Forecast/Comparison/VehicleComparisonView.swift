//
//  VehicleComparisonView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct VehicleComparisonView: View {
    let referenceForecast: UserCarForecast
    @EnvironmentObject var searchManager: SearchManager

    @State private var selectedAgeOffset: Int = 0
    @State private var filters = ComparisonFilters()
    @State private var result: ComparisonResult?
    @State private var selectedCandidate: RankedCandidate?
    @State private var sortMode: ComparisonSortMode = .similarityThenPrice

    private var engine: DepreciationEngine { DepreciationEngine(searchManager: searchManager) }

    private var referenceResolvedCar: Car? {
        engine.resolveCar(userCar: referenceForecast.userCar).first
    }

    private var referenceCurrentValue: Double {
        valueAtSelectedAge(
            referenceForecast.data,
            registrationYear: referenceForecast.userCar.registrationYear
        )
    }

    private var rankedCandidates: [RankedCandidate] {
        let ranked = (result?.candidates ?? []).map(rankCandidate)

        switch sortMode {
        case .similarityThenPrice:
            return ranked.sorted {
                if $0.similarityScore == $1.similarityScore {
                    return $0.priceDistance < $1.priceDistance
                }
                return $0.similarityScore > $1.similarityScore
            }
        case .closestPrice:
            return ranked.sorted {
                if $0.priceDistance == $1.priceDistance {
                    return $0.similarityScore > $1.similarityScore
                }
                return $0.priceDistance < $1.priceDistance
            }
        case .bestRetention:
            return ranked.sorted {
                if $0.depreciationLoss == $1.depreciationLoss {
                    return $0.priceDistance < $1.priceDistance
                }
                return $0.depreciationLoss < $1.depreciationLoss
            }
        }
    }

    private var sameBrandCandidates: [RankedCandidate] {
        rankedCandidates.filter {
            $0.candidate.car.brand.caseInsensitiveCompare(referenceForecast.userCar.brand) == .orderedSame
        }
    }

    private var otherBrandCandidates: [RankedCandidate] {
        rankedCandidates.filter {
            $0.candidate.car.brand.caseInsensitiveCompare(referenceForecast.userCar.brand) != .orderedSame
        }
    }

    private var mostConvenientCandidateID: UUID? {
        rankedCandidates.min {
            if $0.depreciationLoss == $1.depreciationLoss {
                return $0.priceDistance < $1.priceDistance
            }
            return $0.depreciationLoss < $1.depreciationLoss
        }?.id
    }

    private var mostStableCandidateID: UUID? {
        rankedCandidates.min {
            if $0.stabilityIndex == $1.stabilityIndex {
                return $0.priceDistance < $1.priceDistance
            }
            return $0.stabilityIndex < $1.stabilityIndex
        }?.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                introSection
                ageSliderSection
                sortControlSection
                comparisonSection(
                    "Stesso marchio",
                    subtitle: "Ordinati per somiglianza e vicinanza prezzo",
                    candidates: sameBrandCandidates
                )
                comparisonSection(
                    "Altri marchi",
                    subtitle: "Alternative ordinate per pertinenza",
                    candidates: otherBrandCandidates
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .background(ColorLayout.appBackround.auto.ignoresSafeArea())
        .navigationTitle("Confronta con altre auto")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: recompute)
        .onChange(of: filters) { _, _ in recompute() }
        .sheet(item: $selectedCandidate) { ranked in
            ComparisonCandidateDetailSheet(
                rankedCandidate: ranked,
                badges: badges(for: ranked),
                selectedAgeOffset: selectedAgeOffset,
                referenceTitle: "\(referenceForecast.userCar.brand) \(referenceForecast.userCar.model)",
                referenceStartingPrice: referenceForecast.purchasePrice,
                referenceCurrentPrice: referenceCurrentValue
            )
        }
    }

    private var sortControlSection: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Ordinamento risultati")
                    .font(.headline)

                Picker("Ordinamento", selection: $sortMode) {
                    ForEach(ComparisonSortMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Text(sortMode.helperText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var introSection: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Auto di riferimento")
                    .font(.headline)

                Text("Confrontiamo la tua auto con modelli simili per alimentazione, segmento e fascia di prezzo.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ComparisonVehicleCard(
                    title: "\(referenceForecast.userCar.brand) \(referenceForecast.userCar.model)",
                    subtitle: referenceForecast.userCar.version,
                    fuel: referenceResolvedCar?.fuel,
                    engine: referenceForecast.userCar.engine,
                    year: referenceForecast.userCar.registrationYear,
                    segment: referenceResolvedCar?.category,
                    startingPrice: referenceForecast.purchasePrice,
                    currentPrice: referenceCurrentValue,
                    selectedAgeOffset: selectedAgeOffset,
                    isReference: true,
                    badges: [],
                    isInteractive: false,
                    rankLabel: nil
                )
            }
        }
    }

    private var ageSliderSection: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Anni dall'immatricolazione: \(selectedAgeOffset)")
                    .font(.headline)

                Slider(
                    value: Binding(
                        get: { Double(selectedAgeOffset) },
                        set: { selectedAgeOffset = Int($0) }
                    ),
                    in: 0...20, step: 1
                )

                Text("Aggiorna il confronto al valore stimato dopo \(selectedAgeOffset) anni.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func comparisonSection(_ title: String, subtitle: String, candidates: [RankedCandidate]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if candidates.isEmpty {
                SectionCard {
                    Text("Nessun risultato coerente trovato con i filtri attuali.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            ForEach(Array(candidates.enumerated()), id: \.element.id) { index, ranked in
                Button {
                    selectedCandidate = ranked
                } label: {
                    ComparisonVehicleCard(
                        title: "\(ranked.candidate.car.brand) \(ranked.candidate.car.model)",
                        subtitle: ranked.candidate.car.version,
                        fuel: ranked.candidate.car.fuel,
                        engine: ranked.candidate.car.engine,
                        year: ranked.candidate.car.year,
                        segment: ranked.candidate.car.category,
                        startingPrice: ranked.candidate.basePrice,
                        currentPrice: ranked.currentValue,
                        selectedAgeOffset: selectedAgeOffset,
                        isReference: false,
                        badges: badges(for: ranked),
                        isInteractive: true,
                        rankLabel: "#\(index + 1)"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func valueAtSelectedAge(_ data: [DepreciationPoint], registrationYear: Int) -> Double {
        let targetYear = registrationYear + selectedAgeOffset
        if let exact = data.first(where: { $0.year == targetYear }) {
            return exact.value
        }
        let nearest = data.min { abs($0.year - targetYear) < abs($1.year - targetYear) }
        return nearest?.value ?? 0
    }

    private func rankCandidate(_ candidate: ComparisonCandidate) -> RankedCandidate {
        let currentValue = valueAtSelectedAge(candidate.data, registrationYear: candidate.car.year)
        return RankedCandidate(
            candidate: candidate,
            similarityScore: similarityScore(for: candidate),
            priceDistance: abs(candidate.basePrice - referenceForecast.purchasePrice),
            currentValue: currentValue,
            stabilityIndex: stabilityIndex(for: candidate.data)
        )
    }

    private func similarityScore(for candidate: ComparisonCandidate) -> Double {
        let referenceFuel = normalizedTokenString(referenceResolvedCar?.fuel ?? referenceForecast.userCar.engine)
        let candidateFuel = normalizedTokenString(candidate.car.fuel)

        let referenceSegment = normalizedTokenString(referenceResolvedCar?.category ?? "")
        let candidateSegment = normalizedTokenString(candidate.car.category ?? "")

        let fuelMatch = referenceFuel == candidateFuel ? 3.0 : 0.0
        let segmentMatch = referenceSegment == candidateSegment ? 3.0 : 0.0
        let engineMatch = engineSimilarity(referenceForecast.userCar.engine, candidate.car.engine) * 2.0
        let yearDistance = Double(abs(referenceForecast.userCar.registrationYear - candidate.car.year))
        let yearScore = max(0, 1 - min(yearDistance, 10) / 10)
        return fuelMatch + segmentMatch + engineMatch + yearScore
    }

    private func engineSimilarity(_ lhs: String, _ rhs: String) -> Double {
        let left = Set(normalizedTokenString(lhs).split(separator: " "))
        let right = Set(normalizedTokenString(rhs).split(separator: " "))
        guard !left.isEmpty && !right.isEmpty else { return 0 }
        let intersection = left.intersection(right).count
        let union = left.union(right).count
        guard union > 0 else { return 0 }
        return Double(intersection) / Double(union)
    }

    private func normalizedTokenString(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-zA-Z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func stabilityIndex(for points: [DepreciationPoint]) -> Double {
        let sorted = points.sorted { $0.year < $1.year }
        guard sorted.count > 2 else { return 1 }

        var yearDeltas: [Double] = []
        for i in 1..<sorted.count {
            let previous = sorted[i - 1].value
            let current = sorted[i].value
            guard previous > 0 else { continue }
            yearDeltas.append((previous - current) / previous)
        }

        guard yearDeltas.count > 1 else { return 1 }
        let mean = yearDeltas.reduce(0, +) / Double(yearDeltas.count)
        let variance = yearDeltas
            .map { pow($0 - mean, 2) }
            .reduce(0, +) / Double(yearDeltas.count)
        return sqrt(variance)
    }

    private func badges(for ranked: RankedCandidate) -> [ComparisonBadge] {
        var result: [ComparisonBadge] = []
        if ranked.id == mostConvenientCandidateID {
            result.append(.convenient)
        }
        if ranked.id == mostStableCandidateID {
            result.append(.stable)
        }
        return result
    }

    private func recompute() {
        result = engine.generateComparison(
            referenceUserCar: referenceForecast.userCar,
            referenceBasePrice: referenceForecast.purchasePrice,
            filters: filters
        )
    }
}
