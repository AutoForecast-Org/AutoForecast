//
//  ForecastDiplayMode.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

enum ForecastDisplayMode {
    case all           // Mostra all 3 lines
    case baseOnly      // Just blue line
    case baseAndOptimistic // Blue + green
    case baseAndPessimistic // Blue + red
}
