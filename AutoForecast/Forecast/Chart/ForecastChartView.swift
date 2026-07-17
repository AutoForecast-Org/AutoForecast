//
//  ForecastChartView.swift
//
//  Copyright (c) 2025 AutoForecast
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import Charts

struct ForecastChartView: View {
    let data: [DepreciationPoint]
    let pessimisticData: [DepreciationPoint]
    let optimisticData: [DepreciationPoint]
    let yearRange: ClosedRange<Double>
    
    @Binding var selectedYear: Int
    
    let desiredYaxisStepLabels: Int
    let desiredXaxisStepLabels: Int
    
    let baselinePrice: Double?
    
    @AppStorage(ForecastPreferences.showOptimistic) private var showOptimistic = true
    @AppStorage(ForecastPreferences.showPessimistic) private var showPessimistic = true
    @AppStorage(ForecastPreferences.showColorAreas) private var showColorAreas = true
    @AppStorage(ForecastPreferences.showTooltip) private var showTooltip = true
    
    let greenColor = ColorLayout.green.auto
    let redColor = ColorLayout.red.auto
    
//    private var yDomain: ClosedRange<Double> {
//        var allValues = (data + pessimisticData + optimisticData).map { $0.value }
//
//        if let price = baselinePrice {
//            allValues.append(price)
//        }
//
//        let rawMinY = allValues.min() ?? 0
//        let rawMaxY = allValues.max() ?? 0
//
//        let padding = max((rawMaxY - rawMinY) * 0.1, rawMaxY * 0.05)
//
//        let minY = max(0, rawMinY - padding)
//        let maxY = rawMaxY + padding
//
//        return minY...maxY
//    }
    private var yDomain: ClosedRange<Double> {
        var allValues = (data + pessimisticData + optimisticData).map { $0.value }

        if let price = baselinePrice {
            allValues.append(price)
        }

        let rawMinY = allValues.min() ?? 0
        let rawMaxY = allValues.max() ?? 0

        let range = rawMaxY - rawMinY

        let bottomPadding = max(range * 0.08, rawMaxY * 0.04)
        let topPadding    = max(range * 0.18, rawMaxY * 0.10)

        let minY = max(0, rawMinY - bottomPadding)
        let maxY = rawMaxY + topPadding

        return minY...maxY
    }

    
    var body: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = data.first?.year ?? currentYear
        let endYear = data.last?.year ?? (currentYear + 20)
        
        let pastData = data.filter { $0.year <= currentYear }
        let futureData = data.filter { $0.year >= currentYear }
        
        let pastPessimisticData = pessimisticData.filter { $0.year <= currentYear }
        let futurePessimisticData = pessimisticData.filter { $0.year >= currentYear }
        
        let pastOptimisticData = optimisticData.filter { $0.year <= currentYear }
        let futureOptimisticData = optimisticData.filter { $0.year >= currentYear }
        
        // ---------------------------------------
        // SLIDER / YEAR STEPPER BOX
        // ---------------------------------------
//        HStack {
//            Text("Anno \(String(selectedYear))")
//                .font(.headline)
//            Slider(
//                value: Binding(
//                    get: { Double(selectedYear) },
//                    set: { selectedYear = Int($0) }
//                ),
//                in: yearRange,
//                step: 1
//            )
//            .accentColor(ColorLayout.ochre.auto)
//        }
//
        YearStepperBox(
            selectedYear: $selectedYear,
            data: data,
            minYear: startYear,
            maxYear: endYear
        )

