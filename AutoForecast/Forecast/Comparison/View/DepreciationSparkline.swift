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
