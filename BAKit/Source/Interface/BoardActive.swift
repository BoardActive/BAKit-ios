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
//    static let DevEndpoint = "https://dev-api.boardactive.com/mobile/v1"
    static let DevEndpoint = "https://boardactiveapi.dev.radixweb.net/mobile/v1"
    static let ProdEndpoint = "https://api.boardactive.com/mobile/v1"
    static let Events = "/events"
    static let Me = "/me"
    static let Locations = "/locations"
    static let Login = "/login"
    static let Attributes = "/attributes"
    static let GeoFenceLocation = "/geofenceLocation"
}

/**
 A succinct means of denoting which `CLLocationManager` permission the app will request from the user.
 */
public enum AuthorizationMode: String {
    case always
    case whenInUse
}

/**
These are all the general errors which may occur in the SDK.
 */
enum BAKitError: Error {
    case appDisable
}

public class BoardActive: NSObject, CLLocationManagerDelegate {
    /**
     A property returning the BoardActive singleton.
     */
    public static let client = BoardActive()
    public var userDefaults = UserDefaults(suiteName: "BAKit")
    public var isDevEnv = true
    public var geofenceRadius = 1000
    public var recordLocationAfterMeters: Double = 15
    
    public var isAppEnable = true
    
    private let locationManager = CLLocationManager()
    private let geofenceNotifyTimeLimit: Double = 86400
    
//    public var previousUserLocation: CLLocation?
//    public var distanceBetweenLocations: CLLocationDistance?

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
//        BoardActive.client.locationManager.startMonitoringSignificantLocationChanges()
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
        print(locations)
       /* if let locationList = userDefaults?.value(forKey: String.ConfigKeys.userLocations) as? [[String: Double]] {
            BoardActive.client.previousUserLocation = CLLocation(latitude: locationList.last?[String.NetworkCallRelated.Latitude] ?? 0.0, longitude: locationList.last?[String.NetworkCallRelated.Longitude] ?? 0.0)
        }
        
        if (BoardActive.client.previousUserLocation == nil) {
            BoardActive.client.previousUserLocation = location
            saveLocationLocally(location: location)
            
        } else if let previousLocation = BoardActive.client.previousUserLocation, location.distance(from: previousLocation) > recordLocationAfterMeters {
            BoardActive.client.previousUserLocation = location
            saveLocationLocally(location: location)
        } */
        
//        if CLLocationManager.locationServicesEnabled() {
//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied, .authorizedWhenInUse:
//                BoardActive.client.userDefaults?.set(false, forKey: String.Attribute.LocationPermission)
//            case .authorizedAlways:
//                BoardActive.client.userDefaults?.set(true, forKey: String.Attribute.LocationPermission)
//            }
//            BoardActive.client.userDefaults?.synchronize()
//        }
//
//        if BoardActive.client.userDefaults?.object(forKey: String.Attribute.DateLocationRequested) == nil {
//            let date = Date().iso8601
//            BoardActive.client.userDefaults?.set(date, forKey: String.Attribute.DateLocationRequested)
//            BoardActive.client.userDefaults?.synchronize()
////            BoardActive.client.editUser(attributes: Attributes(fromDictionary: ["dateLocationRequested": date]), httpMethod: String.HTTPMethod.PUT)
//        }
//
//        if BoardActive.client.currentLocation == nil {
//            BoardActive.client.currentLocation = location
//            postLocation(location: location)
//        }
//
//        if let currentLocation = BoardActive.client.currentLocation, location.distance(from: currentLocation) < 10.0 {
//            BoardActive.client.distanceBetweenLocations = (BoardActive.client.distanceBetweenLocations ?? 0.0) + location.distance(from: currentLocation)
//        } else {
//            postLocation(location: location)
//            BoardActive.client.distanceBetweenLocations = 0.0
//        }

//        BoardActive.client.currentLocation = location
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
        BoardActive.client.updatePermissionStates()
    }
    
    /**
     Functions as an as needed means of procuring the user's current location.
     - Returns: `CLLocation?` An optional `CLLocation` obtained by `CLLocationManager's` `requestLocation()` function.
     */
  /*  public func getCurrentLocations() -> Dictionary<String, String>? {
        if let latitude = previousUserLocation?.coordinate.latitude, let longitude = previousUserLocation?.coordinate.longitude {
            return [String.NetworkCallRelated.Latitude: "\(latitude)", String.NetworkCallRelated.Longitude: "\(longitude)"]
        }
        return nil
    } */

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
            String.HeaderKeys.IsTestApp: isDevEnv ? "1" : "0",
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
      
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body as Dictionary<String, AnyObject>, verifyAppEnable: false) { parsedJSON, err in
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

        callServer(path: path, httpMethod: String.HTTPMethod.PUT, body: body, verifyAppEnable: false) { parsedJSON, err in
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
        A method to get the list of geofence location.
     */
    public func downloadGeofenceLocation(completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
        let path = "\(EndPoints.GeoFenceLocation)?limit=10"
        callServer(path: path, httpMethod: String.HTTPMethod.GET, body: [:]) { parsedJSON, err in
            guard err == nil else {
                completionHandler(nil, err)
                return
            }
            completionHandler(parsedJSON, nil)
            print(parsedJSON)
        }
    }

    /**
     Creates a `URLSession` given the parameters provided and returns a completion handler containing either a `Dictionary` of the parsed, returned JSON, or an error.

     - Parameter path:  String The path the `URLSession` calls.
     - Parameter httpMethod: String Corresponding `HTTPMethod`
     - Parameter body: [String:Any] Dictionary of what will become the `URLRequest`'s body.
     - Parameter completionHandler: [String: Any]?
     */
    public func callServer(path: String, httpMethod: String, body: [String: Any], verifyAppEnable: Bool = true, completionHandler:
        @escaping ([String: Any]?, Error?) -> Void) {
        if (verifyAppEnable && !isAppEnable) {
            print("App is disable")
            completionHandler(nil, BAKitError.appDisable)
            return
        }
        
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

        if (path == EndPoints.Me || path.contains(EndPoints.GeoFenceLocation)) && httpMethod == String.HTTPMethod.GET {
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

    public func callServer(forList path: String, httpMethod: String, body: [String: Any], verifAppEnable: Bool = true, completionHandler:@escaping ([[String: Any]]?, Error?) -> Void) {
        if (verifAppEnable && !isAppEnable) {
            print("App is disable")
            completionHandler(nil, BAKitError.appDisable)
            return
        }
        
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
    
    //Find and update the location permission and notification permission in the backend.
       @objc public func updatePermissionStates() {
           var locationSharingEnable = false
           let center = UNUserNotificationCenter.current()

           if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                   case .notDetermined, .restricted, .denied:
                       locationSharingEnable = false

                   case .authorizedAlways, .authorizedWhenInUse:
                       locationSharingEnable = true
                   default:
                       locationSharingEnable = false
               }
           }

           center.getNotificationSettings { (settings) in
               var notificationPermission = false
               if(settings.authorizationStatus == .authorized) {
                   notificationPermission = true

               } else {
                   notificationPermission = false
               }
               let dictPara: [String: Any] = ["notificationPermission": notificationPermission,
                                              "locationPermission": locationSharingEnable]
               let body =  ["attributes" : ["stock": dictPara]]
               BoardActive.client.updateUserData(body: body) { (response, error) in
                 print(response as Any)
               }
           }
       }
    
    /**
     Function remove save user locations.
     */
    public func removeSaveUserLocations() {
        userDefaults?.set(nil, forKey: String.ConfigKeys.userLocations)
    }
    
    /**
     Function save device location locally.
     */
    private func saveLocationLocally(location: CLLocation) {
        if let locationList = userDefaults?.value(forKey: String.ConfigKeys.userLocations) as? [[String: Double]] {
            var arrLocations = locationList
            arrLocations.append(formatLocation(location: location)!)
            userDefaults?.set(arrLocations, forKey: String.ConfigKeys.userLocations)
        } else {
            let arrLocation = [formatLocation(location: location)]
            userDefaults?.set(arrLocation, forKey: String.ConfigKeys.userLocations)
        }
    }
    
    /**
     Function formats the location and returns the dictionary.
     - Returns: Dictionary which contains latitued and longitude in dictionary format.
     */
    private func formatLocation(location: CLLocation) -> Dictionary<String, Double>? {
        return [String.NetworkCallRelated.Latitude: location.coordinate.latitude, String.NetworkCallRelated.Longitude: location.coordinate.longitude]
    }
}

//Method to handle geofence feature
extension BoardActive {
    public func storeAppLocations() {
        if (userDefaults?.value(forKey: String.ConfigKeys.geoFenceLocations) == nil) {
            downloadGeofenceLocation { response, error in
                if let arrLocations = response?["data"] as? [[String : Any]], error == nil {
                    var locationList: [[String: Any]] = []
                    for location in arrLocations {
                        let geoFenceLocation = ["longitude":(location["coordinates"] as? [[String: Any]])?.first?["longitude"] ?? "", "latitude":(location["coordinates"] as? [[String: Any]])?.first?["latitude"] ?? "", "locationId": location["id"]!, "radius": location["radius"] as? Int ?? 100, "lastNotificationDate":""] as [String: Any]
                        locationList.append(geoFenceLocation)
                    }
                    self.userDefaults?.set(locationList, forKey: String.ConfigKeys.geoFenceLocations)
                    self.setupRegion()
                } else {
                    os_log("\n[BoardActive] downloadGeofenceLocation :: Error: Not able to fetch geofence location = %s.\n", error?.localizedDescription ?? "")
                    return
                }
            }
            
        } else {
            setupRegion()
        }
    }
    
    private func setupRegion() {
        if let geofenceLocations = userDefaults?.value(forKey: String.ConfigKeys.geoFenceLocations) as? [[String: Any]] {
            let arrFilterLocation = geofenceLocations.filter { location in
                if let notifyDate = location["lastNotificationDate"] as? Date {
                    return (Date().timeIntervalSince(notifyDate) > geofenceNotifyTimeLimit)
                } else {
                    return true
                }
            }
            
            for (index, geoFenceLocation) in arrFilterLocation.enumerated() {
                let location = Location.init(fromDictionary: geoFenceLocation)
                if (index>=20) {
                    break
                }
                createGeoFence(location: location)
            }
            print(geofenceLocations)
        }
    }
    
    func createGeoFence(location: Location) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Geofence not supported.")
            return
         }
        let region = CLCircularRegion(
            center: CLLocationCoordinate2DMake(location.latitude ?? 0.0, location.longitude ?? 0.0),
            radius: CLLocationDistance(location.radius ?? geofenceRadius),
            identifier: location.locationId!)

        region.notifyOnEntry = true
        region.notifyOnExit = false
        locationManager.startMonitoring(for: region)
    }
    
    public func stopMonitoring(region: CLRegion) {
        guard
          let circularRegion = region as? CLCircularRegion
        else { return }
        locationManager.stopMonitoring(for: circularRegion)
        if let geofenceLocations = userDefaults?.value(forKey: String.ConfigKeys.geoFenceLocations) as? [[String: Any]] {
            var arrLocations = geofenceLocations
            for (index, geoFenceLocation) in arrLocations.enumerated() {
                var location = Location.init(fromDictionary: geoFenceLocation)
                if (location.locationId == circularRegion.identifier) {
                    location.lastNotificationDate = Date()
                    arrLocations[index] = location.toDictionary()
                    userDefaults?.set(arrLocations, forKey: String.ConfigKeys.geoFenceLocations)
                    break
                }
            }
            storeAppLocations()
            postLocation(location: CLLocation(latitude: circularRegion.center.latitude, longitude: circularRegion.center.longitude))
            print(geofenceLocations)
        }
    }
    
    public func removeGeofenceLocations() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        userDefaults?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
    }
}
