//
//  BoardActive.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/23/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import CoreLocation
import FirebaseCore
import FirebaseMessaging
import Foundation
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
    case events = "/events"
    case me = "/me"
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

    private var appKey = ""
    private var appId = ""

    private var locationManager = CLLocationManager()
    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    private let notificationOptions = UNNotificationPresentationOptions(arrayLiteral: [.alert, .badge, .sound])
    private var initialLocation: CLLocation?
    private var updatedUserLocation: CLLocation?
    private var distanceBetweenLocations: CLLocationDistance?

    /**
     Utilizes the a property list to instantiate `FirebaseOptions` before calling `FirebaseApp.configure(options:)` on those options.

     - parameter resource: The `String` name of a property list in the main bundle containing the data necessary to configure a `FirebaseApp`.
     */
    public func setupEnvironment(appID: String, appKey: String) {
        appId = appID
        self.appKey = appKey
        FirebaseApp.configure()
    }

    /**
     Sets the BoardActive `CLLocationManager`'s delegate property to BoardActive.client. Configures BoardActive's `CLLocationManager` to allow background location updates, _not_ pause location updates automatically, sets `desiredAccuracy` to `kCLLocationAccuracyBest`, requests always authorization, and starts updating locations.
     */
    public func requestLocations() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .denied:
            locationManager.requestAlwaysAuthorization()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            locationManager.requestAlwaysAuthorization()
            break
        default:
            break
        }

