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
    static let DevEndpoint = "https://springer-api.boardactive.com/mobile/v1"
    static let ProdEndpoint = "https://api.boardactive.com/mobile/v1"
    static let Events = "/events"
    static let Me = "/me"
    static let Locations = "/locations"
    static let Login = "/login"
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
    public var isDevEnv = false
    public var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    private var distanceBetweenLocations: CLLocationDistance?

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

    // MARK: - Core Location

    public func monitorLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    public func createRegion(location: CLLocation?, start: Bool = false) {
        var region: CLCircularRegion?
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            locationManager.stopUpdatingLocation()
            let coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
            let regionRadius = 100.0

            region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: "BAKitRegion")

            region?.notifyOnExit = true
            region?.notifyOnEntry = true

            guard let reg = region else {
                return
            }

            if start {
                locationManager.stopUpdatingLocation()
                locationManager.startMonitoring(for: reg)
            } else {
                locationManager.stopMonitoring(for: reg)
                locationManager.startUpdatingLocation()
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("\n[BoardActive] locationManager:didENTERRegion : Region: \(region.debugDescription)\n")
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("\n[BoardActive] locationManager:didEXITRegion : Region: \(region.debugDescription)\n")

        locationManager.requestLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            os_log("\n[BoardActive] didUpdateLocations :: Error: Last location of locations = nil.\n")
            return
        }

        if currentLocation == nil {
            currentLocation = location
            postLocation(location: location)
        }

        if let currentLocation = currentLocation, location.distance(from: currentLocation) < 2.0 {
            distanceBetweenLocations = (distanceBetweenLocations ?? 0.0) + location.distance(from: currentLocation)
        } else {
            postLocation(location: location)
            distanceBetweenLocations = 0.0
        }

        currentLocation = location
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
        if userDefaults?.object(forKey: String.Attribute.DateLocationPermissionRequested) == nil {
            let date = Date().iso8601
            userDefaults?.set(date, forKey: String.Attribute.DateLocationPermissionRequested)
        }

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                userDefaults?.set(false, forKey: String.Attribute.LocationPermission)
                locationManager.stopUpdatingLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                userDefaults?.set(true, forKey: String.Attribute.LocationPermission)
                locationManager.startUpdatingLocation()
            }
        }
        userDefaults?.synchronize()
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
        locationManager.stopUpdatingLocation()
    }
    
    public func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    public func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    public func requestLocation() {
        locationManager.requestLocation()
    }

    fileprivate func getHeaders() -> [String: String]? {
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
            String.HeaderKeys.AppKeyHeader: userDefaults?.string(forKey: String.ConfigKeys.AppKey) ?? "",
            String.HeaderKeys.AppIdHeader: userDefaults?.string(forKey: String.ConfigKeys.AppId) ?? "",
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

            os_log("[BoardActive] :: postLogin: %s", parsedJSON.debugDescription)

            completionHandler(parsedJSON, nil)

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
            String.ConfigKeys.Email: userDefaults?.object(forKey: String.ConfigKeys.Email) as Any,
            String.HeaderKeys.DeviceOSHeader: String.HeaderValues.iOS,
            String.HeaderKeys.DeviceOSVersionHeader: String.HeaderValues.DeviceOSVersion,
        ]

        callServer(path: path, httpMethod: String.HTTPMethod.PUT, body: body) { parsedJSON, err in
            guard err == nil else {
                completionHandler(nil, err)
                return
            }

            self.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
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
    public func postEvent(name: String, messageId: String, firebaseNotificationId: String) {
        let path = "\(EndPoints.Events)"

        let body: [String: Any] = [
            String.EventKeys.EventName: name,
            String.EventKeys.MessageId: messageId,
            String.EventKeys.FirebaseNotificationId: firebaseNotificationId,
            String.EventKeys.Inbox: ["": ""],
        ]

        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body) { _, err in
            guard err == nil else {
                return
            }
        }
    }

    /**
     Derives a latitude and longitude from the location parameter, couples the coordinate with an iso8601 formatted date, and then updates the server and database with user's timestamped location.

     - Parameter location: `CLLocation`
     */
    public func postLocation(location: CLLocation) {
        let path = "\(EndPoints.Locations)"

        let body: [String: Any] = [
            String.NetworkCallRelated.Latitude: "\(location.coordinate.latitude)",
            String.NetworkCallRelated.Longitude: "\(location.coordinate.longitude)",
            String.NetworkCallRelated.DeviceTime: Date().iso8601 as AnyObject,
        ]
        print("PATH :: \(path) \n BODY :: \(body)")
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body) { parsedJSON, err in
            guard err == nil else {
                return
            }
            os_log("[BA:client:updateLocation] :: jsonArray :: %s", parsedJSON.debugDescription)
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

        let request = NSMutableURLRequest(url: NSURL(string: destination)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)

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
                os_log("[BA:client:callServer] :: dataTask:error : %s \n response : %s", error!.localizedDescription, response as! HTTPURLResponse)
                return
            }

            if let data = data, (try? JSONSerialization.jsonObject(with: data)) != nil {
                if let dataString = String(data: data, encoding: .utf8) {
                    os_log("[BA:client:callServer] :: dataString : %@", dataString)

                    completionHandler(self.convertToDictionary(text: dataString), nil)
                    return
                }
            }
        })
        dataTask.resume()
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
}
