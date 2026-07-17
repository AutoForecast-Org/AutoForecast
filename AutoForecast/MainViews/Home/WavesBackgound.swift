//
//  WavesBackgound.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct WavesBackground: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                WaveShape3()
//                    .fill(LinearGradient(
//                        gradient: Gradient(colors: [Color(red:0.82, green:0.92, blue:1.0), Color(red:0.95, green:0.98, blue:1.0)]),
//                        startPoint: .top,
//                        endPoint: .bottom))
                    .fill(gradient(for: .top))
                    .frame(height: geo.size.height / 3)
                    .offset(y: geo.size.height * 0.05)
                WaveShape2()
//                    .fill(LinearGradient(
//                        gradient: Gradient(colors: [Color(red:0.68, green:0.85, blue:0.98), Color(red:0.85, green:0.95, blue:1.0)]),
//                        startPoint: .top,
//                        endPoint: .bottom))
                    .fill(gradient(for: .middle))
                    .frame(height: geo.size.height / 3.5)
                    .offset(y: geo.size.height * 0.03)
                WaveShape1()
//                    .fill(LinearGradient(
//                        gradient: Gradient(colors: [Color(red:0.29, green:0.65, blue:0.97), Color(red:0.61, green:0.81, blue:0.98)]),
//                        startPoint: .top,
//                        endPoint: .bottom))
                    .fill(gradient(for: .bottom))
                    .frame(height: geo.size.height / 4)
            }
            .ignoresSafeArea()
        }
    }
}

private enum WaveLevel {
    case top
    case middle
    case bottom
}

struct WaveShape1: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.8))
        path.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.6),
                      control1: CGPoint(x: rect.width * 0.25, y: rect.height * 0.9),
                      control2: CGPoint(x: rect.width * 0.75, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}

struct WaveShape2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.75))
        path.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.95),
                      control1: CGPoint(x: rect.width * 0.2, y: rect.height * 0.85),
                      control2: CGPoint(x: rect.width * 0.8, y: rect.height * 1.1))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}
struct WaveShape3: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.85))
        path.addCurve(to: CGPoint(x: rect.width, y: rect.height * 1.00),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.9),
                      control2: CGPoint(x: rect.width * 0.7, y: rect.height * 1.22))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}

private extension WavesBackground {

    func gradient(for level: WaveLevel) -> LinearGradient {

        let lightGradients = (
            top:    Gradient(colors: [Color(red:0.29, green:0.65, blue:0.97),
                                      Color(red:0.61, green:0.81, blue:0.98)]),
            middle: Gradient(colors: [Color(red:0.68, green:0.85, blue:0.98),
                                      Color(red:0.85, green:0.95, blue:1.0)]),
            bottom: Gradient(colors: [Color(red:0.82, green:0.92, blue:1.0),
                                      Color(red:0.95, green:0.98, blue:1.0)])
        )

        let darkGradients = (
            top:    Gradient(colors: [Color(red:0.82, green:0.92, blue:1.0),
                                      Color(red:0.95, green:0.98, blue:1.0)]),
            middle: Gradient(colors: [Color(red:0.68, green:0.85, blue:0.98),
                                      Color(red:0.85, green:0.95, blue:1.0)]),
            bottom: Gradient(colors: [Color(red:0.29, green:0.65, blue:0.97),
                                      Color(red:0.61, green:0.81, blue:0.98)])
        )

        let gradients = colorScheme == .light ? lightGradients : darkGradients

        let selected: Gradient
        switch level {
        case .top:    selected = gradients.top
        case .middle: selected = gradients.middle
        case .bottom: selected = gradients.bottom
        }

        return LinearGradient(
            gradient: selected,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