//        locationManager.requestAlwaysAuthorization() // asks for location permissions when app in foreground
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    /**
     Functions as an as needed means of procuring the user's current location. If regular locations updates provide a better solution, call `requestLocations(authorizationMode:AuthorizationMode)`.
     - Returns: `CLLocation?` An optional `CLLocation` obtained by `CLLocationManager's` `requestLocation()` function.
     */
    public func getCurrentLocations() -> CLLocation? {
        locationManager.requestLocation()
        guard let location = self.locationManager.location else {
            return nil
        }
        return location
    }

    /**
     Calls `stopUpdatingLocation` on BoardActive's private CLLocationManager property.
     */
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /**
     Sets `UNUserNotificationCenterDelegate` and `MessagingDelegate` to self. Requests user push notification authorization via the `UNUserNotificationCenter` and registers for remote notifications.
     */
    public func requestNotifications() {
        UNUserNotificationCenter.current().delegate = self

        Messaging.messaging().delegate = self

        // Allows Firebase to target only those devices subscribed to the included topic
//        Messaging.messaging().subscribe(toTopic: "topic") { _ in
//            print("description")
//        }

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            guard error == nil, granted else {
                return
            }
        }

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
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
        let notificationModel = NotificationModel(fromDictionary: tempUserInfo)

        badgeNumber += 1
        application.applicationIconBadgeNumber = badgeNumber

        os_log("Notification Model :: %s", notificationModel.toDictionary().debugDescription)

        if let _ = notificationModel.aps, let gcmmessageId = notificationModel.gcmmessageId, let firebaseNotificationId = notificationModel.notificationId {
            switch application.applicationState {
            case .active:
                os_log("%s", String.ReceivedBackground)
                createEvent(name: String.Received, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
            case .background:
                os_log("%s", String.ReceivedBackground)
                createEvent(name: String.Received, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
            case .inactive:
                os_log("%s", String.TappedAndTransitioning)
                createEvent(name: String.Opened, googleMessageId: gcmmessageId, messageId: firebaseNotificationId)
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
            self.updateUser(attributes: ["": ""])
        }

        let requestLocationsOp = BlockOperation {
            self.requestLocations()
        }
        requestLocationsOp.addDependency(retrieveMeOp)

        operationQueue.addOperations([retrieveMeOp, requestLocationsOp], waitUntilFinished: true)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if initialLocation == nil {
            initialLocation = locations.last
        }
        updatedUserLocation = locations.last!
        distanceBetweenLocations = updatedUserLocation!.distance(from: initialLocation!)

        if distanceBetweenLocations! >= 5.0 {
            BoardActive.client.updateLocation(location: updatedUserLocation!)
            distanceBetweenLocations = 0
        }
        initialLocation = updatedUserLocation
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        os_log("Location manager failed with error: %s", error.localizedDescription)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("CLAuthorizationStatus :: %d", status.rawValue)
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
        UIApplication.shared.applicationIconBadgeNumber = response.notification.request.content.badge as! Int

        guard response.actionIdentifier != UNNotificationDefaultActionIdentifier || response.actionIdentifier !=
            "VIEW_IDENTIFIER" else {
            return
        }
        BoardActive.client.delegate?.appReceivedRemoteNotification(notification: response.notification)
        completionHandler()
    }

    // MARK: Class Functions

    fileprivate func getHeaders() -> [String: String]? {
        guard let tokenString = UserDefaults.standard.object(forKey: .DeviceToken) as? String else {
            return nil
        }
        let uuidString = UIDevice.current.identifierForVendor!.uuidString
        let headers: [String: String] = [
            "X-BoardActive-App-Key": self.appKey,
            "X-BoardActive-App-Id": self.appId,
            "X-BoardActive-Device-Token": tokenString,
            "X-BoardActive-App-Version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String,
            "X-BoardActive-Device-OS": "ios",
            "Content-Type": "application/json",
            "X-BoardActive-Device-OS-Version": UIDevice.current.systemVersion,
            "X-BoardActive-Device-Type": String.DeviceType,
            "X-BoardActive-Device-UUID": uuidString,
            "Accept": "*/*",
            "Cache-Control": "no-cache",
            "Host": "springer-api.boardactive.com",
            "accept-encoding": "gzip, deflate",
            "Connection": "keep-alive",
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
//            os_log("[BA:client:createEvent] Path string nil")
//            return
//        }

//        let path = EndPoints.events.rawValue
//        let headers = getHeaders()
        let body: [String: Any] = [
            String.EventKeys.name.rawValue: name,
            String.EventKeys.messageId.rawValue: messageId,
            String.EventKeys.inbox.rawValue: Dictionary<String, String>(),
            String.EventKeys.firebaseNotificationId.rawValue: googleMessageId,
        ]
        callServer(path: "\(EndPoints.events.rawValue)", httpMethod: "POST", body: body) { _, err in
            guard err == nil else {
                return
            }
        }
    }

    /**
     Derives a latitude and longitude from the location parameter, couples the coordinate with an iso8601 formatted date, and then updates the server and database with user's timestamped location.

     - Parameter location: `CLLocation` The user's current location.
     */
    public func updateLocation(location: CLLocation) {
        let path = "\(EndPoints.locations.rawValue)"
        let body: [String: Any] = [
            "latitude": "\(location.coordinate.latitude)",
            "longitude": "\(location.coordinate.longitude)",
            "deviceTime": Date().iso8601,
        ] as [String: Any]
        callServer(path: path, httpMethod: "POST", body: body) { parsedJSON, err in
            guard err == nil else {
                return
            }
            os_log("[BA:client:updateLocation] :: jsonArray :: %s", parsedJSON.debugDescription)
        }
    }

    /**
     A means of updating the user's associated data.

     - Parameter email: `String` An email that will be associated with the user on the server then saved to the database.
     */
    public func updateUser(attributes: [String: Any]) {
        let path = "\(EndPoints.me.rawValue)"
        var body: [String: Any] = [
            String.StockAttributes.deviceOS.rawValue: String.iOS,
            String.StockAttributes.deviceOSVersion.rawValue: String.SystemVersion,
        ]

        body = body.merging(attributes) { current, _ in current }

        callServer(path: path, httpMethod: "PUT", body: body) { userInfoJSON, err in
            guard err == nil else {
                return
            }
            os_log("[BA:client:updateMe] OK : %s", (userInfoJSON.debugDescription))
        }
    }

    enum BackendError: Error {
        case urlError(reason: String)
        case objectSerialization(reason: String)
    }

    /**
     Creates a `URLSession` given the parameters provided and returns a completion handler containing either a `Dictionary` of the parsed, returned JSON, or an error.
     
     - Parameter path:  String The path the `URLSession` calls.
     - Parameter httpMethod: String Corresponding `HTTPMethod`
     - Parameter body: [String:Any] Dictionary of what will become the `URLRequest`'s body.
     - Parameter completionHandler: [String: Any]?
    */
    typealias callback = ([String:Any]?, (Error?) -> Void)
    public func callServer(path: String, httpMethod: String, body: [String: Any], completionHandler:
        @escaping ([String: Any]?, Error?) -> Void) {
        #if DEBUG
            let endpoint = "https://springer-api.boardactive.com/mobile/v1"
        #else
            let endpoint = "https://api.boardactive.com/mobile/v1"
        #endif

        let destination = endpoint + path
        let parameters = body as [String: Any]
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        let request = NSMutableURLRequest(url: NSURL(string: destination)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 100.0)
        guard let headers = getHeaders() else {
            return
        }
        request.allHTTPHeaderFields = headers
        request.httpMethod = httpMethod
        request.httpBody = postData as Data
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse.debugDescription)
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print(dataString)
                    }
                }
            }
        })

        dataTask.resume()
    }
}
