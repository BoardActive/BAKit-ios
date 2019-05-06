//
//  BoardActive.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/23/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import CoreLocation
import FirebaseCore
import FirebaseMessaging
import Foundation
import PromiseKit
import UIKit
import UserNotifications

import os.log

public protocol BoardActiveDelegate: AnyObject {
    /**
     The means by which BoardActive passes it's received notification to the conforming object.
     
     - Parameter notification: `UNNotification` The received push notification that has been tapped or otherwise selected by the user for display.
     */
    func appReceivedRemoteNotification(notification: UNNotification)
}

public enum ActionIdentifier: String {
    case accept
    case cancel
}

/**
 Dev and prod base urls plus their associated endpoints.
 */
public enum EndPoints: String {
    case dev       = "https://springer-api.boardactive.com/mobile/v1"
    case prod      = "https://api.boardactive.com/mobile/v1"
    case events    = "/events"
    case me        = "/me"
    case locations = "/locations"
}

/**
 A succinct means of denoting which `CLLocationManager` permission the app will request from the user.
 */
public enum AuthorizationMode: String {
    case always
    case whenInUse
}


public class BoardActive: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate, CLLocationManagerDelegate {
    /**
     A property returning the BoardActive singleton.
     */
    public static let client = BoardActive()
    
    /**
     The class that conforms to the BoardActiveDelegate protocol, receiving `UNNotifications` immediately following user interaction with said notifications.
     */
    public weak var delegate: BoardActiveDelegate?

    /**
     The app's badge number.
     */
    public var badgeNumber = UIApplication.shared.applicationIconBadgeNumber
    
    private var locationManager = CLLocationManager()
    private let authOptions = UNAuthorizationOptions.init(arrayLiteral: [.alert, .badge, .sound])
    private let notificationOptions = UNNotificationPresentationOptions(arrayLiteral: [.alert, .badge, .sound])
    private lazy var configValues: Dictionary<String, String>? = {
        return populateConfigDictionary()
    }()
    private var initialLocation :CLLocation?
    private var updatedUserLocation :CLLocation?
    private var distanceBetweenLocations: CLLocationDistance?


    /**
     Utilizes the a property list to instantiate `FirebaseOptions` before calling `FirebaseApp.configure(options:)` on those options.
     
     - parameter resource: The `String` name of a property list in the main bundle containing the data necessary to configure a `FirebaseApp`.
     */
    public func setupEnvironment(resource: String) {
        let path = Bundle.main.path(forResource: resource, ofType: "plist")
        let options = FirebaseOptions(contentsOfFile: path!)!

        FirebaseApp.configure(options: options)
    }
    // [END Init]

