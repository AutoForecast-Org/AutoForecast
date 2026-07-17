//
//  OscillationValueView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct OscillationValueView: View {
    
    @Binding var selectedYear: Int
    
    let minValue: Double
    let baseValue: Double
    let maxValue: Double
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            // MARK: - LABELS ABOVE
            HStack {
                Text("Valore minimo")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                Text("La tua stima nel \(String(selectedYear))")
                    .font(.system(size: 12.5, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ColorLayout.primary.auto.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(ColorLayout.primary.auto.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: .infinity)
                Text("Valore massimo")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            
            // MARK: - LINE + DOTS
            ZStack {
//                // Line
//                Rectangle()
//                    .fill(Color.secondary.opacity(0.3))
//                    .frame(height: 2)
//                    .padding(.horizontal, 20)
                // Gradient Line
                LinearGradient(
                    colors: [ColorLayout.red.auto.opacity(0.6), ColorLayout.primary.auto, ColorLayout.green.auto.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 3)
                .cornerRadius(2)
                .padding(.horizontal, 20)

                
                // Dots
                HStack {
                    Circle()
                        .fill(ColorLayout.red.auto)
                        .frame(width: 16, height: 16)
                        .frame(maxWidth: .infinity)

                    Circle()
                        .fill(ColorLayout.primary.auto)
                        .frame(width: 20, height: 20)
                        .frame(maxWidth: .infinity)

                    Circle()
                        .fill(ColorLayout.green.auto)
                        .frame(width: 16, height: 16)
                        .frame(maxWidth: .infinity)
                }
//                .padding(.horizontal, 20)
//                HStack {
//                    Circle()
//                        .fill(Color.red)
//                        .frame(width: 16, height: 16)
//                    
//                    Spacer()
//                    
//                    Circle()
//                        .fill(Color.blue)
//                        .frame(width: 20, height: 20)
//                    
//                    Spacer()
//                    
//                    Circle()
//                        .fill(Color.green)
//                        .frame(width: 16, height: 16)
//                }
//                .padding(.horizontal, 20)
            }
            .frame(height: 30)
            
            // MARK: - VALUES BELOW
            HStack {
                Text("€\(Int(minValue))")
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
                
                Text("€\(Int(baseValue))")
                    .font(.system(size: 12.5, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ColorLayout.primary.auto.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(ColorLayout.primary.auto.opacity(0.3), lineWidth: 1)
                            )
                    )

                    .frame(maxWidth: .infinity)
                
                Text("€\(Int(maxValue))")
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
            }
        }
//        .padding()
//        .background(Color.blue.opacity(0.08))
//        .cornerRadius(16)
    }
}

