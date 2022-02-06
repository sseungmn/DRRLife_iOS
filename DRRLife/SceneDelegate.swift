//
//  SceneDelegate.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let mainViewController = ViewController()
        
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
    }
}

