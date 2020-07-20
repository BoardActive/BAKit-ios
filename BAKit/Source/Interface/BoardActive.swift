//
//  BoardActive.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/23/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//
import CoreLocation
import Foundation
import os.log
import UIKit

public enum NetworkError: Error {
    case BadJSON
    case NSError
}

/**
 Dev and prod base urls plus their associated endpoints.
 */
public enum EndPoints {
//    static let DevEndpoint = "https://springer-api.boardactive.com/mobile/v1"
    static let DevEndpoint = "https://dev-api.boardactive.com/mobile/v1"
    static let ProdEndpoint = "https://api.boardactive.com/mobile/v1"
    static let Events = "/events"
    static let Me = "/me"
    static let Locations = "/locations"
    static let Login = "/login"
    static let Attributes = "/attributes"
}

/**
 A succinct means of denoting which `CLLocationManager` permission the app will request from the user.
 */
public enum AuthorizationMode: String {
    case always
    case whenInUse
}

public class BoardActive: NSObject, CLLocationManagerDelegate {
    /**
     A property returning the BoardActive singleton.
     */
    public static let client = BoardActive()

    public var userDefaults = UserDefaults(suiteName: "BAKit")
    public var isDevEnv = true
    
    private let locationManager = CLLocationManager()
    public var currentLocation: CLLocation?
    public var distanceBetweenLocations: CLLocationDistance?

    private override init() {}

    /**
     Sets the `appID`, `appKey`, and `fcmToken` in the `UserDefaults` to those of the parameters before calling `FirebaseApp.configure()`.

     - parameter appID: The app's ID.
     - parameter appKey: The app's key.
     - parameter fcmToken: The FCM token for this device.
     */
    public func setupEnvironment(appID: String, appKey: String) {
        userDefaults?.set(appID, forKey: String.ConfigKeys.AppId)
        userDefaults?.set(appKey, forKey: String.ConfigKeys.AppKey)
        userDefaults?.synchronize()
    }

    deinit {
        stopUpdatingLocation()
    }
    
    /**
     If error occurs, block will execute with status other than `INTULocationStatusSuccess` and subscription will be kept alive.
     */
    public func monitorLocation() {
        BoardActive.client.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        BoardActive.client.locationManager.distanceFilter = 10
        BoardActive.client.locationManager.delegate = self
        BoardActive.client.locationManager.requestAlwaysAuthorization()
        BoardActive.client.locationManager.startUpdatingLocation()
        BoardActive.client.locationManager.startMonitoringSignificantLocationChanges()
        BoardActive.client.locationManager.pausesLocationUpdatesAutomatically = false
        BoardActive.client.locationManager.allowsBackgroundLocationUpdates=true
    }
    
      /**
       Calls `stopUpdatingLocation` on BoardActive's private CLLocationManager property.
       */
      public func stopUpdatingLocationandReinitialize() {
            BoardActive.client.locationManager.stopUpdatingLocation()
            BoardActive.client.locationManager.startMonitoringSignificantLocationChanges()
      }

