//
//  Client.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/23/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import Alamofire
import CoreLocation
import FirebaseCore
import FirebaseMessaging
import Foundation
import PromiseKit
import UIKit
import UserNotifications

internal enum EndPoints: String {
    case prod = "https://springer-api.boardactive.com/mobile/v1"
    case events = "/events"
    case me = "/me"
    case locations = "/locations"
}

public class BoardActive: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    public static let client = BoardActive() // BA singleton
    
    // MARK: Client-specific variables
    private static let AppKey = "f80c29ab-dfc6-4cea-af25-19abdae8907"
    private static let AppID = "123"
    private static let IsTestApp = "1"    
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setupEnv()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupEnv()
    }
    
    private func setupEnv() {
        FirebaseApp.configure()
    }
    // [END Init]
    
    public func requestLocations() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        } else {
            let alert = AlertController(title: "Location Services", message: "Enable location services for proper app functionality.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.showAlert()
        }
        
        locationManager.requestAlwaysAuthorization() // asks for location permissions when app in foreground
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("\nLOCATION MANAGER PAUSE\n")
    }
    
    public func requestNotifications(_ application: UIApplication) {
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
        // [END register_for_notifications]
    }
    
    public func onNotificationReceived(callback: ([String: Any]) -> Void) {
        callback(["received": ["world": "test"]])
    }
    
    public func onNotificationOpened(callback: ([String: Any]) -> Void) {
        callback(["opened": ["world": "test"]])
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func handleNotification(_ application: UIApplication, _ userInfo: [AnyHashable: Any]) {
        // TODO: check if 3rd party notifications execute this callback
        let m = Message(userInfo as! [String: Any])
        
        if m.isValidNotification() {
            if application.applicationState == UIApplication.State.active {
                // in FG and receive notification
                print("RECEIVED FOREGROUND")
                createEvent(name: "received", notificationId: m.notificationId ?? "", messageId: m.messageId, promotionId: m.id)
            } else if application.applicationState == UIApplication.State.background {
                // in BG and receive notification
                print("RECEIVED BACKGROUND")
                createEvent(name: "received", notificationId: m.notificationId ?? "", messageId: m.messageId, promotionId: m.id)
            } else if application.applicationState == UIApplication.State.inactive {
                // tap notification from notification center
                print("TAPPED & TRANSITIONING")
                createEvent(name: "opened", notificationId: m.notificationId ?? "", messageId: m.messageId, promotionId: m.id)
            }
        }
    }
    
    // [END Public API]
    
    // [START Overrides]
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation(locations.first!) // only take first
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name(.FCMToken), object: nil, userInfo: dataDict)
        
        UserDefaults.standard.setValue(fcmToken, forKey: .DeviceToken)
        UserDefaults.standard.synchronize()
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        DispatchQueue.global(qos: .userInitiated).async {
            let initialNetworkCallsGroup = DispatchGroup()
            
            initialNetworkCallsGroup.enter()
            self.retrieveMe()
            initialNetworkCallsGroup.leave()
            
            initialNetworkCallsGroup.enter()
            self.requestLocations()
            initialNetworkCallsGroup.leave()
            
            initialNetworkCallsGroup.resume()
        }
    }
    
    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Your FCM registration token: ", fcmToken)
        UserDefaults.standard.setValue(fcmToken, forKey: .DeviceToken)
        UserDefaults.standard.synchronize()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let gcmMessageIDKey = "gcm.message_id"
        
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            UserDefaults.standard.setValue(messageID, forKey: .MessageId)
            UserDefaults.standard.synchronize()
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    // [END Overrides]
    
    // [START Class Functions]
    private func getPath() -> String {
        return EndPoints.prod.rawValue
    }
    
    private func getHeaders() -> HTTPHeaders {
        var tokenString: String
        
        if (UserDefaults.standard.object(forKey: .DeviceToken) as? String) != nil {
            tokenString = (UserDefaults.standard.object(forKey: .DeviceToken) as? String)!
        } else if (UserDefaults.standard.object(forKey: .PreviousDeviceToken) as? String) != nil {
            tokenString = (UserDefaults.standard.object(forKey: .PreviousDeviceToken) as? String)!
        } else {
            tokenString = ""
        }
        
        let headers: HTTPHeaders = [
            "Access-Control-Allow-Origin": String.AllowOrigin,
            "X-BoardActive-App-Id": BoardActive.AppID, // needs to be passed in
            "X-BoardActive-App-Key": BoardActive.AppKey,
            "X-BoardActive-App-Version": String.AppVersion,
            "X-BoardActive-Device-OS": String.iOS, // its a cocoa pod...
            "X-BoardActive-Device-OS-Version": String.SystemVersion,
            "X-BoardActive-Device-Token": tokenString, // fcmTokenStore,
            "X-BoardActive-Device-Type": String.DeviceType,
            "X-BoardActive-Is-Test-App": BoardActive.IsTestApp
        ]
        
        return headers
    }
    
    internal func createEvent(name: String, notificationId: String, messageId: String, promotionId: String) {
        let path = getPath() + EndPoints.events.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "name": name,
            "params": [
                "firebaseNotificationId": notificationId,
                "advertisement_id": messageId,
                "promotion_id": promotionId
            ],
            ]
        
        Alamofire.request(path, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case let .success(json):
                    print("[BA:client:createEvent] OK : ", json)
                case let .failure(error):
                    print("[BA:client:createEvent] ERR : ", error)
                }
        }
    }
    
    internal func updateLocation(_ location: CLLocation) {
        let latitudeString = "\(location.coordinate.latitude)"
        let longitudeString = "\(location.coordinate.longitude)"
        
        let path = getPath() + EndPoints.locations.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "latitude": latitudeString,
            "longitude": longitudeString,
            "deviceTime": Date().iso8601
        ]
        
        Alamofire.request(path, method: .post, parameters: body, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case let .success(json):
                    print("[BA:client:updateLocation] OK : ", json)
                case let .failure(error):
                    print("[BA:client:updateLocation] ERR : ", error)
                }
                NotificationCenter.default.post(name: NSNotification.Name(.InfoUpdateNotification), object: [latitudeString, longitudeString])
        }
    }
    
    internal func retrieveMe() {
        let path = getPath() + EndPoints.me.rawValue
        let headers = getHeaders()
        
        Alamofire.request(path, method: .get, parameters: nil, headers: headers)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case let .success(json):
                    print("[BA:client:me] OK : ", json)
                case let .failure(error):
                    print("[BA:client:me] ERR : ", error)
                }
            })
    }
    
    internal func updateMe(email: String) {
        let path = getPath() + EndPoints.me.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "email": email,
            "deviceOS": String.iOS,
            "deviceOSVersion": String.SystemVersion
        ]
        
        Alamofire.request(path, method: .put, parameters: body, headers: headers)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case let .success(json):
                    print("[BA:client:updateMe] OK : ", json)
                case let .failure(error):
                    print("[BA:client:updateMe] ERR : ", error)
                }
            })
    }
    
    private func JSONStringify(value: [String: Any], prettyPrinted: Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                print("error")
            }
        }
        return ""
    }
    
    // Handles casting raw json from Number to String before AdDrop initialization
    private func castMessageJsonNumbersToStrings(json: [String: Any]) -> [String: Any] {
        var mutatedJson = json
        if let promotionIdNumber = json["promotion_id"] as? NSNumber {
            mutatedJson["promotion_id"] = "\(promotionIdNumber)"
        }
        
        if let messageIdNumber = json["message"] as? NSNumber {
            mutatedJson["advertisement_id"] = "\(messageIdNumber)"
        }
        return mutatedJson
    }
}