    /**
     Sets the BoardActive `CLLocationManager`'s delegate property to BoardActive.client. Configures BoardActive's `CLLocationManager` to allow background location updates, _not_ pause location updates automatically, sets `desiredAccuracy` to `kCLLocationAccuracyBest`, requests always authorization, and starts updating locations.
     */
    public func requestLocations(authorizationMode:AuthorizationMode) {
        locationManager.delegate = self
        locationManager.activityType = .other
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        if authorizationMode == AuthorizationMode.always {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /**
     Functions as an as needed means of procuring the user's current location. If regular locations updates provide a better solution, call `requestLocations(authorizationMode:AuthorizationMode)`.
     - Returns: `CLLocation?` An optional `CLLocation` obtained by `CLLocationManager's` `requestLocation()` function.
     */
    public func getCurrentLocations() -> CLLocation? {
        self.locationManager.requestLocation()
        guard let location = self.locationManager.location else {
            return nil
        }
        return location
    }
    
    /**
     Calls `stopUpdatingLocation` on BoardActive's private CLLocationManager property.
     */
    public func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }

    /**
     Sets `UNUserNotificationCenterDelegate` and `MessagingDelegate` to self. Requests user push notification authorization via the `UNUserNotificationCenter` and registers for remote notifications.
     */
    public func requestNotifications() {
        // [START set_userNotification_delegate]
        UNUserNotificationCenter.current().delegate = self
        // [END set_userNotification_delegate]

        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]

        // [START register_for_notifications]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            guard error == nil, granted else {
                return
            }
        }

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        // [END register_for_notifications]
    }

    /**
     Registers your app’s notification types and the custom actions that they support.
    
     - Parameter categories: An array of `UNNotificationCategory`.
     */
    public func register(categories: [UNNotificationCategory]) {
        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }

    /**
     Creates an instance of `NotificationModel` from `userInfo`, validates said instance, and calls `createEvent`, capturing the current application state.
     
     - Parameter userInfo: A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`. For more information about the contents of the remote notification dictionary, see Generating a Remote Notification.
     */
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]
        let notificationModel = NotificationModel(object: tempUserInfo)
    
        badgeNumber += 1
        application.applicationIconBadgeNumber = badgeNumber
        
        os_log("Notification Model :: %s", notificationModel.dictionaryRepresentation().debugDescription)

        if notificationModel.isValidNotification() {
            switch application.applicationState {
            case .active:
                os_log("%s", String.ReceivedBackground)
                createEvent(name: String.Received, googleMessageId: notificationModel.gcmMessageId!, messageId: notificationModel.messageId!)
            case .background:
                os_log("%s", String.ReceivedBackground)
                createEvent(name: String.Received, googleMessageId: notificationModel.gcmMessageId!, messageId: notificationModel.messageId!)
            case .inactive:
                os_log("%s", String.TappedAndTransitioning)
                createEvent(name: String.Opened, googleMessageId: notificationModel.gcmMessageId!, messageId: notificationModel.messageId!)
            default:
                break
            }
        }
    }
    
    /**
     This method will be called once a token is available, or has been refreshed. Typically it will be called once per app start, but may be called more often, if token is invalidated or updated. In this method, you should perform operations such as:
     
     * Uploading the FCM token to your application server, so targeted notifications can be sent.
     * Subscribing to any topics.
     */
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        os_log("BoardActive :: Firebase token: %s", fcmToken)
        
        let dataDict: [String: String] = [String.Token: fcmToken]
        NotificationCenter.default.post(name: Notification.Name(.FCMToken), object: nil, userInfo: dataDict)
        
        UserDefaults.standard.setValue(fcmToken, forKey: .DeviceToken)
        UserDefaults.standard.synchronize()
        
        let operationQueue = OperationQueue()
        
        let retrieveMeOp = BlockOperation {
            self.updateMe(email: nil)
        }
        
        let requestLocationsOp = BlockOperation {
            self.requestLocations(authorizationMode: AuthorizationMode.always)
        }
        requestLocationsOp.addDependency(retrieveMeOp)
        
        operationQueue.addOperations([retrieveMeOp, requestLocationsOp], waitUntilFinished: true)
    }
    // [END Public API]
    
    // [START Overrides]
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if initialLocation == nil {
            initialLocation = locations.last!
        }
        updatedUserLocation = locations.last!
        distanceBetweenLocations =  updatedUserLocation!.distance(from: initialLocation!)
        
        os_log("DISTANCE TRAVELED :: %s", distanceBetweenLocations!.debugDescription)
        if distanceBetweenLocations! >= 5.0 {
            updateLocation(location: locations.last!)
        }
        
        initialLocation = locations.last!
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        os_log("Location manager failed with error: %s", error.localizedDescription)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("CLAuthorizationStatus :: %d", status.rawValue)
//        var locationAuthorizationStatus = status
    }

    /**
     This method is called on iOS 10+ devices to handle data messages received via FCM direct channel (not via APNS). For iOS 9 and below, the direct channel data message is handled by the UIApplicationDelegate's -application:didReceiveRemoteNotification: method. You can enable all direct channel data messages to be delivered in FIRMessagingDelegate by setting the flag `useMessagingDelegateForDirectMessages` to true.
     */
    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        os_log("MESSAGING %s", messaging.fcmToken!.debugDescription)
        
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        os_log("willPresent")
        completionHandler(notificationOptions)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                
        UIApplication.shared.applicationIconBadgeNumber = UserDefaults.extensions!.badge
