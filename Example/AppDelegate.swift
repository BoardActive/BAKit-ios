//
//  AppDelegate.swift
//  AdDrop
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    var window: UIWindow?
    
    public weak var notificationDelegate: NotificationDelegate?
    
    private let basicCategoryIdentifier = "Basic"
    private let bigPictureategoryIdentifier = "Big Picture"
    private let actionButtonCategoryIdentifier = "Action Button"
    private let bigTextCategoryIdentifier = "Big Text"
    private let inboxStyleCategoryIdentifier = "Inbox Style"
    
    private enum ActionIdentifier: String {
        case accept, reject
    }
    
    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        application.setMinimumBackgroundFetchInterval(600)
        
        BoardActive.client.stopMonitoringSignificantLocationChanges()

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 18.0)!],for: .normal)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        os_log("\n[AppDelegate] didFinishLaunchingWithOptions :: DATABASE LOCATION :: %s \n", paths[0].debugDescription)
        application.applicationIconBadgeNumber = UserDefaults.extensions.badge

        os_log("\n[AppDelegate] didFinishLaunchingWithOptions :: BADGE NUMBER :: %s \n", application.applicationIconBadgeNumber.description)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("DID BECOME ACTIVE")
        os_log("\n[AppDelegate] applicationDidBecomeActive :: BADGE NUMBER INITIAL :: %s \n", application.applicationIconBadgeNumber.description)

        let badgeCount = 0
        UserDefaults.extensions.badge = badgeCount
        UserDefaults.extensions.synchronize()
        
        application.applicationIconBadgeNumber = badgeCount
        
        os_log("\n[AppDelegate] applicationDidBecomeActive :: BADGE NUMBER FINAL :: %s \n", application.applicationIconBadgeNumber.description)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.sharedInstance.saveContext()
        
        let currentLocation = BoardActive.client.currentLocation
        BoardActive.client.createRegion(location: currentLocation, start: true)
        
        BoardActive.client.startMonitoringSignificantLocationChanges()
    }
    
    private func registerCustomCategory() {
        var basicNotificationCategory: UNNotificationCategory
        var bigPictureCategory: UNNotificationCategory
        var actionButtonCategory: UNNotificationCategory
        var bigTextCategory: UNNotificationCategory
        var inboxCategory: UNNotificationCategory
        
        let accept = UNNotificationAction(identifier: ActionIdentifier.accept.rawValue, title: "Accept")
        let reject = UNNotificationAction(identifier: ActionIdentifier.reject.rawValue, title: "Reject")
        
        if #available(iOS 11.0, *) {
            basicNotificationCategory = UNNotificationCategory(identifier: basicCategoryIdentifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
            bigPictureCategory = UNNotificationCategory(identifier: bigPictureategoryIdentifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
            actionButtonCategory = UNNotificationCategory(identifier: actionButtonCategoryIdentifier, actions: [accept, reject], intentIdentifiers: [])
            bigTextCategory = UNNotificationCategory(identifier: bigTextCategoryIdentifier, actions: [], intentIdentifiers: [])
            inboxCategory = UNNotificationCategory(identifier: inboxStyleCategoryIdentifier, actions: [], intentIdentifiers: [])
        } else {
            basicNotificationCategory = UNNotificationCategory(identifier: basicCategoryIdentifier, actions: [], intentIdentifiers: [])
            bigPictureCategory = UNNotificationCategory(identifier: bigPictureategoryIdentifier, actions: [], intentIdentifiers: [])
            actionButtonCategory = UNNotificationCategory(identifier: actionButtonCategoryIdentifier, actions: [accept, reject], intentIdentifiers: [])
            bigTextCategory = UNNotificationCategory(identifier: bigTextCategoryIdentifier, actions: [], intentIdentifiers: [])
            inboxCategory = UNNotificationCategory(identifier: inboxStyleCategoryIdentifier, actions: [], intentIdentifiers: [])
        }
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([basicNotificationCategory, bigPictureCategory, actionButtonCategory, bigTextCategory, inboxCategory])
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Request that BoardActive's CLLocationManager update location
//        BoardActive.client.requestLocation()
        
        completionHandler(.newData)
    }
}

