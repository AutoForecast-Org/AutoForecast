//
//  WelcomeSlideView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct WelcomeSlideView: View {
    let slide: WelcomeSlide
    
    var body: some View {
        VStack(spacing: 20) {
            Image(slide.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .cornerRadius(16)
                .shadow(radius: 8)
            
            Text(slide.title)
                .font(.largeTitle)
                .bold()
            
            Text(slide.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
