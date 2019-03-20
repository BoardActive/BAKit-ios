//
//  Client.swift
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
import SwiftyJSON
import UserNotifications

public enum EndPoints: String {
    case prod = "https://springer-api.boardactive.com/mobile/v1"
    case events = "/events"
    case me = "/me"
    case locations = "/locations"
}

public class BoardActive: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    public static let client = BoardActive()

    let systemVersion = UIDevice.current.systemVersion

    let appDelegate = UIApplication.shared.delegate
    var locationManager: CLLocationManager = CLLocationManager()
    let clientViewController: UIViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
    var openingViewController: UIViewController? // used to return to previous view controller after hide() is called
    var coveringWindow = UIWindow(frame: (UIApplication.shared.keyWindow?.screen.bounds)!)

    private init() {
        super.init(nibName: nil, bundle: nil)
        FirebaseApp.configure() // TODO: move to boot?\
        retrieveMe()
        requestLocations()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func requestLocations() {
        locationManager.delegate = self

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

        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .fitness

        DispatchQueue.main.async {
            BoardActive.client.locationManager.startUpdatingLocation()
        }
    }

    public func requestNotifications(_ application: UIApplication) {
        Messaging.messaging().delegate = self

        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        application.registerForRemoteNotifications()
    }

    func coverEverything() {
        coveringWindow.windowLevel = UIWindow.Level.alert + 1
        coveringWindow.isHidden = false
        let clientViewController: UIViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        coveringWindow.rootViewController = clientViewController
        coveringWindow.makeKeyAndVisible()
    }

    public func show() {
        coverEverything()
    }

    public func hide() {
        print("HIDE")
        hideEverything()
    }

    public func hideEverything() {
        coveringWindow.windowLevel = UIWindow.Level.alert - 1
        coveringWindow.isHidden = true
        appDelegate?.window??.windowLevel = UIWindow.Level.alert + 1

        appDelegate?.window??.makeKeyAndVisible()
    }

    public func onNotificationReceived(callback: ([String: Any]) -> Void) {
        callback(["received": ["world": "test"]])
    }

    public func onNotificationOpened(callback: ([String: Any]) -> Void) {
        callback(["opened": ["world": "test"]])
    }

    public func handleNotification(_ application: UIApplication, _ userInfo: [AnyHashable: Any]) {
        // TODO: check if 3rd party notifications execute this callback
        let a = Message(userInfo as! [String: Any])

        if a.isValidNotification() {
            if application.applicationState == UIApplication.State.active {
                // in FG and receive notification
                print("RECEIVED FOREGROUND")
                createEvent(name: "received", notificationId: a.notificationId ?? "", messageId: a.messageId, promotionId: a.id)
            } else if application.applicationState == UIApplication.State.background {
                // in BG and receive notification
                print("RECEIVED BACKGROUND")
                createEvent(name: "received", notificationId: a.notificationId ?? "", messageId: a.messageId, promotionId: a.id)
            } else if application.applicationState == UIApplication.State.inactive {
                // tap notification from notification center
                print("TAPPED & TRANSITIONING")
                createEvent(name: "opened", notificationId: a.notificationId ?? "", messageId: a.messageId, promotionId: a.id)
            }
        }
    }

    public func createEvent(name: String, notificationId: String, messageId: String, promotionId: String) {
        let path = getPath() + EndPoints.events.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "name": name,
            "params": [
                "firebaseNotificationId": notificationId,
                "advertisement_id": messageId,
                "promotion_id": promotionId,
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

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation(locations.first!)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.setValue(fcmToken, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
//        let dataDict: [String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let gcmMessageIDKey = "gcm.message_id"

        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        UserDefaults.standard.setValue(messageID, forKey: "kMESSAGEID")
        UserDefaults.standard.synchronize()

        completionHandler()
    }

    private func getPath() -> String {
        return EndPoints.prod.rawValue
    }

    private func castAdDropJsonNumbersToStrings(json: [String: Any]) -> [String: Any] {
        var mutatedJson = json
        if let promotionIdNumber = json["promotion_id"] as? NSNumber {
            mutatedJson["promotion_id"] = "\(promotionIdNumber)"
        }

        if let messageIdNumber = json["message"] as? NSNumber {
            mutatedJson["advertisement_id"] = "\(messageIdNumber)"
        }
        return mutatedJson
    }

    private func getHeaders() -> HTTPHeaders {
        guard let mePayloadDictionary = UserDefaults.standard.object(forKey: "MePayload") as? Dictionary<String, Any> else {
            return HTTPHeaders()
        }

        let tokenString = mePayloadDictionary["deviceToken"] as! String

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-BoardActive-App-Key": "1",
            "X-BoardActive-App-Id": "1", // needs to be passed in
            "X-BoardActive-App-Version": "4.7.3",
            "X-BoardActive-Device-Token": tokenString, // fcmTokenStore,
            "X-BoardActive-Device-OS": "ios",
            "X-BoardActive-Device-OS-Version": "\(systemVersion)",
            "X-BoardActive-Is-Test-App": "1",
        ]
        return headers
    }

    func fetchAdDropById(_ id: String) -> Promise<Message> {
        let path = getPath() + "/promotions/" + id
        let headers = getHeaders()

        return Promise { seal in
            Alamofire.request(path, headers: headers).responseJSON { response in
                    switch response.result {
                    case let .success(json):
                        guard let json = json as? [String: Any] else {
                            print("[BA:client:fetchAdDrop] ERR : no json")
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        var mutatedJson = json
                        mutatedJson = self.castAdDropJsonNumbersToStrings(json: mutatedJson)
                        let adDrop = Message(mutatedJson)
                        print("[BA:client:fetchAdDrop] OK : ", adDrop)
                        seal.fulfill(adDrop)
                    case let .failure(error):
                        print("[BA:client:fetchAdDrop] ERR : ", error)
                        seal.reject(error)
                    }
                }
        }
    }

    func updateLocation(_ location: CLLocation) {
        let path = getPath() + EndPoints.locations.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "latitude": "\(location.coordinate.latitude)",
            "longitude": "\(location.coordinate.longitude)",
            "deviceTime": "\(Date())",
        ]

        Alamofire.request(path, method: .post, parameters: body, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let json):
                    print("[BA:client:updateLocation] OK : ", json)
                case .failure(let error):
                    print("[BA:client:updateLocation] ERR : ", error)
                }
                print((response.value as AnyObject).debugDescription!)
            }
    }

    public func retrieveMe() {
        let path = getPath() + EndPoints.me.rawValue
        let headers = getHeaders()
        Alamofire.request(path, method: .get, parameters: nil, headers: headers).responseSwiftyJSON(completionHandler: { response in
            switch response.result {
            case .success(let json):
                print("[BA:client:me] OK : ", json)
            case .failure(let error):
                print("[BA:client:me] OK : ", error)
                return
            }

            let parsedJSON = MePayload(fromJson: response.result.value)
            UserDefaults.standard.setValue(parsedJSON.toDictionary(), forKey: "MePayload")
            UserDefaults.standard.synchronize()
        })
    }

    func updateUserInfo(email: String) {
        let path = getPath() + EndPoints.me.rawValue
        let headers = getHeaders()
        let body: [String: Any] = [
            "email": email,
            "deviceOS": "ios",
            "deviceOSVersion": "12.1.4",
        ]

        Alamofire.request(path, method: .post, parameters: body, headers: headers).responseSwiftyJSON(completionHandler: { response in
            switch response.result {
            case .success(let json):
                print("[BA:client:updateUserInfo] OK : ", json)
            case .failure(let error):
                print("[BA:client:updateUserInfo] ERR : ", error)
                return
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
}
       

//  func toggleAdDropBookmark(_ adDrop: Message) -> Promise<AdDrop> {
//    return adDrop.isBookmarked
//      ? createAdDropBookmark(adDrop)
//      : deleteAdDropBookmark(adDrop)
//  }

//  func createAdDropBookmark(_ adDrop: AdDrop) -> Promise<AdDrop> {
//    let path = getPath() + "/promotions/" + String(adDrop.id) + "/bookmarks"
//    let headers = getHeaders()
//    let body: [String: Any] = [:]
//
//    // TODO do we even need body?
//    return Promise { seal in
//      Alamofire.request(path, method: .post, parameters: body, headers: headers)
//        .responseJSON { response in
//          switch response.result {
//          case .success(let json):
//            print("[BA:client:createAdDropBookmark] OK : ", json)
//            seal.fulfill(adDrop)
//          case .failure(let error):
//            print("[BA:client:createAdDropBookmark] ERR : ", error)
//            seal.reject(error)
//          }
//      }
//    }
//  }

//  func deleteAdDropBookmark(_ adDrop: Message) -> Promise<AdDrop> {
//    let path = getPath() + "/promotions/" + String(adDrop.id) + "/bookmarks"
//    let headers = getHeaders()
//    let body: [String: Any] = [:]
//
//    return Promise { seal in
//      Alamofire.request(path, method: .delete, parameters: body, headers: headers)
//        .responseJSON { response in
//          switch response.result {
//          case .success(let json):
//            print("[BA:client:deleteAdDropBookmark] OK : ", json)
//            seal.fulfill(adDrop)
//          case .failure(let error):
//            print("[BA:client:deleteAdDropBookmark] ERR : ", error)
//            seal.reject(error)
//          }
//      }
//    }
//  }             

//    func fetchAdDrops() -> Promise<[Message]> {
//        let path = getPath() + "/promotions"
//        let headers = getHeaders()
//        var adDrops = [Message]()
//
//        print("[BA:client:fetchAdDrops] fetching...")
//
//        return Promise { seal in
//
//            Alamofire.request(path, headers: headers)
//                .responseJSON { response in
//                    switch response.result {
//                    case let .success(json):
//
//                        guard let json = json as? NSArray else {
//                            print("[BA:client:fetchAdDrops] SUCCESS ERR : no json")
//                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
//                        }
//
//                        for adDrop in json {
//                            var adDropJson = adDrop as! [String: Any]
//                            adDropJson = self.castAdDropJsonNumbersToStrings(json: adDropJson)
//                            let drop = Message(adDropJson)
//                            if drop.isValidModel() {
//                                adDrops.append(drop)
//                            } else {
//                                print("[BA:client:fetchAdDrops] INVALID : ", drop)
//                            }
//                        }
//
//                        print("[BA:client:fetchAdDrops] OK : ", adDrops)
//                        seal.fulfill(adDrops)
//                    case let .failure(error):
//                        print("[BA:client:fetchAdDrops] ERR : ", error)
//                        seal.reject(error)
//                    }
//                }
//        }
//    }

//    Nothing works unless the PUT call to ME has gone through
//    deviceToken = fcm

//  func fetchBookmarkedAdDrops() -> Promise<[AdDrop]>{
//    let path = getPath() + "/promotions/bookmarks"
//    let headers = getHeaders()
//    var adDrops = [AdDrop]()
//
//    return Promise { seal in
//      Alamofire.request(path, headers: headers)
//        .responseJSON { response in
//          switch response.result {
//          case .success(let json):
//
//            guard let json = json as? NSArray else {
//              print("[BA:client:fetchAdDrops] ERR : no json")
//              return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
//            }
//
//            for adDrop in json {
//              var adDropJson = adDrop as! [String: Any]
//              adDropJson = self.castAdDropJsonNumbersToStrings(json: adDropJson)
//              let adDrop = AdDrop(adDropJson)
//              if (adDrop.isValidModel()) {
//                adDrop.isBookmarked = true  // TODO should be set by backend
//                adDrops.append(adDrop)
//              } else {
//                print("[BA:client:fetchAdDrops] INVALID : ", adDrop)
//              }
//            }
//
//            print("[BA:client:fetchAdDrops] OK : ", adDrops)
//            seal.fulfill(adDrops)
//          case .failure(let error):
//            print("[BA:client:fetchAdDrops] ERR : ", error)
//            seal.reject(error)
//          }
//      }
//    }
//  }
//
