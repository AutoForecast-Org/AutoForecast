//
//  OrientationLockView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct OrientationLockView<Content: View>: View {
    let content: Content
    let forcedOrientation: UIInterfaceOrientationMask?
    
    init(forcedOrientation: UIInterfaceOrientationMask? = nil, @ViewBuilder content: () -> Content) {
        self.forcedOrientation = forcedOrientation
        self.content = content()
    }
    
    var body: some View {
        content
            .onAppear {
                if let orientation = forcedOrientation {
                    AppDelegate.orientationLock = orientation
                    if orientation.contains(.landscape) {
                        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    } else if orientation.contains(.portrait) {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    }
                    setNeedsUpdateOfSupportedInterfaceOrientationsOnRootViewController()
                }
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
                setNeedsUpdateOfSupportedInterfaceOrientationsOnRootViewController()
            }
    }
}

struct OrientationHelper {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            (scene.delegate as? UIWindowSceneDelegate)?.window??.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
        AppDelegate.orientationLock = orientation
        setNeedsUpdateOfSupportedInterfaceOrientationsOnRootViewController()
    }
    
    static func unlockOrientation() {
        AppDelegate.orientationLock = .portrait
    }
}
private func setNeedsUpdateOfSupportedInterfaceOrientationsOnRootViewController() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
        rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
