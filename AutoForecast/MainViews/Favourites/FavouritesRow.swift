//
//  FavouritesRow.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct FavouritesRow: View {
    let search: SavedSearch

    private static let rowDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorLayout.primary.auto.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "car.fill")
                    .foregroundColor(ColorLayout.primary.auto)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(search.brand) \(search.model)")
                    .font(.headline)
                    .foregroundColor(ColorLayout.primary.auto)

                var engineAndVersionString: String {
                    if let version = search.version {
                        return "\(search.engine) • \(version)"
                    } else {
                        return search.engine
                    }
                }
                
                Text("\(engineAndVersionString)")
                    .font(.subheadline)
                    .foregroundColor(ColorLayout.gray3.auto)
                    .multilineTextAlignment(.leading)
                
                Text("\(String(search.registrationYear)) • \(search.actualKm) km")
                    .font(.subheadline)
                    .foregroundColor(ColorLayout.gray3.auto)
                    .multilineTextAlignment(.leading)

                Text("Salvata il \(formattedDate(search.createdAt))")
                    .font(.caption)
                    .foregroundColor(ColorLayout.gray3.auto)
            }

            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ColorLayout.gray3.auto)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(ColorLayout.cardRowBackgroud.auto)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    func formattedDate(_ date: Date) -> String {
        Self.rowDateFormatter.string(from: date)
    }
}
