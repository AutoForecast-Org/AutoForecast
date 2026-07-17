//
//  ForecastChartExpandView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import SwiftUI

struct ForecastChartExpandedView: View {
    let forecast: UserCarForecast
    let yearRange: ClosedRange<Double>
    @State var selectedYear: Int
    
    var body: some View {
        OrientationLockView(forcedOrientation: .landscape) {
            
            ScrollView {
                VStack(spacing: 16) {
                    ForecastChartView(
                        data: forecast.data,
                        pessimisticData: forecast.pessimisticData,
                        optimisticData: forecast.optimisticData,
                        yearRange: yearRange,
                        selectedYear: $selectedYear,
                        desiredYaxisStepLabels: 10,
                        desiredXaxisStepLabels: 1,
                        baselinePrice: forecast.purchasePrice
                    )
                    .frame(maxHeight: .infinity)
                    
                    if let point = forecast.data.first(where: { $0.year == selectedYear }) {
                        OscillationValueView(
                            selectedYear: $selectedYear,
                            minValue: point.value * 0.90,
                            baseValue: point.value,
                            maxValue: point.value * 1.10
                        )
                    }
                    
                }
            }
            //            .padding(.top, 40)
            .padding(.bottom, 8)
            .navigationTitle("Valore futuro")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
        }
    }
}