        Chart {
            
            // ---------------------------------------
            // PESSIMISTICO (ROSSO)
            // ---------------------------------------
            if(showPessimistic) {
                ForEach(pastPessimisticData) { point in
                    LineMark(
                        x: .value("Anno", Double(point.year)),
                        y: .value("Valore", point.value),
                        series: .value("Serie", "PessimisticPast")
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4,4]))
                    .foregroundStyle(.gray).opacity(0.4)
                    .zIndex(1)
                }
                if showColorAreas {
                    ForEach(futurePessimisticData) { point in
                        AreaMark(
                            x: .value("Anno", Double(point.year)),
                            yStart: .value("Baseline", yDomain.lowerBound),
                            yEnd: .value("Valore", point.value),
                            series: .value("Serie1", "PessimisticFuture")
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.red.opacity(0.25))
                        .zIndex(1)
                    }
                }
                ForEach(futurePessimisticData) { point in
                    LineMark(
                        x: .value("Anno", Double(point.year)),
                        y: .value("Valore", point.value),
                        series: .value("Serie", "PessimisticFuture")
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4,4]))
                    .foregroundStyle(.red)
                    .zIndex(1)
                }
            }
            
            // ---------------------------------------
            // OTTIMISTICO (VERDE)
            // ---------------------------------------
            if (showOptimistic) {
                ForEach(pastOptimisticData) { point in
                    LineMark(
                        x: .value("Anno", Double(point.year)),
                        y: .value("Valore", point.value),
                        series: .value("Serie", "OptimisticPast")
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4,4]))
                    .foregroundStyle(.gray).opacity(0.4)
                    .zIndex(2)
                }
                if showColorAreas {
                    ForEach(futureOptimisticData) { point in
                        AreaMark(
                            x: .value("Anno", Double(point.year)),
                            yStart: .value("Baseline", yDomain.lowerBound),
                            yEnd: .value("Valore", point.value),
                            series: .value("Serie2", "OptimisticFuture")
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.green.opacity(0.25))
                        .zIndex(2)
                    }
                }
                ForEach(futureOptimisticData) { point in
                    LineMark(
                        x: .value("Anno", Double(point.year)),
                        y: .value("Valore", point.value),
                        series: .value("Serie", "OptimisticFuture")
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4,4]))
                    .foregroundStyle(.green)
                    .zIndex(2)
                }
            }
            
            // ---------------------------------------
            // PRINCIPALE (BLU)
            // ---------------------------------------
            ForEach(pastData) { point in
                LineMark(
                    x: .value("Anno", Double(point.year)),
                    y: .value("Valore", point.value),
                    series: .value("Serie", "BasePAST")
                )
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(.gray).opacity(0.4)
                .zIndex(3)
            }
            
            if showColorAreas {
                ForEach(futureData) { point in
                    AreaMark(
                        x: .value("Anno", Double(point.year)),
                        yStart: .value("Baseline", yDomain.lowerBound),
                        yEnd: .value("Valore", point.value),
                        series: .value("Serie3", "BaseFuture")
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.blue.opacity(0.40))
                    .zIndex(3)
                }
            }
            ForEach(futureData) { point in
                LineMark(
                    x: .value("Anno", Double(point.year)),
                    y: .value("Valore", point.value),
                    series: .value("Serie", "BaseFuture")
                )
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(.blue)
                .zIndex(3)
            }
            
            // ---------------------------------------
            // LINEA ANNO CORRENTE
            // ---------------------------------------
            RuleMark(x: .value("Anno", Double(currentYear)))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(.gray.opacity(0.7))
            
            // ---------------------------------------
            // PUNTO SELEZIONATO
            // ---------------------------------------
            if let selPoint = data.first(where: { $0.year == selectedYear }) {
                PointMark(
                    x: .value("Anno", Double(selPoint.year)),
                    y: .value("Valore", selPoint.value)
                )
                .foregroundStyle(.blue)
                .symbolSize(70)
                
                RuleMark(x: .value("Anno", Double(selPoint.year)))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6,6]))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            
            // ---------------------------------------
            // PREZZO DI LISTINO
            // ---------------------------------------
            if let price = baselinePrice {
                RuleMark(y: .value("Prezzo di listino", price))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundStyle(ColorLayout.primary.auto.opacity(0.6))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Prezzo di listino")
                            .font(.caption)
                            .foregroundColor(ColorLayout.primary.auto)
                    }
                    .zIndex(4)
            }

        }
        // ---------------------------------------
        // SCALA X
        // ---------------------------------------
        .chartXScale(domain: Double(startYear)...Double(endYear))
        .chartXAxis {
            let strideValues = Array(stride(from: startYear, through: endYear, by: desiredXaxisStepLabels))
            AxisMarks(values: strideValues.map { Double($0) }) { value in
                AxisTick()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        let year = Int(doubleValue)
                        let number = NSNumber(value: year)
                        let label = NumberFormatter.yearFormatter.string(from: number) ?? ""
                        
                        Text(label)
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .padding(.vertical, 6)
                            .padding(.horizontal, -11)
                    }
                }
            }
        }
        .chartXAxisLabel(position: .bottom, alignment: .bottomTrailing) {
            Text("Anno")
        }
        
        // ---------------------------------------
        // SCALA Y
        // ---------------------------------------
        .chartYScale(domain: yDomain)
