//
//  BoardActive.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/23/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit
import os.log
import INTULocationManager

public protocol BoardActiveDelegate: NSObject {
    func appReceivedRemoteNotification(notification: [AnyHashable: Any])
}


public enum NetworkError: Error {
    case BadJSON
    case NSError
}

/**
 Dev and prod base urls plus their associated endpoints.
 */
public enum EndPoints {
    static let DevEndpoint  = "https://springer-api.boardactive.com/mobile/v1"
    static let ProdEndpoint = "https://api.boardactive.com/mobile/v1"
    static let Events       = "/events"
    static let Me           = "/me"
    static let Locations    = "/locations"
    static let Login        = "/login"
}

/**
 A succinct means of denoting which `CLLocationManager` permission the app will request from the user.
 */
public enum AuthorizationMode: String {
    case always
    case whenInUse
}

public class BoardActive: NSObject {
    /**
     A property returning the BoardActive singleton.
     */
    public static let client = BoardActive()
    public var userDefaults = UserDefaults.init(suiteName: "BAKit")
    public var isDevEnv = false
    public weak var delegate: BoardActiveDelegate?
    
    private var locationManager = INTULocationManager.sharedInstance()
    private var currentLocationRequestID: INTULocationRequestID?
    private var currentLocation: CLLocation?
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
    
