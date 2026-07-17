//
//  YearStepperBox.swift
//
//  Copyright (c) 2026 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct YearStepperBox: View {
    @Binding var selectedYear: Int
    let data: [DepreciationPoint]
    let minYear: Int
    let maxYear: Int

    private var selectedPoint: DepreciationPoint? {
        data.first { $0.year == selectedYear }
    }

    var body: some View {
        HStack {
            stepButton(
                systemImage: "chevron.left",
                enabled: selectedYear > minYear
            ) {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedYear -= 1
                }
            }

            Spacer()

            VStack(spacing: 4) {
                Text("Anno \(String(selectedYear))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let value = selectedPoint?.value {
                    Text("€\(Int(value))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(ColorLayout.primary.auto)
                }
            }

            Spacer()

            stepButton(
                systemImage: "chevron.right",
                enabled: selectedYear < maxYear
            ) {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedYear += 1
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4, y: 2)
    }


    // MARK: - Button
    private func stepButton(
        systemImage: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(ColorLayout.primary.auto.opacity(enabled ? 0.15 : 0.05))
                )
        }
        .disabled(!enabled)
        .foregroundColor(
            enabled ? ColorLayout.primary.auto : .gray.opacity(0.4)
        )
    }
}
