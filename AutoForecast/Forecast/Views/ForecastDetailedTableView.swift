//
//  ForecastDetailedTableView.swift
//
//  Copyright (c) 2026 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ForecastDetailedTableView: View {
    let data: [DepreciationPoint]

    var body: some View {
        List {
            Section(header: Text("Valore stimato anno per anno")) {
                ForEach(data.sorted(by: { $0.year < $1.year })) { point in
                    HStack {
                        Text(String(point.year))
                            .font(.headline)
                        Spacer()
                        Text(point.value, format: .currency(code: "EUR"))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Dati")
        .navigationBarTitleDisplayMode(.inline)
    }
}
