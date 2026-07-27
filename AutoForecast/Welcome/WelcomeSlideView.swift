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
    let index: Int
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Passo \(index + 1) di \(total)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: slide.systemImage)
                    .font(.headline)
                    .foregroundStyle(ColorLayout.primary.auto)
            }

            Image(slide.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .cornerRadius(16)

            Text(slide.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(slide.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(slide.highlights, id: \.self) { highlight in
                    Label(highlight, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .labelStyle(.titleAndIcon)
                }
            }

            if let footerNote = slide.footerNote {
                Text(footerNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ColorLayout.primary.auto.opacity(0.08),
                            ColorLayout.cardRowBackgroud.auto,
                            ColorLayout.cardRowBackgroud.auto
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