    //MARK: - Core Location
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            os_log("\n[BoardActive] didUpdateLocations :: Error: Last location of locations = nil.\n")
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied, .authorizedWhenInUse:
                BoardActive.client.userDefaults?.set(false, forKey: String.Attribute.LocationPermission)
            case .authorizedAlways:
                BoardActive.client.userDefaults?.set(true, forKey: String.Attribute.LocationPermission)
            }
            BoardActive.client.userDefaults?.synchronize()
        }
        
        if BoardActive.client.userDefaults?.object(forKey: String.Attribute.DateLocationRequested) == nil {
            let date = Date().iso8601
            BoardActive.client.userDefaults?.set(date, forKey: String.Attribute.DateLocationRequested)
            BoardActive.client.userDefaults?.synchronize()
//            BoardActive.client.editUser(attributes: Attributes(fromDictionary: ["dateLocationRequested": date]), httpMethod: String.HTTPMethod.PUT)
        }
        
        if BoardActive.client.currentLocation == nil {
            BoardActive.client.currentLocation = location
            postLocation(location: location)
        }
        
        if let currentLocation = BoardActive.client.currentLocation, location.distance(from: currentLocation) < 10.0 {
            BoardActive.client.distanceBetweenLocations = (BoardActive.client.distanceBetweenLocations ?? 0.0) + location.distance(from: currentLocation)
        } else {
            postLocation(location: location)
            BoardActive.client.distanceBetweenLocations = 0.0
        }
        
        BoardActive.client.currentLocation = location
    }
    
    public func getAttributes(completionHandler: @escaping([[String: Any]]?, Error?) -> Void) {
          let path = EndPoints.Attributes
          callServer(forList: path, httpMethod: String.HTTPMethod.GET, body: [:]) { (parsedJson, error) in
              if error != nil {
                  completionHandler(nil, error)
              } else {
                  completionHandler(parsedJson, nil)
              }
          }
      }
      
      
      public func updateUserData(body: [String: Any], completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
          let path = "\(EndPoints.Me)"

          callServer(path: path, httpMethod: String.HTTPMethod.PUT, body: body) { parsedJSON, err in
              guard err == nil else {
                  completionHandler(nil, err)
                  return
              }

              completionHandler(parsedJSON, nil)
              return
          }
      }
      
      public func getMe(completionHandler: @escaping([String: Any]?, Error?) -> Void) {
          let path = "\(EndPoints.Me)"

          callServer(path: path, httpMethod: String.HTTPMethod.GET, body: [:]) { parsedJSON, err in
                       guard err == nil else {
                           completionHandler(nil, err)
                           return
                       }
                  os_log("[BoardActive] :: login: %s", parsedJSON.debugDescription)
                       completionHandler(parsedJSON, nil)
                       return
                   }
      }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else {
            os_log("\n[BoardActive] didFailWithError :: %s \n", error.localizedDescription)
            return
        }
        
        localNotificationifFailed()
        
        switch clError.errorCode {
        case 0:
            os_log("\n[BoardActive] didFailWithError :: Error: Location Unknown \n")
            break
        case 1:
            // Access to the location service was denied by the user.
            stopUpdatingLocation()
            break
        case 2:
            // Network error
            break
        default:
            os_log("\n[BoardActive] didFailWithError :: Error: %s \n", clError.errorUserInfo.debugDescription)
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var isAppAuthorized = false
        switch status {
        case .notDetermined, .restricted, .denied, .authorizedWhenInUse:
            os_log("\n[BoardActive] didChangeAuthorization :: status: Always\n")
            userDefaults?.set(false, forKey: String.Attribute.LocationPermission)
        case .authorizedAlways:
            os_log("\n[BoardActive] didChangeAuthorization :: status: Always\n")
            userDefaults?.set(true, forKey: String.Attribute.LocationPermission)
            isAppAuthorized = true
        }
        userDefaults?.synchronize()

//        BoardActive.client.editUser(attributes: Attributes(fromDictionary: ["locationPermission": isAppAuthorized]), httpMethod: String.HTTPMethod.PUT)
    }
    
    /**
     Functions as an as needed means of procuring the user's current location.
     - Returns: `CLLocation?` An optional `CLLocation` obtained by `CLLocationManager's` `requestLocation()` function.
     */
    public func getCurrentLocations() -> Dictionary<String, String>? {
        if let latitude = currentLocation?.coordinate.latitude, let longitude = currentLocation?.coordinate.longitude {
            return [String.NetworkCallRelated.Latitude: "\(latitude)", String.NetworkCallRelated.Longitude: "\(longitude)"]
        }
        return nil
    }

    /**
     Calls `stopUpdatingLocation` on BoardActive's private CLLocationManager property.
     */
    public func stopUpdatingLocation() {
        BoardActive.client.locationManager.stopUpdatingLocation()
    }

    // MARK: SDK Functions

    public func getHeaders() -> [String: String]? {
        guard let tokenString = userDefaults?.object(forKey: String.HeaderValues.FCMToken) as? String else {
            return nil
        }

        let hostKey: String
        if isDevEnv {
            hostKey = String.HeaderValues.DevHostKey
        } else {
            hostKey = String.HeaderValues.ProdHostKey
        }

        let headers: [String: String] = [
            String.HeaderKeys.AcceptEncodingHeader: String.HeaderValues.GzipDeflate,
            String.HeaderKeys.AcceptHeader: String.HeaderValues.WildCards,
            String.HeaderKeys.AppKeyHeader: BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey) ?? "",
            String.HeaderKeys.AppIdHeader: BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppId) ?? "",
            String.HeaderKeys.AppVersionHeader: String.HeaderValues.AppVersion,
            String.HeaderKeys.CacheControlHeader: String.HeaderValues.NoCache,
            String.HeaderKeys.ConnectionHeader: String.HeaderValues.KeepAlive,
            String.HeaderKeys.ContentTypeHeader: String.HeaderValues.ApplicationJSON,
            String.HeaderKeys.DeviceOSHeader: String.HeaderValues.iOS,
            String.HeaderKeys.DeviceOSVersionHeader: String.HeaderValues.DeviceOSVersion,
            String.HeaderKeys.DeviceTokenHeader: tokenString,
            String.HeaderKeys.DeviceTypeHeader: String.HeaderValues.DeviceType,
            String.HeaderKeys.HostHeader: hostKey,
            String.HeaderKeys.IsTestApp: "1",
            String.HeaderKeys.UUIDHeader: UIDevice.current.identifierForVendor!.uuidString,
        ]
        return headers
    }

    private func retrievePath(isDev: Bool) -> String {
        if isDevEnv {
            return EndPoints.DevEndpoint
        } else {
            return EndPoints.ProdEndpoint
        }
    }

    /**
     Retrieves a user attributes and affiliated apps.
     - Returns: Closure containing client/user information.
     */
    public func postLogin(email: String, password: String, completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
        let path = "\(EndPoints.Login)"
        let body: [String: Any] = [
            String.ConfigKeys.Email: email,
            String.ConfigKeys.Password: password,
        ]
      
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body as Dictionary<String, AnyObject>) { parsedJSON, err in
            guard err == nil else {
                completionHandler(nil, err)
                return
            }

            os_log("[BoardActive] :: login: %s", parsedJSON.debugDescription)
            completionHandler(parsedJSON, nil)
            // since login requires email, update user after email is given
            DispatchQueue.main.async {
                BoardActive.client.editUser(attributes: Attributes(fromDictionary: ["stock": ["email": email]]), httpMethod: String.HTTPMethod.PUT)
            }
          
            return
        }
    }

    /**
     Associates a particular device with a user's account.
     - Returns: Closure containing a user's attributes.
     */
    public func registerDevice(completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
        let path = "\(EndPoints.Me)"

        let body: [String: Any] = [
            String.ConfigKeys.Email: BoardActive.client.userDefaults?.object(forKey: String.ConfigKeys.Email) as Any,
            String.HeaderKeys.DeviceOSHeader: String.HeaderValues.iOS,
            String.HeaderKeys.DeviceOSVersionHeader: String.HeaderValues.DeviceOSVersion,
        ]

        callServer(path: path, httpMethod: String.HTTPMethod.PUT, body: body) { parsedJSON, err in
            guard err == nil else {
                completionHandler(nil, err)
                return
            }

            BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
            completionHandler(parsedJSON, nil)
            return
        }
    }

    /**
     Creates an Event using the information provided and then logs said Event to the BoardActive server.

     - Parameter name: `String`
     - Parameter messageId: `String` The value associated with the key "messageId" in notifications.
     - Parameter firebaseNotificationId: `String` The value associated with key "gcm.message_id" in notifications.
     */
    public func postEvent(name: String, messageId: String, firebaseNotificationId: String, notificationId: String, completionHandler: (() -> Void)? = nil) {
        let path = "\(EndPoints.Events)"

        let body: [String: Any] = [
            String.EventKeys.EventName: name,
            String.EventKeys.MessageId: messageId,
            String.EventKeys.FirebaseNotificationId: firebaseNotificationId,
            String.EventKeys.NotificationId: notificationId
//            String.EventKeys.Inbox: ["": ""],
        ]
        
        print("body: \(body)")

        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body) { _, err in
            guard err == nil else {
                if completionHandler != nil {
                    completionHandler!()
                }
                return
            }
            if completionHandler != nil {
                completionHandler!()
            }
        }
    }

    /**
     Derives a latitude and longitude from the location parameter, couples the coordinate with an iso8601 formatted date, and then updates the server and database with user's timestamped location.

     - Parameter location: `CLLocation`
     */
    public func postLocation(location: CLLocation) {

        let body: [String: Any] = [
            String.NetworkCallRelated.Latitude: location.coordinate.latitude,
            String.NetworkCallRelated.Longitude: location.coordinate.longitude,
            String.NetworkCallRelated.DeviceTime: Date().iso8601 as AnyObject,
        ]

        callServer(path: EndPoints.Locations, httpMethod: String.HTTPMethod.POST, body: body) { parsedJSON, err in
            guard err == nil else {
                return
            }
        }
    }

    /**
     A means of updating the user's associated attributes.

     - Parameter attributes: `Attributes` An instance of the `Attributes` class. Include only those keys whose values you intend to edit.
     - Parameter httpMethod: `String` Either `String.HTTPMethod.POST` ("POST") or `String.HTTPMethod.PUT` ("PUT").
      */
    public func editUser(attributes: Attributes, httpMethod: String) {
        let path = "\(EndPoints.Me)"

        let body: [String: Any] = [
            String.Attribute.Attrs: [
                String.Attribute.Stock: attributes.toDictionary()[String.Attribute.Stock],
                String.Attribute.Custom: attributes.toDictionary()[String.Attribute.Custom],
            ] as AnyObject,
        ]

        callServer(path: path, httpMethod: httpMethod, body: body) { parsedJSON, err in
            guard err == nil else {
                // Handle Error
                return
            }
          
            os_log("\n[BoardActive] :: editUser: %s\n", parsedJSON.debugDescription)
        }
    }

    /**
     Creates a `URLSession` given the parameters provided and returns a completion handler containing either a `Dictionary` of the parsed, returned JSON, or an error.

     - Parameter path:  String The path the `URLSession` calls.
     - Parameter httpMethod: String Corresponding `HTTPMethod`
     - Parameter body: [String:Any] Dictionary of what will become the `URLRequest`'s body.
     - Parameter completionHandler: [String: Any]?
     */
    public func callServer(path: String, httpMethod: String, body: [String: Any], completionHandler:
        @escaping ([String: Any]?, Error?) -> Void) {
        let destination = retrievePath(isDev: isDevEnv) + path
        let parameters = body as [String: Any]
        var bodyData = Data()

        do {
            try bodyData = JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("[BoardActive] :: callServer :: bodyData serialization error.")
        }

        let request = NSMutableURLRequest(url: NSURL(string: destination)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)

        guard let headers = getHeaders(), !headers.isEmpty else {
            os_log("[BA:client:callServer] :: NSMutableURLRequest:headers :: %s", getHeaders()?.debugDescription ?? "Empty Headers")
            return
        }

        request.allHTTPHeaderFields = headers
        request.httpMethod = httpMethod

        if path == EndPoints.Me && httpMethod == String.HTTPMethod.GET {
            request.httpBody = nil
        } else {
            request.httpBody = bodyData as Data
        }

        let session = URLSession.shared

        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let _ = response as? HTTPURLResponse else {
                os_log("[BA:client:callServer] :: dataTask:error : %s", error!.localizedDescription)
                return
            }

            if let data = data, (try? JSONSerialization.jsonObject(with: data)) != nil {
                if let dataString = String(data: data, encoding: .utf8) {
                    os_log("[BA:client:callServer] :: dataString : %@", dataString)

                    completionHandler(BoardActive.client.convertToDictionary(text: dataString), nil)
                    return
                }
            }
        })
        dataTask.resume()
    }

    public func callServer(forList path: String, httpMethod: String, body: [String: Any], completionHandler:@escaping ([[String: Any]]?, Error?) -> Void) {
          let destination = retrievePath(isDev: isDevEnv) + path
          let parameters = body as [String: Any]

          let request = NSMutableURLRequest(url: NSURL(string: destination)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)

          guard let headers = getHeaders(), !headers.isEmpty else {
              os_log("[BA:client:callServer] :: NSMutableURLRequest:headers :: %s", getHeaders()?.debugDescription ?? "Empty Headers")
              return
          }
          request.allHTTPHeaderFields = headers
          request.httpMethod = httpMethod
          let session = URLSession.shared

          let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
              guard error == nil, let _ = response as? HTTPURLResponse else {
                  os_log("[BA:client:callServer] :: dataTask:error : %s", error!.localizedDescription)
                  return
              }

              if let data = data, (try? JSONSerialization.jsonObject(with: data)) != nil {
                  if let dataString = String(data: data, encoding: .utf8) {
                      os_log("[BA:client:callServer] :: dataString : %@", dataString)

                      completionHandler(BoardActive.client.convertToDictionary(ofArray: dataString), nil)
                      return
                  }
              }
          })
          dataTask.resume()
      }
      
    func convertToDictionary(ofArray text: String) -> [[String: Any]]? {
           if let data = text.data(using: .utf8) {
               do {
                   return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
               } catch {
                   print(error.localizedDescription)
               }
           }
           return nil
       }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public func sendNotification(msg : String) {
        let content = UNMutableNotificationContent()
        content.title = "Terminate state notification"
        content.subtitle = msg
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        
        // 4
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func localNotificationifFailed() {
        let content = UNMutableNotificationContent()
        content.title = "Test notification failed"
        content.subtitle = "This is a test notification failed"
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        
        // 4
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    
}
