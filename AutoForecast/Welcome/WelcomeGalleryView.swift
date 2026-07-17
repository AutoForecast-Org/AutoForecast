//
//  WelcomeGalleryView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct WelcomeGalleryView: View {
    @State private var selection = 0
    let slides: [WelcomeSlide]
    @AppStorage("welcomeScreenAlreadyShown") var welcomeScreenAlreadyShown: Bool = false
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    WelcomeSlideView(slide: slide)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: selection)
            
            Button(action: {
                if selection < slides.count - 1 {
                    selection += 1
                } else {
                    welcomeScreenAlreadyShown = true 
                }
            }) {
                Text(selection == slides.count - 1 ? "Inizia" : "Avanti")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorLayout.primary.auto)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
        }
    }
}