//        .chartYAxis {
//                AxisMarks(position: .leading, values: .automatic(desiredCount: desiredYaxisStepLabels)) { value in
//                AxisGridLine()
//                AxisValueLabel {
//                    if let val = value.as(Double.self) {
//                        Text("€\(Int(val/1000))k")
//                    }
//                }
//            }
//        }
        .chartYAxis {
            AxisMarks(
                position: .leading,
                values: .automatic(desiredCount: desiredYaxisStepLabels)
            ) { value in
                AxisGridLine()

                AxisValueLabel {
                    if let val = value.as(Double.self) {
                        let number = NSNumber(value: Int(val))
                        let formatted =
                            NumberFormatter.currencyNoDecimals.string(from: number) ?? ""

                        Text("€\(formatted)")
                    }
                }
            }
        }

        .chartYAxisLabel("Valore del veicolo")
        
        // ---------------------------------------
        // Overlay: selezione e tooltip
        // ---------------------------------------
        .chartOverlay { proxy in
            GeometryReader { geo in
                // Overlay grigio a sinistra dell’anno corrente
//                if let xCurrent = proxy.position(forX: Double(currentYear)) {
//                    Canvas { context, size in
//                        let stripeWidth: CGFloat = 4
//                        let spacing: CGFloat = 4
//                        var x: CGFloat = 0
//                        while x < xCurrent {
//                            let rect = CGRect(x: x, y: 0, width: stripeWidth, height: size.height)
//                            context.fill(Path(rect), with: .color(Color.gray.opacity(0.40)))
//                            x += stripeWidth + spacing
//                        }
//                    }
//                    .frame(width: geo.size.width, height: geo.size.height)
//                }
                
                // Gesture di selezione
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let xValue: Double = proxy.value(atX: value.location.x) {
                                    let rounded = Int(xValue.rounded())
                                    let clamped = min(max(rounded, startYear), endYear)
                                    selectedYear = clamped
                                }
                            }
                    )
                
                // Tooltip
                if showTooltip,
                   let point = data.first(where: { $0.year == selectedYear }),
                   let xPos = proxy.position(forX: Double(point.year)),
                   let yPos = proxy.position(forY: point.value) {
                    
                    let tooltipWidth: CGFloat = 100
                    let tooltipHeight: CGFloat = 56
                    
                    let clampedX = min(max(xPos, tooltipWidth/2 + 4), geo.size.width - tooltipWidth/2 - 4)
                    let clampedY = max(yPos - 40, tooltipHeight/2 + 4)
                    
                    VStack(spacing: 4) {
                        Text("Anno \(String(point.year))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("€\(Int(point.value))")
                            .font(.headline).bold()
                    }
                    .padding(8)
                    .frame(width: tooltipWidth)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .position(x: clampedX, y: clampedY)
                }
            }
        }
        .frame(height: 240)
//        .shadow(radius: 5, y: 3)
        
        // ---------------------------------------
        // TOGGLE
        // ---------------------------------------
        VStack(alignment: .leading, spacing: 12) {
            Text("Opzioni di visualizzazione")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ToggleButton(
                    title: "Dati ottimistici",
                    isOn: $showOptimistic,
                    color: greenColor
                )

                ToggleButton(
                    title: "Dati pessimistici",
                    isOn: $showPessimistic,
                    color: redColor
                )

                ToggleButton(
                    title: "Aree di colore",
                    isOn: $showColorAreas,
                    color: .gray
                )

                ToggleButton(
                    title: "Pop-up informativo",
                    isOn: $showTooltip,
                    color: .gray
                )
            }
        }

    }
}

extension NumberFormatter {
    static let yearFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .none
        f.usesGroupingSeparator = false
        return f
    }()
}

extension NumberFormatter {
    static let currencyNoDecimals: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.groupingSeparator = "."
        f.maximumFractionDigits = 0
        return f
    }()
}

enum ForecastPreferences {
    static let showOptimistic = "forecast_showOptimistic"
    static let showPessimistic = "forecast_showPessimistic"
    static let showColorAreas = "forecast_showColorAreas"
    static let showTooltip = "forecast_showTooltip"
}
