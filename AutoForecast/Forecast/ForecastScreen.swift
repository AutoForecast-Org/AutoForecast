//
//  ForecastScreen.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ForecastScreen: View {

    var userCar: UserCar

    @EnvironmentObject var searchManager: SearchManager

    private var depreciationEngine: DepreciationEngine {
        DepreciationEngine(searchManager: searchManager)
    }

    var body: some View {
        let basePrice = depreciationEngine.resolvePurchasePrice(userCar: userCar)

        VStack(spacing: 20) {
            ForecastView(
                userCarForecast: UserCarForecast(
                    userCar: userCar,
                    data: depreciationEngine.generateDepreciationData(userCar: userCar, basePrice: basePrice),
                    optimisticData: depreciationEngine.generateOptimisticData(userCar: userCar, basePrice: basePrice),
                    pessimisticData: depreciationEngine.generatePessimisticData(userCar: userCar, basePrice: basePrice),
                    purchasePrice: basePrice,
                    isExmample: false,
                    isSaved: false
                )
            )
        }
        .navigationTitle("Previsione")
        .navigationBarTitleDisplayMode(.inline)
    }
}
