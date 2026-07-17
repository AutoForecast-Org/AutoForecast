//
//  ToggleButton.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ToggleButton: View {
    let title: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isOn
                      ? "checkmark.circle.fill"
                      : "checkmark.circle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isOn ? .white : color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
//            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isOn ? color.opacity(0.85)
                               : Color.gray.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: isOn ? 0 : 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
