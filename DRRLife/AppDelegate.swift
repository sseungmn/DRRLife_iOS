//
//  AppDelegate.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import UIKit
import NMapsMap
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NMFAuthManager.shared().clientId = Bundle.main.NMFClientId
        
        FirebaseApp.configure()
        
        sleep(1)
        return true
    }

}

