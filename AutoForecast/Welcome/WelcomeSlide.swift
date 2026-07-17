//
//  WelcomeSlide.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct WelcomeSlide: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

let slides = [
    WelcomeSlide(imageName: "Placeholder", title: "Benvenuto", description: "Esplora la nostra app con facilità."),
    WelcomeSlide(imageName: "Placeholder", title: "Scopri", description: "Trova le funzioni che ti servono."),
    WelcomeSlide(imageName: "Placeholder", title: "Inizia", description: "Pronto per partire!")
]