extension AppDelegate {
    func setupSDK() {
        let operationQueue = OperationQueue()
        let registerDeviceOperation = BlockOperation.init {
            BoardActive.client.registerDevice { (parsedJSON, err) in
                guard err == nil, let parsedJSON = parsedJSON else {
                    fatalError()
                }
                
                BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
                BoardActive.client.userDefaults?.synchronize()
                
                let userInfo = UserInfo.init(fromDictionary: parsedJSON)
                StorageObject.container.userInfo = userInfo
            }
        }
       
        let requestNotificationsOperation = BlockOperation.init {
            self.requestNotifications()
        }
        
        let monitorLocationOperation = BlockOperation.init {
            DispatchQueue.main.async {
                BoardActive.client.monitorLocation()
            }
        }
        
        monitorLocationOperation.addDependency(requestNotificationsOperation)
        requestNotificationsOperation.addDependency(registerDeviceOperation)
        
        operationQueue.addOperation(registerDeviceOperation)
        operationQueue.addOperation(requestNotificationsOperation)
        operationQueue.addOperation(monitorLocationOperation)
    }
    
    public func requestNotifications() {
        registerCustomCategory()
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if BoardActive.client.userDefaults?.object(forKey: "dateNotificationPermissionRequested") == nil {
                BoardActive.client.userDefaults?.set(Date().iso8601, forKey: "dateNotificationPermissionRequested")
                BoardActive.client.userDefaults?.synchronize()
            }

            guard error == nil, granted else {
                return
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
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
        os_log("\n[AppDelegate] didReceiveRegistrationToken :: Firebase registration token: %s \n", fcmToken.debugDescription)
        BoardActive.client.userDefaults?.set(fcmToken, forKey: "deviceToken")
        BoardActive.client.userDefaults?.synchronize()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        os_log("\n[AppDelegate] didRegisterForRemoteNotificationsWithDeviceToken :: \nAPNs TOKEN: %s \n", deviceTokenString)
                
        self.registerCustomCategory()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle error
        os_log("\n[AppDelegate] didFailToRegisterForRemoteNotificationsWithError :: \nAPNs TOKEN FAIL :: %s \n", error.localizedDescription)
    }
    
    /**
     Called when app in foreground or background as opposed to `application(_:didReceiveRemoteNotification:)` which is only called in the foreground.
     (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        handleNotification(application: application, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo as! [String: Any]
        
        if userInfo["notificationId"] as? String == "0000001" {
            handleNotification(application: UIApplication.shared, userInfo: userInfo)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("Refresh HomeViewController Tableview"), object: nil, userInfo: userInfo)
        completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.badge, .sound, .alert]))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        guard (response.actionIdentifier == UNNotificationDefaultActionIdentifier) || (response.actionIdentifier == UNNotificationDismissActionIdentifier) else {
            return
        }
        
        BoardActive.client.postEvent(name: String.Opened, messageId: StorageObject.container.notification!.messageId!, firebaseNotificationId: StorageObject.container.notification!.gcmmessageId!)
        print("[AppDelegate] userNotificationCenter:didReceive: :: TAPPED & TRANSITIONING")
        
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        
        self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
        
        print("[AppDelegate] userNotificationCenter:didReceive: :: User Info: \(userInfo)")
        
        completionHandler()
    }
    
    /**
     Creates an instance of `NotificationModel` from `userInfo`, validates said instance, and calls `createEvent`, capturing the current application state.
     
     - Parameter userInfo: A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`. For more information about the contents of the remote notification dictionary, see Generating a Remote Notification.
     */
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]
        
        StorageObject.container.notification = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: tempUserInfo)
        
        guard let notificationModel = StorageObject.container.notification else {
            return
        }
        
        if let _ = notificationModel.aps, let messageId = notificationModel.messageId, let firebaseNotificationId = notificationModel.gcmmessageId {
            print("\n[AppDelegate] handleNotification :: Application State: \(application.applicationState.rawValue)\n")
            switch application.applicationState {
            case .active:
                print("\n[AppDelegate] handleNotification :: RECEIVED ACTIVE")
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
                break
            case .background:
                print("\n[AppDelegate] handleNotification :: RECEIVED BACKGROUND")
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
                break
            case .inactive:
                print("\n[AppDelegate] handleNotification :: RECEIVED INACTIVE\n")
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
                break
            default:
                break
            }
        }
    }
}
