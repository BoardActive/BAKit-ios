//
//  Client.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/23/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import Alamofire
import PromiseKit
import FirebaseCore
import FirebaseMessaging

public class BoardActive: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  public static let client = BoardActive() // BA singleton
  let API = [
    "prod": "https://api.boardactive.com/mobile",
    "dev": "https://dev-api.boardactive.com/mobile",
    "webProd": "https://api.boardactive.com",
    "webDev": "https://dev-api.boardactive.com"
  ]
  
  let appDelegate = UIApplication.shared.delegate
  let locationManager: CLLocationManager = CLLocationManager()
  let clientViewController: UIViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
  var openingViewController: UIViewController?  // used to return to previous view controller after hide() is called
  
  // [START Init]
  private init() {
    super.init(nibName: nil, bundle: nil)
    FirebaseApp.configure() // TODO move to boot?
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  // [END Init]
  
  // [START Public API]
  public func boot(_ config: [String: Any]) {
    self.requestLocations()
  }
  
  public func requestLocations () {
    locationManager.delegate = self
    
    // TODO.. using 10 so?
    if #available(iOS 9.0, *) {
      locationManager.allowsBackgroundLocationUpdates = true
    } else {
      // Fallback on earlier versions
    };
    
    locationManager.requestAlwaysAuthorization()   // asks for location permissions when app in foreground
    locationManager.startUpdatingLocation()
  }
  
  public func requestNotifications (_ application: UIApplication) {
    // [START set_messaging_delegate]
    Messaging.messaging().delegate = self;
    // [END set_messaging_delegate]
    
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    // [START register_for_notifications]
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    // [END register_for_notifications]
  }
  
  public func show() {
    print("SHOW")
    openingViewController = appDelegate?.window??.rootViewController
    appDelegate?.window??.rootViewController = clientViewController
  }
  
  public func hide() {
    print("HIDE")
    appDelegate?.window??.rootViewController = openingViewController
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
    // TODO check if 3rd party notifications execute this callback
    let a = AdDrop(userInfo as! [String: Any])
    
    if (a.isValidNotification()) {
      if (application.applicationState == UIApplicationState.active) {
        // in FG and receive notification
        print("RECEIVED FOREGROUND")
        createEvent(name: "received", notificationId: a.notificationId ?? "", advertisementId: a.advertisementId, promotionId: a.id)
      } else if (application.applicationState == UIApplicationState.background) {
        // in BG and receive notification
        print("RECEIVED BACKGROUND")
        createEvent(name: "received", notificationId: a.notificationId ?? "", advertisementId: a.advertisementId, promotionId: a.id)
      } else if (application.applicationState == UIApplicationState.inactive) {
        // tap notification from notification center
        print("TAPPED & TRANSITIONING")
        createEvent(name: "opened", notificationId: a.notificationId ?? "", advertisementId: a.advertisementId, promotionId: a.id)
      }
    }
  }
  // [END Public API]
  
  // [START Overrides]
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for location in locations {
      updateLocation(location)
      break // only take first
    }
  }
  
  public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")
    
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END Overrides]
  
  // [START Class Functions]
  private func getPath() -> String {
    return API["prod"]!
  }
  
  private func getHeaders(latitude: String? = "82.8628", longitude: String? = "135.0000", advertiserId: String? = "*") -> HTTPHeaders {
    // Sets lat/lng Antartica by default
    let headers: HTTPHeaders = [
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-BoardActive-Application-Key": "key",
      "X-BoardActive-Application-Secret": "secret",
      "X-BoardActive-Advertiser-Id": "233",   // TODO move to config within app delegate, 233 = knapsackmagic advertiser id // advertiserId!,
      "X-BoardActive-Device-Id": "-1",        // TODO gutted onesignal soooo
      "X-BoardActive-Device-OS": "ios",       // its a cocoa pod...
      "X-BoardActive-Latitude": latitude!,
      "X-BoardActive-Longitude": longitude!
    ]
    return headers;
  }
  
  func fetchAdDrops() -> Promise<[AdDrop]>{
    let path = getPath() + "/promotions"
    let headers = getHeaders()
    var adDrops = [AdDrop]()
    
    print("[BA:client:fetchAdDrops] fetching...")
    
    return Promise { seal in
      Alamofire.request(path, headers: headers)
        .responseJSON { response in
          switch response.result {
          case .success(let json):
            guard let json = json as? NSArray else {
              print("[BA:client:fetchAdDrops] ERR : no json")
              return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
            }
            
            for adDrop in json {
              let adDrop = AdDrop(adDrop as! [String: Any])
              if (adDrop.isValidModel()) {
                adDrops.append(adDrop)
              } else {
                print("[BA:client:fetchAdDrops] INVALID : ", adDrop)
              }
            }
            
            print("[BA:client:fetchAdDrops] OK : ", adDrops)
            seal.fulfill(adDrops)
          case .failure(let error):
            print("[BA:client:fetchAdDrops] ERR : ", error)
            seal.reject(error)
          }
      }
    }
  }
  
  func fetchBookmarkedAdDrops() -> Promise<[AdDrop]>{
    let path = getPath() + "/promotions/bookmarks"
    let headers = getHeaders()
    var adDrops = [AdDrop]()
    
    return Promise { seal in
      Alamofire.request(path, headers: headers)
        .responseJSON { response in
          switch response.result {
          case .success(let json):
            guard let json = json as? NSArray else {
              print("[BA:client:fetchAdDrops] ERR : no json")
              return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
            }
            
            for adDrop in json {
              let adDrop = AdDrop(adDrop as! [String: Any])
              if (adDrop.isValidModel()) {
                adDrop.isBookmarked = true  // TODO should be set by backend
                adDrops.append(adDrop)
              } else {
                print("[BA:client:fetchAdDrops] INVALID : ", adDrop)
              }
            }
            
            print("[BA:client:fetchAdDrops] OK : ", adDrops)
            seal.fulfill(adDrops)
          case .failure(let error):
            print("[BA:client:fetchAdDrops] ERR : ", error)
            seal.reject(error)
          }
      }
    }
  }
  
  func fetchAdDropById(_ id: String) -> Promise<AdDrop> {
    let path = getPath() + "/promotions/" + id
    let headers = getHeaders()
    
    return Promise { seal in
      Alamofire.request(path, headers: headers)
        .responseJSON { response in
          switch response.result {
          case .success(let json):
            guard let json = json as? [String: Any] else {
              print("[BA:client:fetchAdDrop] ERR : no json")
              return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
            }
            let adDrop = AdDrop(json)
            print("[BA:client:fetchAdDrop] OK : ", adDrop)
            seal.fulfill(adDrop)
          case .failure(let error):
            print("[BA:client:fetchAdDrop] ERR : ", error)
            seal.reject(error)
          }
      }
    }
  }
  
  public func createEvent(name: String, notificationId: String, advertisementId: String, promotionId: String) {
    let path = getPath() + "/events"
    let headers = getHeaders()
    let body: [String: Any] = [
      "name": name,
      "params": [
        "firebaseNotificationId": notificationId,
        "advertisement_id": advertisementId,
        "promotion_id": promotionId
      ]
    ]
    
    Alamofire.request(path, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate()
      .responseJSON { response in
        switch response.result {
        case .success(let json):
          print("[BA:client:createEvent] OK : ", json)
        case .failure(let error):
          print("[BA:client:createEvent] ERR : ", error)
        }
    }
  }
  
  func toggleAdDropBookmark(_ adDrop: AdDrop) -> Promise<AdDrop> {
    return adDrop.isBookmarked
      ? createAdDropBookmark(adDrop)
      : deleteAdDropBookmark(adDrop)
  }
  
  func createAdDropBookmark(_ adDrop: AdDrop) -> Promise<AdDrop> {
    let path = getPath() + "/promotions/" + String(adDrop.id) + "/bookmarks"
    let headers = getHeaders()
    let body: [String: Any] = [:]
    
    // TODO do we even need body?
    return Promise { seal in
      Alamofire.request(path, method: .post, parameters: body, headers: headers)
        .responseJSON { response in
          switch response.result {
          case .success(let json):
            print("[BA:client:createAdDropBookmark] OK : ", json)
            seal.fulfill(adDrop)
          case .failure(let error):
            print("[BA:client:createAdDropBookmark] ERR : ", error)
            seal.reject(error)
          }
      }
    }
  }
  
  func deleteAdDropBookmark(_ adDrop: AdDrop) -> Promise<AdDrop> {
    let path = getPath() + "/promotions/" + String(adDrop.id) + "/bookmarks"
    let headers = getHeaders()
    let body: [String: Any] = [:]
    
    return Promise { seal in
      Alamofire.request(path, method: .delete, parameters: body, headers: headers)
        .responseJSON { response in
          switch response.result {
          case .success(let json):
            print("[BA:client:deleteAdDropBookmark] OK : ", json)
            seal.fulfill(adDrop)
          case .failure(let error):
            print("[BA:client:deleteAdDropBookmark] ERR : ", error)
            seal.reject(error)
          }
      }
    }
  }
  
  
  func updateLocation(_ location: CLLocation) -> Void {
    let path = getPath() + "/mobile_geopoints"
    let headers = getHeaders(latitude: "\(location.coordinate.latitude)", longitude: "\(location.coordinate.longitude)")
    let body: [String: Any] = [:]
    
    Alamofire.request(path, method: .post, parameters: body, headers: headers)
      .responseJSON { response in
        switch response.result {
        case .success(let json):
          print("[BA:client:updateLocation] OK : ", json)
        case .failure(let error):
          print("[BA:client:updateLocation] ERR : ", error)
        }
    }
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
  // [END Class Functions]
}
