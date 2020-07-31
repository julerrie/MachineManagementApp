//
//  AppDelegate.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/14.
//  Copyright © 2020 julerrie. All rights reserved.
//

import UIKit
import MetricKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MXMetricManagerSubscriber {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MXMetricManager.shared.add(self)
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        MXMetricManager.shared.remove(self)
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            let payloadDict = payload.dictionaryRepresentation()
            print(payloadDict)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

