//
//  BadgeChip.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct BadgeChip: View {
    let badge: ComparisonBadge

    var body: some View {
        Label(badge.title, systemImage: badge.icon)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(badge.tint.opacity(0.16))
            .foregroundColor(badge.tint)
            .clipShape(Capsule())
    }
}
