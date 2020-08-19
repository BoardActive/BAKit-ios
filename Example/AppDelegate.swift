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
import CoreLocation

protocol NotificationDelegate: NSObject {
    func appReceivedRemoteNotification(notification: [AnyHashable: Any])
    func appReceivedRemoteNotificationInForeground(notification: [AnyHashable: Any])
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate  {
    var window: UIWindow?
    
    public weak var notificationDelegate: NotificationDelegate?
    private let categoryIdentifier = "PreviewNotification"
    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    
    //Flags use to manage notification behaviour in various states
    var isNotificationStatusActive = false
    var isApplicationInBackground = false
    var isAppActive = false
    var isReceviedEventUpdated = false

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    //App prepare for launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 18.0)!],for: .normal)
        os_log("\n[AppDelegate] didFinishLaunchingWithOptions :: BADGE NUMBER :: %s \n", application.applicationIconBadgeNumber.description)
        application.applicationIconBadgeNumber = 0
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            isNotificationStatusActive = true
            //You have a location when app is in killed/ not running state
            let locationManager = CLLocationManager()
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.distanceFilter = 10
                locationManager.delegate = self
                locationManager.pausesLocationUpdatesAutomatically = false
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startMonitoringSignificantLocationChanges()
        }
        NotificationCenter.default.addObserver(BoardActive.client, selector: #selector(BoardActive.client.updatePermissionStates), name: Notification.Name("Update user permission states"), object: nil)
        return true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _: CLLocationCoordinate2D = manager.location?.coordinate else { return }
         BoardActive.client.postLocation(location: manager.location!)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        isApplicationInBackground = true
        isAppActive = false
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if (isApplicationInBackground) {
            NotificationCenter.default.post(name: Notification.Name("Update user permission states"), object: nil)
        }
        isAppActive = true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("app terminate")
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
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if BoardActive.client.userDefaults?.object(forKey: "dateNotificationRequested") == nil {
                BoardActive.client.userDefaults?.set(Date().iso8601, forKey: "dateNotificationRequested")
                BoardActive.client.userDefaults?.synchronize()
            }
            BoardActive.client.updatePermissionStates()
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
    
    /**
     This delegate method will call when app is in foreground.
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo as! [String: Any]
        
        if userInfo["notificationId"] as? String == "0000001" {
            handleNotification(application: UIApplication.shared, userInfo: userInfo)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("Refresh HomeViewController Tableview"), object: nil, userInfo: userInfo)
        completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.badge, .sound, .alert]))
    }
    
    
    /**
        This delegate method will call when user opens the notifiation from the notification center.
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard (response.actionIdentifier == UNNotificationDefaultActionIdentifier) || (response.actionIdentifier == UNNotificationDismissActionIdentifier) else {
            return
        }
        
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        StorageObject.container.notification = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: userInfo)
        guard let notificationModel = StorageObject.container.notification else {
            return
        }
        
        if isApplicationInBackground && !isNotificationStatusActive {
           isNotificationStatusActive = false
           isApplicationInBackground = false
           if let _ = notificationModel.aps, let _ = notificationModel.messageId, let _ = notificationModel.gcmmessageId, let _ = notificationModel.notificationId {
            if (isReceviedEventUpdated) {
                self.notificationDelegate?.appReceivedRemoteNotificationInForeground(notification: userInfo)
            } else {
                self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
            }
           }
            
        } else if isAppActive && !isNotificationStatusActive {
            
            if (isReceviedEventUpdated) {
                self.notificationDelegate?.appReceivedRemoteNotificationInForeground(notification: userInfo)

            } else {
                self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
            }
            
        } else {
            isNotificationStatusActive = true
            isApplicationInBackground = false
            NotificationCenter.default.post(name: Notification.Name("display"), object: nil)
        }
               
        completionHandler()
    }
    
    /**
     Creates an instance of `NotificationModel` from `userInfo`, validates said instance, and calls `createEvent`, capturing the current application state.
     
     - Parameter userInfo: A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`. For more information about the contents of the remote notification dictionary, see Generating a Remote Notification.
     */
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]
        print("tempuserinfo: \(tempUserInfo)")
        isReceviedEventUpdated = true
        StorageObject.container.notification = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: tempUserInfo)
        
        //if let _ = (window?.rootViewController as? UINavigationController)?.viewControllers.last as? HomeViewController{
            NotificationCenter.default.post(name: NSNotification.Name("Refresh HomeViewController Tableview"), object: nil, userInfo: userInfo)
       // }
        guard let notificationModel = StorageObject.container.notification else {
            return
        }
        
        if let _ = notificationModel.aps, let messageId = notificationModel.messageId, let firebaseNotificationId = notificationModel.gcmmessageId, let notificationId = notificationModel.notificationId {
            switch application.applicationState {
            case .active:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId)
                break
            case .background:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId)
                break
            case .inactive:
                os_log("%s", String.TappedAndTransitioning)
                BoardActive.client.postEvent(name: String.Opened, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId)
                break
            default:
                break
            }
        }
    }
}
