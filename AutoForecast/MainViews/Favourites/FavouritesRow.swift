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
                    .foregroundColor(ColorLayout.gray3.auto.opacity(0.85))
                    .multilineTextAlignment(.leading)
                
                Text("\(String(search.registrationYear)) • \(search.actualKm) km")
                    .font(.subheadline)
                    .foregroundColor(ColorLayout.gray3.auto.opacity(0.85))
                    .multilineTextAlignment(.leading)

                Text("Salvata il \(formattedDate(search.createdAt))")
//                Text("Salvata il \(search.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(ColorLayout.gray3.auto)
            }

            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ColorLayout.gray3.auto)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(ColorLayout.cardRowBackgroud.auto)
        .cornerRadius(16)
        .shadow(radius: 3, y: 2)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
