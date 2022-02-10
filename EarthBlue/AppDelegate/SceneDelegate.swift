//
//  SceneDelegate.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 06/11/2021.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: MainView())
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        dismissAlertController()
    }
    
    private func dismissAlertController() {
        guard let currentVC = window?.rootViewController, let _ = currentVC.presentedViewController as? UIAlertController else {return}
        currentVC.dismiss(animated: false, completion: nil)
    }
}

