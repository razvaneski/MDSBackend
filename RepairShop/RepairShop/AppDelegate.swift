//
//  AppDelegate.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 24.04.2023.
//

import UIKit
import netfox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NFX.sharedInstance().setGesture(.custom)
        NFX.sharedInstance().start()
        window?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(showNFX)))
        
        return true
    }

    @objc private func showNFX() {
        NFX.sharedInstance().show()
    }


}

