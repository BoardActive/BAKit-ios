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
import Messages
import CoreData

protocol NotificationDelegate: NSObject {
    func appReceivedRemoteNotification(notification: [AnyHashable: Any])
}

private let categoryIdentifier = "PreviewNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    var window: UIWindow?
    
    public weak var notificationDelegate: NotificationDelegate?

    public var badgeNumber = UIApplication.shared.applicationIconBadgeNumber

    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    
    private let notificationCatOptions = UNNotificationCategoryOptions(arrayLiteral: [])
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
      
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        os_log("App Did Finish Launching")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("App Became Active Again")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.sharedInstance.saveContext()
    }
}

extension AppDelegate {
    func setupSDK() {
        BoardActive.client.registerDevice { (parsedJSON, err) in
            guard err == nil else {
                fatalError()
            }
            
            BoardActive.client.userDefaults?.set(true, forKey: String.DeviceRegistered)
            BoardActive.client.userDefaults?.synchronize()
            
            let userInfo = UserInfo.init(fromDictionary: parsedJSON!)
            StorageObject.container.userInfo = userInfo
        }
        
        self.requestNotifications()
        
        BoardActive.client.monitorLocation()
    }
    
    public func requestNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let notificationCenter = UNUserNotificationCenter.current()
        
        if #available(iOS 11.0, *) {
            let previewNotificationCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
            notificationCenter.setNotificationCategories([previewNotificationCategory])
        } else {
            // Fallback on earlier versions
        }
        // Register the notification type.
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            guard error == nil, granted else {
                return
            }
            
            if BoardActive.client.userDefaults?.object(forKey: "dateNotificationPermissionRequested") == nil {
                BoardActive.client.userDefaults?.set(Date().iso8601, forKey: "dateNotificationPermissionRequested")
                BoardActive.client.userDefaults?.synchronize()
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    /**
     Creates an instance of `NotificationModel` from `userInfo`, validates said instance, and calls `createEvent`, capturing the current application state.
     
     - Parameter userInfo: A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`. For more information about the contents of the remote notification dictionary, see Generating a Remote Notification.
     */
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]
        var notificationModel: NotificationModel
        
        if let _ = tempUserInfo["aps"] {
            notificationModel = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: tempUserInfo)
        } else {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            notificationModel = NSEntityDescription.insertNewObject(forEntityName: "NotificationModel", into: context) as! NotificationModel
            notificationModel.body = tempUserInfo["body"] as? String
            notificationModel.messageData = CoreDataStack.sharedInstance.createMessageData(fromDictionary: tempUserInfo)
        }
        notificationModel.date = Date()
        CoreDataStack.sharedInstance.persistentContainer.viewContext.insert(notificationModel)
        
        StorageObject.container.notification = notificationModel
        
        badgeNumber += 1
        application.applicationIconBadgeNumber = badgeNumber
        
        os_log("Notification Model :: %s", notificationModel.debugDescription)
        
        if let _ = notificationModel.aps, let gcmmessageId = notificationModel.gcmmessageId, let firebaseNotificationId = notificationModel.notificationId {
            switch application.applicationState {
            case .active:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
            case .background:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
            case .inactive:
                os_log("%s", String.TappedAndTransitioning)
                BoardActive.client.postEvent(name: String.Opened, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
            default:
                break
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    /**
     This function will be called once a token is available, or has been refreshed. Typically it will be called once per app start, but may be called more often, if a token is invalidated or updated. In this method, you should perform operations such as:
     
     * Uploading the FCM token to your application server, so targeted notifications can be sent.
     * Subscribing to any topics.
     */
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        BoardActive.client.userDefaults?.set(fcmToken, forKey: "deviceToken")
        BoardActive.client.userDefaults?.synchronize()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /**
     Called when app in foreground or background as opposed to `application(_:didReceiveRemoteNotification:)` which is only called in the foreground.
     (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleNotification(application: application, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.badge, .sound, .alert]))
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        os_log("APNs TOKEN :: %s", deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("APNs TOKEN FAIL :: %s", error.localizedDescription)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            return
        }
        
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        
        self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
        
        print(userInfo)
        
        completionHandler()
    }
}
