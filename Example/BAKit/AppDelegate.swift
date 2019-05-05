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
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        BoardActive.client.setupEnvironment(resource: "GoogleService-Info")
        BoardActive.client.requestNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        os_log("App Did Finish Launching")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("App Became Active Again")
    }
}

// [START receive_message]
extension AppDelegate {
    enum Identifiers: String {
        case viewAction = "VIEW_IDENTIFIER"
        case newsCategory = "NEWS_CATEGORY"
    }
    
    /**
     Called when app in foreground or background as opposed to `application(_:didReceiveRemoteNotification:)` which is only called in the foreground.
     (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        BoardActive.client.handleNotification(application: application, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registerCustomActions()
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        os_log("APNs TOKEN :: %s", deviceTokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("Reason for failing remote notifications: %s", error.localizedDescription)
    }
    
    func registerCustomActions() {
        let viewAction = UNNotificationAction(identifier: Identifiers.viewAction.rawValue, title: "View", options: [.foreground])
        
        let newsCategory = UNNotificationCategory(identifier: Identifiers.newsCategory.rawValue, actions: [viewAction], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([newsCategory])

//        BoardActive.client.register(categories: [newsCategory])
    }
}
// [END receive_message]
