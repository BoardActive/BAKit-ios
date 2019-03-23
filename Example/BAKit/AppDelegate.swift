//
//  AppDelegate.swift
//  BAKit
//
//  Created by HVNT on 08/23/2018.
//  Copyright (c) 2018 HVNT. All rights reserved.
//

import BAKit
import Firebase
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BoardActive.client.requestNotifications(application)
        return true
    }

    // From Apple docs: Unlike the application(_:didReceiveRemoteNotification:) method, which is called only when your app is running in the foreground, the system calls this method when your app is running in the foreground or background. (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        BoardActive.client.handleNotification(application, userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    // [END receive_message]

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print(deviceTokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Reason for failing remote notifications:  \(error)")
    }
}