    /**
        If error occurs, block will execute with status other than `INTULocationStatusSuccess` and subscription will be kept alive.
     */
    public func monitorLocation() {
        weak var weakSelf = BoardActive.client
        DispatchQueue.main.async {
            weakSelf?.currentLocationRequestID = weakSelf?.locationManager.subscribeToLocationUpdates(withDesiredAccuracy: .room) { (location, accuracy, status) in
                guard status == INTULocationStatus.success, accuracy.rawValue == 5 else {
                    os_log("[BoardActive] :: monitorLocation : status : %d", status.rawValue)
                    NotificationCenter.default.post(name: NSNotification.Name("Location Update Error"), object: ["status":status.rawValue])
                    return
                }
                
                if weakSelf?.userDefaults?.object(forKey: String.Attribute.DateLocationPermissionRequested) == nil {
                    weakSelf?.userDefaults?.set(Date().iso8601, forKey: String.Attribute.DateLocationPermissionRequested)
                    weakSelf?.userDefaults?.synchronize()
                }
                
                if weakSelf?.currentLocation == nil {
                    weakSelf?.currentLocation = location
                }
                
                weakSelf?.distanceBetweenLocations = location!.distance(from: weakSelf!.currentLocation!)
                
                if weakSelf!.distanceBetweenLocations! >= 5.0 {
                    weakSelf!.postLocation(location: location!)
                    weakSelf?.distanceBetweenLocations = 0
                }
                
                weakSelf?.currentLocation = location
            }
            
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied, .authorizedWhenInUse:
                    self.userDefaults?.set(false, forKey: String.Attribute.LocationPermission)
                    self.userDefaults?.synchronize()
                case .authorizedAlways:
                    self.userDefaults?.set(true, forKey: String.Attribute.LocationPermission)
                    self.userDefaults?.synchronize()
                }
            } else {
                
            }
        }
    }
    
    private func revokeLocationSubscription() {
        self.locationManager.cancelLocationRequest(self.currentLocationRequestID!)
    }
    
    deinit {
        revokeLocationSubscription()
    }
    
    //If regular location updates provide a better solution, call `requestLocations(authorizationMode:AuthorizationMode)`.
    /**
     Functions as an as needed means of procuring the user's current location.
     - Returns: `CLLocation?` An optional `CLLocation` obtained by `CLLocationManager's` `requestLocation()` function.
     */
    public func getCurrentLocations() -> Dictionary<String,String>? {
        if let latitude = currentLocation?.coordinate.latitude, let longitude = currentLocation?.coordinate.longitude {
            return [String.NetworkCallRelated.Latitude: "\(latitude)", String.NetworkCallRelated.Longitude: "\(longitude)"]
        }
        return nil
    }
    
    /**
     Calls `stopUpdatingLocation` on BoardActive's private CLLocationManager property.
     */
    public func stopUpdatingLocation() {
        revokeLocationSubscription()
    }
    
    
    
    // MARK: Class Functions
    
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
            String.HeaderKeys.AcceptEncodingHeader  : String.HeaderValues.GzipDeflate,
            String.HeaderKeys.AcceptHeader          : String.HeaderValues.WildCards,
            String.HeaderKeys.AppKeyHeader          : String.HeaderValues.AppKey,
            String.HeaderKeys.AppIdHeader           : String.HeaderValues.AppId,
            String.HeaderKeys.AppVersionHeader      : String.HeaderValues.AppVersion,
            String.HeaderKeys.CacheControlHeader    : String.HeaderValues.NoCache,
            String.HeaderKeys.ConnectionHeader      : String.HeaderValues.KeepAlive,
            String.HeaderKeys.ContentTypeHeader     : String.HeaderValues.ApplicationJSON,
            String.HeaderKeys.DeviceOSHeader        : String.HeaderValues.iOS,
            String.HeaderKeys.DeviceOSVersionHeader : String.HeaderValues.DeviceOSVersion,
            String.HeaderKeys.DeviceTokenHeader     : tokenString,
            String.HeaderKeys.DeviceTypeHeader      : String.HeaderValues.DeviceType,
            String.HeaderKeys.HostHeader            : hostKey,
            String.HeaderKeys.UUIDHeader            : String.HeaderValues.UUID
        ]
        return headers
    }
    
    private func retrievePath(isDev:Bool) -> String {
        if isDevEnv {
            return EndPoints.DevEndpoint
        } else {
            return EndPoints.ProdEndpoint
        }
    }
    
    public func postLogin(email: String, password: String) {
        let path = "\(EndPoints.Login)"
        let body: [String: Any] = [
            String.ConfigKeys.Email: email,
            String.ConfigKeys.Password: password
        ]
        
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body as Dictionary<String, AnyObject>) { parsedJSON, err in
            guard err == nil else {
                return
            }
            
            if let parsedJSON = parsedJSON {
                let payload: LoginPayload = LoginPayload.init(fromDictionary: parsedJSON)
                
//                self.userDefaults?.set(payload.avatarImageId, forKey: "avatarImageId")
//                self.userDefaults?.set(payload.avatarUrl, forKey: "avatarUrl")
//                self.userDefaults?.set(payload.customerId, forKey: "customerId")
//                self.userDefaults?.set(payload.firstName, forKey: "firstName")
//                self.userDefaults?.set(payload.googleAvatarUrl, forKey: "googleAvatarUrl")
//                self.userDefaults?.set(payload.guid, forKey: "guid")
                self.userDefaults?.set(payload.id, forKey: String.ConfigKeys.ID)
//                self.userDefaults?.set(payload.lastName, forKey: "lastName")
                self.userDefaults?.set(true, forKey: .LoggedIn)
                self.userDefaults?.synchronize()
                print(payload)
            }
            os_log("[BoardActive] :: postLogin: %s", parsedJSON.debugDescription)
        }
    }
    
    public func registerDevice() {
        let path = "\(EndPoints.Me)"
        
        let body: [String: Any] = [
            String.ConfigKeys.Email: self.userDefaults?.object(forKey: String.ConfigKeys.Email) as Any,
            String.HeaderKeys.DeviceOSHeader: String.HeaderValues.iOS,
            String.HeaderKeys.DeviceOSVersionHeader: String.HeaderValues.DeviceOSVersion
        ]
        
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body) { parsedJSON, err in
            guard err == nil else {
                return
            }
            
            if let parsedJSON = parsedJSON {
                self.userDefaults?.set(true, forKey: .DeviceRegistered)
                os_log("[BoardActive] :: registerDevice : parsedJSON : %s", parsedJSON.description)
            }
        }
    }
    
    /**
     Creates an Event using the information provided and then logs said Event to the BoardActive server.
     
     - Parameter name: `String`
     - Parameter googleMessageId: `String` The value associated with key "gcm.message_id" in notifications.
     - Parameter messageId: `String` The value associated with the key "messageId" in notifications.
     */
    public func postEvent(name: String, googleMessageId: String, messageId: String) {
        let path = "\(EndPoints.Events)"
        
        let body: [String: Any] = [
            String.EventKeys.EventName: name,
            String.EventKeys.MessageId: messageId,
            String.EventKeys.Inbox: ["":""],
            String.EventKeys.FirebaseNotificationId: googleMessageId,
        ]
        
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body) { _, err in
            guard err == nil else {
                return
            }
        }
    }
    
    /**
     Derives a latitude and longitude from the location parameter, couples the coordinate with an iso8601 formatted date, and then updates the server and database with user's timestamped location.
     
     - Parameter location: `CLLocation` The user's current location.
     */
    public func postLocation(location: CLLocation) {
        let path = "\(EndPoints.Locations)"
        
        let body: [String: Any] = [
            String.NetworkCallRelated.Latitude: "\(location.coordinate.latitude)",
            String.NetworkCallRelated.Longitude: "\(location.coordinate.longitude)",
            String.NetworkCallRelated.DeviceToken: Date().iso8601 as AnyObject
            ]
        print("PATH :: \(path) \n BODY :: \(body)")
        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body) { parsedJSON, err in
            guard err == nil else {
                fatalError()
                return
            }
            os_log("[BA:client:updateLocation] :: jsonArray :: %s", parsedJSON.debugDescription)
        }
    }
    
    /**
     A means of updating the user's associated data.
     
     - Parameter email: `String` An email that will be associated with the user on the server then saved to the database.
     */
    public func postMe(attributes: Attributes, httpMethod: String) {
        let path = "\(EndPoints.Me)"
        
        let body: [String: Any] = [
            String.Attribute.Attrs:[
                String.Attribute.Stock: attributes.toDictionary()[String.Attribute.Stock],
                String.Attribute.Custom: attributes.toDictionary()[String.Attribute.Custom]
            ] as AnyObject
        ]
        
        self.callServer(path: path, httpMethod: httpMethod, body: body) { parsedJSON, err in
            guard err == nil else {
                fatalError()
                return
            }
            os_log("[BoardActive] : updateMe : OK : %s", (parsedJSON.debugDescription))
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
        @escaping ([String:Any]?, Error?) -> Void) {
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
                    os_log("[BA:client:callServer] :: dataString : %s", dataString.debugDescription)
                    
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
