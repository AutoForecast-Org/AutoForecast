//
//  DepreciationSparkline.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct DepreciationSparkline: View {
    let points: [DepreciationPoint]
    let selectedAgeOffset: Int
    let registrationYear: Int

    private var sortedPoints: [DepreciationPoint] {
        points.sorted { $0.year < $1.year }
    }

    private var minValue: Double {
        sortedPoints.map(\.value).min() ?? 0
    }

    private var maxValue: Double {
        sortedPoints.map(\.value).max() ?? 1
    }

    private var selectedPointIndex: Int? {
        let targetYear = registrationYear + selectedAgeOffset
        return sortedPoints.enumerated().min {
            abs($0.element.year - targetYear) < abs($1.element.year - targetYear)
        }?.offset
    }

    var body: some View {
        if sortedPoints.count < 2 {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondary.opacity(0.12))
        } else {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let denominator = max(maxValue - minValue, 1)
                let stepX = width / CGFloat(max(sortedPoints.count - 1, 1))

                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.secondary.opacity(0.10))

                    Path { path in
                        for (index, point) in sortedPoints.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalized = (point.value - minValue) / denominator
                            let y = height - CGFloat(normalized) * height

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        ColorLayout.primary.auto,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )

                    if let selectedPointIndex {
                        let selectedValue = sortedPoints[selectedPointIndex].value
                        let normalized = (selectedValue - minValue) / denominator
                        let y = height - CGFloat(normalized) * height
                        let x = CGFloat(selectedPointIndex) * stepX

                        Circle()
                            .fill(ColorLayout.primary.auto)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

struct DepreciationComparisonSparkline: View {
    let referencePoints: [DepreciationPoint]
    let referenceRegistrationYear: Int
    let candidatePoints: [DepreciationPoint]
    let candidateRegistrationYear: Int
    let selectedAgeOffset: Int
    let referenceColor: Color
    let candidateColor: Color

    private var referenceSeries: [(age: Int, value: Double)] {
        normalizedSeries(referencePoints, registrationYear: referenceRegistrationYear)
    }

    private var candidateSeries: [(age: Int, value: Double)] {
        normalizedSeries(candidatePoints, registrationYear: candidateRegistrationYear)
    }

    private var allValues: [Double] {
        referenceSeries.map(\.value) + candidateSeries.map(\.value)
    }

    private var ageRange: ClosedRange<Int>? {
        let ages = referenceSeries.map(\.age) + candidateSeries.map(\.age)
        guard let minimum = ages.min(), let maximum = ages.max() else { return nil }
        return minimum...max(maximum, minimum + 1)
    }

    var body: some View {
        if referenceSeries.count < 2 || candidateSeries.count < 2 || ageRange == nil {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondary.opacity(0.10))
                .overlay {
                    Text("Dati insufficienti per il confronto")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
        } else {
            GeometryReader { geometry in
                let minimumValue = allValues.min() ?? 0
                let maximumValue = allValues.max() ?? 1
                let valueRange = max(maximumValue - minimumValue, 1)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.secondary.opacity(0.10))

                    VStack(spacing: 0) {
                        Divider().opacity(0.25)
                        Spacer()
                        Divider().opacity(0.25)
                        Spacer()
                        Divider().opacity(0.25)
                    }
                    .padding(.vertical, 12)

                    seriesPath(referenceSeries, in: geometry.size, minimumValue: minimumValue, valueRange: valueRange)
                        .stroke(referenceColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    seriesPath(candidateSeries, in: geometry.size, minimumValue: minimumValue, valueRange: valueRange)
                        .stroke(candidateColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    selectedMarker(referenceSeries, color: referenceColor, in: geometry.size, minimumValue: minimumValue, valueRange: valueRange)
                    selectedMarker(candidateSeries, color: candidateColor, in: geometry.size, minimumValue: minimumValue, valueRange: valueRange)
                }
            }
        }
    }

    private func normalizedSeries(_ points: [DepreciationPoint], registrationYear: Int) -> [(age: Int, value: Double)] {
        points
            .map { (age: $0.year - registrationYear, value: $0.value) }
            .sorted { $0.age < $1.age }
    }

    private func seriesPath(
        _ series: [(age: Int, value: Double)],
        in size: CGSize,
        minimumValue: Double,
        valueRange: Double
    ) -> Path {
        Path { path in
            for (index, point) in series.enumerated() {
                let position = position(for: point, in: size, minimumValue: minimumValue, valueRange: valueRange)
                if index == 0 {
                    path.move(to: position)
                } else {
                    path.addLine(to: position)
                }
            }
        }
    }

    @ViewBuilder
    private func selectedMarker(
        _ series: [(age: Int, value: Double)],
        color: Color,
        in size: CGSize,
        minimumValue: Double,
        valueRange: Double
    ) -> some View {
        if let point = series.min(by: { abs($0.age - selectedAgeOffset) < abs($1.age - selectedAgeOffset) }) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
                .overlay(Circle().stroke(ColorLayout.cardRowBackgroud.auto, lineWidth: 2))
                .position(position(for: point, in: size, minimumValue: minimumValue, valueRange: valueRange))
        }
    }

    private func position(
        for point: (age: Int, value: Double),
        in size: CGSize,
        minimumValue: Double,
        valueRange: Double
    ) -> CGPoint {
        let range = ageRange ?? 0...1
        let normalizedAge = Double(point.age - range.lowerBound) / Double(max(range.upperBound - range.lowerBound, 1))
        let normalizedValue = (point.value - minimumValue) / valueRange
        return CGPoint(
            x: CGFloat(normalizedAge) * size.width,
            y: size.height - CGFloat(normalizedValue) * size.height
        )
    }
}