//        switch response.actionIdentifier {
//        case accept:
//            let cancelAction = UNNotificationAction(identifier: cancel, title: "Cancel")
//            let currentActions = extensionContext?.notificationActions ?? []
//            extensionContext?.notificationActions = currentActions.map {
//                $0.identifier == accept ? cancelAction : $0
//            }
//        case cancel:
//            let acceptAction = UNNotificationAction(identifier: accept,
//                                                    title: "Accept")
//            let currentActions = extensionContext?.notificationActions ?? []
//            extensionContext?.notificationActions = currentActions.map {
//                $0.identifier == cancel ? acceptAction : $0
//            }
//        default:
//            break
//        }
        
//        completion(.doNotDismiss)
        
        guard response.actionIdentifier != UNNotificationDefaultActionIdentifier || response.actionIdentifier !=
            "VIEW_IDENTIFIER" else {
            return
        }

        
        
        BoardActive.client.delegate?.appReceivedRemoteNotification(notification: response.notification)
        completionHandler()
    }
//    }

    // MARK: Class Functions

    fileprivate func getPath() -> String? {
        return EndPoints.dev.rawValue
    }

    fileprivate func getHeaders() -> HTTPHeaders {
        guard let tokenString = UserDefaults.standard.object(forKey: .DeviceToken) as? String else {
            return HTTPHeaders.init()
        }

        if configValues?[String.ConfigKeys.UUID.rawValue] == nil {
            configValues?[String.ConfigKeys.UUID.rawValue] = UIDevice.current.identifierForVendor?.uuidString
        }

        let headers: HTTPHeaders = [
            String.HeaderKeys.AccessControl.rawValue: String.AllowOrigin,
            String.HeaderKeys.AppId.rawValue: configValues?[String.ConfigKeys.AppId.rawValue] ?? "", // needs to be passed in
            String.HeaderKeys.AppKey.rawValue: configValues?[String.ConfigKeys.AppKey.rawValue] ?? "",
            String.HeaderKeys.AppVersion.rawValue: String.AppVersion,
            String.HeaderKeys.DeviceOS.rawValue: String.iOS, // its a cocoa pod...
            String.HeaderKeys.DeviceOSVersion.rawValue: String.SystemVersion,
            String.HeaderKeys.DeviceToken.rawValue: tokenString, // fcmTokenStore,
            String.HeaderKeys.DeviceType.rawValue: String.DeviceType,
            String.HeaderKeys.UUID.rawValue: configValues?[String.ConfigKeys.UUID.rawValue] ?? ""
        ]

        return headers
    }

    /**
     Creates an Event using the information provided and then logs said Event to the BoardActive server.
     
     - Parameter name: `String`
     - Parameter googleMessageId: `String` The value associated with key "gcm.message_id" in notifications.
     - Parameter messageId: `String` The value associated with the key "messageId" in notifications.
     */
    public func createEvent(name: String, googleMessageId: String, messageId: String) {
        guard let pathString = getPath() else {
            os_log("[BA:client:createEvent] Path string nil")
            return
        }

        let path = pathString + EndPoints.events.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "name": name,
            "messageId": messageId,
            "inbox": Dictionary<String, String>(),
            "firebaseNotificationId": googleMessageId
        ]

        Alamofire.request(path, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseSwiftyJSON { response in
                switch response.result {
                case let .success(json):
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                                response.data!, options: [])
                        guard let jsonArray = jsonResponse as? [[String: Any]] else {
                            return
                        }
//                        print(jsonArray)
//                        print("JSON Array :: \(jsonArray.debugDescription)")
                        //Response result
                    } catch let parsingError {
                        os_log("[BA:client:createEvent] Parsing Error :: %s", parsingError.localizedDescription)
                    }
                    os_log("[BA:client:createEvent] OK : %s", json.debugDescription)
                case let .failure(error):
                    os_log("[BA:client:createEvent] ERR : %s", error.localizedDescription)
                }
        }
    }

    /**
     Derives a latitude and longitude from the location parameter, couples the coordinate with an iso8601 formatted date, and then updates the server and database with user's timestamped location.
     
     - Parameter location: `CLLocation` The user's current location.
     */
    public func updateLocation(location: CLLocation) {
        let latitudeString = "\(location.coordinate.latitude)"
        let longitudeString = "\(location.coordinate.longitude)"

        guard let pathString = getPath() else {
            os_log("[BA:client:updateLocation] Path string nil")
            return
        }

        let path = pathString + EndPoints.locations.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            String.Latitude: latitudeString,
            String.Longitude: longitudeString,
            String.DeviceTime: Date().iso8601
        ]

        Alamofire.request(path, method: .post, parameters: body, headers: headers)
            .validate()
            .responseSwiftyJSON { response in
                switch response.result {
                case let .success(json):
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                                response.data!, options: [])
                        guard let jsonArray = jsonResponse as? [String:Any] else {
                            return
                        }
                        os_log("[BA:client:updateLocation] :: jsonArray :: %s", jsonArray.debugDescription)
                    } catch let parsingError {
                        print("[BA:client:updateLocation] Parsing Error", parsingError)
                    }
                    os_log("[BA:client:updateLocation] OK : %s", json.debugDescription)
                case let .failure(error):
                    os_log("[BA:client:updateLocation] ERR : %s", error.localizedDescription)
                }
                NotificationCenter.default.post(name: NSNotification.Name(.InfoUpdateNotification), object: [latitudeString, longitudeString])
        }
    }

    /**
     A means of updating the user's associated data.
     
     - Parameter email: `String` An email that will be associated with the user on the server then saved to the database.
     */
    public func updateMe(email: String? = nil) {
        guard let pathString = getPath() else {
            os_log("[BA:client:updateMe] Path string nil")
            return
        }

        let path = pathString + EndPoints.me.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            String.StockAttributes.email.rawValue: email ?? "",
            String.StockAttributes.deviceOS.rawValue: String.iOS,
            String.StockAttributes.deviceOSVersion.rawValue: String.SystemVersion
        ]
        
        configValues![String.StockAttributes.email.rawValue] = email

        Alamofire.request(path, method: .put, parameters: body, headers: headers)
            .validate()
            .responseSwiftyJSON(completionHandler: { response in
                switch response.result {
                case let .success(json):
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                                response.data!, options: [])
                        guard let jsonArray = jsonResponse as? [[String: Any]] else {
                            return
                        }
                    } catch let parsingError {
//                        print("[BA:client:updateMe] Parsing Error", parsingError)
                    }
                    os_log("[BA:client:updateMe] OK : %s", json.debugDescription)
                case let .failure(error):
                    os_log("[BA:client:updateMe] ERR : %s", error.localizedDescription)
                }
            })
    }

    fileprivate func populateConfigDictionary() -> Dictionary<String, String>? {
        var configs: Dictionary<String, String>?

        guard let path = Bundle.main.path(forResource: "BoardActive-Credentials", ofType: "plist") else {
            return nil
        }

        if let xml = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(BoardActiveCredentials.self, from: xml) {
            configs = preferences.dictionaryRepresentation() as? Dictionary<String, String>
        }
        
        os_log("[BA:client:populateConfigDictionary] Config Values: %s", [String.ConfigKeys.AppId.rawValue: configs?[String.ConfigKeys.AppId.rawValue], String.ConfigKeys.AppKey.rawValue: configs?[String.ConfigKeys.AppKey.rawValue], EndPoints.dev: configs?[EndPoints.dev.rawValue]].debugDescription)
        return configs
    }
}
