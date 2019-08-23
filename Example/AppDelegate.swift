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

    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    
    private let notificationCatOptions = UNNotificationCategoryOptions(arrayLiteral: [])
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.applicationIconBadgeNumber = UserDefaults.extensions.badge
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        os_log("App Did Finish Launching")
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 18.0)!],for: .normal)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print("DATABASE LOCATION :: \(paths[0])")
        print("BADGE NUMBER :: \(application.applicationIconBadgeNumber)")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("App Became Active Again")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.sharedInstance.saveContext()
    }
    
    private func registerCustomCategory() {
        var previewNotificationCategory: UNNotificationCategory
        if #available(iOS 11.0, *) {
            previewNotificationCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
        } else {
            previewNotificationCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [], intentIdentifiers: [])
        }
        UNUserNotificationCenter.current().setNotificationCategories([previewNotificationCategory])
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
        print("HANDLE NOTIFICATION CALLED")
        let tempUserInfo = userInfo as! [String: Any]
        
        StorageObject.container.notification = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: tempUserInfo)
        
        guard let notificationModel = StorageObject.container.notification else {
            return
        }

//        } else {
//            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
//            notificationModel = NSEntityDescription.insertNewObject(forEntityName: "NotificationModel", into: context) as! NotificationModel
//            notificationModel.body = tempUserInfo["body"] as? String
//            notificationModel.messageData = CoreDataStack.sharedInstance.createMessageData(fromDictionary: tempUserInfo)
//        }
//        CoreDataStack.sharedInstance.persistentContainer.viewContext.insert(notificationModel)
        
        
        os_log("Notification Model :: %s", notificationModel.debugDescription)
        
        if let _ = notificationModel.aps, let gcmmessageId = notificationModel.gcmmessageId, let firebaseNotificationId = notificationModel.notificationId {
            switch application.applicationState {
            case .active:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
                break
            case .background:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
                break
            case .inactive:
                os_log("%s", String.TappedAndTransitioning)
                BoardActive.client.postEvent(name: String.Opened, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
                break
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
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        os_log("APNs TOKEN :: %s", deviceTokenString)
        DispatchQueue.main.async {
            self.registerCustomCategory()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("APNs TOKEN FAIL :: %s", error.localizedDescription)
    }
    
    /**
     Called when app in foreground or background as opposed to `application(_:didReceiveRemoteNotification:)` which is only called in the foreground.
     (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification CALLED")

        handleNotification(application: application, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent CALLED")
        NotificationCenter.default.post(Notification(name: Notification.Name("Refresh HomeViewController Tableview")))
        completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.badge, .sound, .alert]))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive CALLED")

        guard (response.actionIdentifier == UNNotificationDefaultActionIdentifier) || (response.actionIdentifier == UNNotificationDismissActionIdentifier) else {
            return
        }
        
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        
        self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
        
        print(userInfo)
        
        completionHandler()
    }
}
