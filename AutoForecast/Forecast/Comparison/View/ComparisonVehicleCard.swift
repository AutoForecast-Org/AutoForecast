//
//  ComparisonVehicleCard.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ComparisonVehicleCard: View {
    let title: String
    let subtitle: String?
    let fuel: String?
    let engine: String
    let year: Int
    let segment: String?
    let startingPrice: Double
    let currentPrice: Double
    let selectedAgeOffset: Int
    let isReference: Bool
    let badges: [ComparisonBadge]
    let isInteractive: Bool
    let rankLabel: String?

    private var variation: Double {
        guard startingPrice > 0 else { return 0 }
        return (currentPrice - startingPrice) / startingPrice
    }

    private var variationColor: Color {
        variation >= 0 ? ColorLayout.green.auto : ColorLayout.red.auto
    }

    private var resolvedSubtitle: String {
        guard let subtitle, !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Versione non disponibile"
        }
        return subtitle
    }

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let rankLabel, !isReference {
                            Text(rankLabel)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(ColorLayout.primary.auto)
                        }
                        Text(title)
                            .font(.headline)
                        Text(resolvedSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer(minLength: 8)

                    if isReference {
                        Text("Auto corrente")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ColorLayout.primary.auto.opacity(0.16))
                            .foregroundColor(ColorLayout.primary.auto)
                            .clipShape(Capsule())
                    } else if isInteractive {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if !badges.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(badges) { badge in
                            BadgeChip(badge: badge)
                        }
                    }
                }

                HStack(spacing: 8) {
                    DetailChip(label: fuel ?? "N/D", icon: "fuelpump.fill")
                    DetailChip(label: engine, icon: "gearshape.2.fill")
                }

                HStack(spacing: 8) {
                    DetailChip(label: "\(year)", icon: "calendar")
                    DetailChip(label: segment ?? "Segmento N/D", icon: "square.grid.2x2")
                }

                HStack(spacing: 10) {
                    MetricBox(title: "Listino", value: startingPrice.euroString)
                    MetricBox(title: "Valore (\(selectedAgeOffset)a)", value: currentPrice.euroString)
                    MetricBox(
                        title: "Variazione",
                        value: variation.percentString,
                        tint: variationColor
                    )
                }
            }
        }
    }
}
