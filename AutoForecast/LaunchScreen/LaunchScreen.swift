//
//  LaunchScreen.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct LaunchScreen<RootView: View, Logo: View>: Scene {
    var config: LaunchScreenConfig = .init()
    @ViewBuilder var logo: () -> Logo
    @ViewBuilder var rootContent: RootView
    var body: some Scene {
        WindowGroup {
            rootContent
                .modifier(LaunchScreenModifier(config: config, logo: logo))
        }
    }
}

fileprivate struct LaunchScreenModifier<Logo: View>: ViewModifier {
    var config: LaunchScreenConfig
    @ViewBuilder var logo: Logo
    /// View Properties
    @Environment(\.scenePhase) private var scenePhase
    @State private var splashWindow: UIWindow?
    func body(content: Content) -> some View {
        content
        /// Adding an overlay window so that the splash screen will be visible on top of the entire SwiftUI App.
            .onAppear {
                let scenes = UIApplication.shared.connectedScenes
            
                for scene in scenes {
                    guard let windowScene = scene as? UIWindowScene,
                          checkStates(windowScene.activationState),
                          /// Checkinng the window scene is already habing a Splash Window
                          !windowScene.windows.contains(where: { $0.tag == 1009 })
                    else {
                        print("Already have a Splash Window for this scene")
                        continue
                    }
                    
                    let window = UIWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    let rootViewController = UIHostingController(rootView: LaunchScereenView(config: config) {
                        logo
                    } isCompleted: {
                        /// Hiding Splash Window
                        window.isHidden = true
                        window.isUserInteractionEnabled = false
                    })
                    window.tag = 1009
                    rootViewController.view.backgroundColor = .clear
                    window.rootViewController = rootViewController
                    
                    self.splashWindow = window
                    print("Splash Window Added")
                }
            }
    }
    
    private func checkStates(_ state: UIWindowScene.ActivationState) -> Bool {
        switch scenePhase {
        case .active: return state == .foregroundActive
        case .inactive: return state == .foregroundInactive
        case .background: return state == .background
        default: return state.hashValue == scenePhase.hashValue
        }
    }
        
    
}

/// Lauch Screen Config for More Customization
struct LaunchScreenConfig {
    var initialDelay: Double = 1.2 /// 0.35 default
    var backgroundColor: Color = .black
    var logoBackgroundColor: Color = .white
    var scaling: CGFloat = 4
    var forcheHideLogo: Bool = false
    /// For Even More Customization
    var animation: Animation = .smooth(duration: 1, extraBounce: 0)
}

fileprivate struct LaunchScereenView<Logo: View>: View {
    var config: LaunchScreenConfig
    @ViewBuilder var logo: Logo
    var isCompleted: () -> ()
    /// View Properties
    @State private var scaleDown: Bool = false
    @State private var scaleUp: Bool = false
    var body: some View {
        Rectangle()
            .fill(config.backgroundColor)
            /// Reverse Logo Masking
            .mask {
                GeometryReader {
                    let size = $0.size.applying(.init(scaleX: config.scaling, y: config.scaling))
                    
                    Rectangle()
                        .overlay {
                            logo
                                .blur(radius: config.forcheHideLogo ? 0 : (scaleUp ? 15 : 0))
                                .blendMode(.destinationOut)
                                .animation(.smooth(duration: 0.3, extraBounce: 0)) { content in
                                    content
                                        .scaleEffect(scaleDown ? 0.8 : 1)
                                    
                                }
                                .visualEffect { [scaleUp] content, proxy in
                                    let scaleX: CGFloat = size.width / proxy.size.width
                                    let scaleY: CGFloat = size.height / proxy.size.height
                                    /// Logo Size based scaling
                                    let maxScale = Swift.max(scaleX, scaleY)
                                    
                                    return content
                                        .scaleEffect(scaleUp ? maxScale : 1)
                                }
                            
                        }
                }
            }
            .opacity(config.forcheHideLogo ? 1 : (scaleUp ? 0 : 1))
            .background {
                Rectangle()
                    .fill(config.logoBackgroundColor)
                    /// Hiding Background Gradually as logo is scaling up
                    .opacity(scaleUp ? 0 : 1)
            }
            .ignoresSafeArea()
            .task {
                guard !scaleDown else { return }
                try? await Task.sleep(for: .seconds(config.initialDelay))
                scaleDown = true
                try? await Task.sleep(for: .seconds(0.1))
                withAnimation(config.animation, completionCriteria: .logicallyComplete) {
                    scaleUp = true
                } completion: {
                    isCompleted()
                }
            }
    }
}
