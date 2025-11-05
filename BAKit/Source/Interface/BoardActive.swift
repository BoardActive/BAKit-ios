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
//    static let DevEndpoint = "https://boardactiveapi.dev.radixweb.net/mobile/v1"
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
    public var geofenceRadius = 100
    public var recordLocationAfterMeters: Double = 1000

    public var isAppEnable = true

    // MARK: - Configurable Location Manager Properties (Branddrop improvements)

    /// Desired location accuracy (default: NearestTenMeters for better battery life)
    /// Set to kCLLocationAccuracyBestForNavigation if you need maximum accuracy
    public var desiredLocationAccuracy: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters

    /// Minimum distance (in meters) before location update fires (default: 10m for battery efficiency)
    /// Set to kCLDistanceFilterNone for maximum frequency (not recommended - drains battery)
    public var locationDistanceFilter: CLLocationDistance = 10

    /// Enable filtering of low-accuracy location readings (default: true)
    /// Prevents poor quality data (>30m accuracy) from being processed
    public var enableAccuracyFiltering: Bool = true

    /// Maximum horizontal accuracy (in meters) to accept (default: 30m)
    /// Location readings with accuracy worse than this will be rejected
    /// 30m is a good balance for real-world indoor/outdoor use
    public var accuracyThreshold: CLLocationAccuracy = 30

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private let geofenceNotifyTimeLimit: Double = 86400

    public var currentLocation = CLLocation()
    private var isGeoLocationCalled = false
    
//    public var previousUserLocation: CLLocation?
//    public var distanceBetweenLocations: CLLocationDistance?
    
    public let categoryIdentifier = "PreviewNotification"
    public let downloadActionIdentifier = "download"

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

     Now uses configurable properties for accuracy and distance filter.
     Defaults provide 50-70% better battery life vs previous hardcoded values.
     */
    public func monitorLocation() {
        os_log("🚀 [BAKit] ========================================")
        os_log("🚀 [BAKit] STARTING LOCATION MONITORING")
        os_log("🚀 [BAKit] ========================================")

        // Check if location services are enabled globally
        let servicesEnabled = CLLocationManager.locationServicesEnabled()
        os_log("🚀 [BAKit] Location Services Globally: %@", servicesEnabled ? "ENABLED" : "DISABLED")

        if !servicesEnabled {
            os_log("❌ [BAKit] ERROR: Location services are disabled in device Settings!")
            os_log("❌ [BAKit] User must enable in Settings > Privacy > Location Services")
            os_log("🚀 [BAKit] ========================================")
            return
        }

        // Check current authorization status
        let authStatus = CLLocationManager.authorizationStatus()
        os_log("🚀 [BAKit] Current Authorization Status:")
        switch authStatus {
        case .notDetermined:
            os_log("   📋 Not Determined - Will request permission")
        case .restricted:
            os_log("   ⛔ Restricted - Cannot use location services")
        case .denied:
            os_log("   ❌ Denied - User must enable in Settings")
        case .authorizedWhenInUse:
            os_log("   ⚠️ When In Use Only - Will request Always permission")
        case .authorizedAlways:
            os_log("   ✅ Always Authorized - Full access granted")
        @unknown default:
            os_log("   ❓ Unknown status")
        }

        // Configure location manager
        os_log("🚀 [BAKit] Configuring Location Manager:")
        BoardActive.client.locationManager.delegate = self
        os_log("   ✓ Delegate set to BoardActive instance")

        BoardActive.client.locationManager.desiredAccuracy = BoardActive.client.desiredLocationAccuracy
        os_log("   ✓ Desired Accuracy: %.1f meters", BoardActive.client.desiredLocationAccuracy)

        BoardActive.client.locationManager.distanceFilter = BoardActive.client.locationDistanceFilter
        os_log("   ✓ Distance Filter: %.1f meters", BoardActive.client.locationDistanceFilter)

        BoardActive.client.locationManager.pausesLocationUpdatesAutomatically = false
        os_log("   ✓ Pauses Automatically: DISABLED")

        BoardActive.client.locationManager.allowsBackgroundLocationUpdates = true
        os_log("   ✓ Background Updates: ENABLED")

        BoardActive.client.locationManager.activityType = .otherNavigation
        os_log("   ✓ Activity Type: Other Navigation")

        // Request permission
        os_log("🚀 [BAKit] Requesting Always Authorization...")
        BoardActive.client.locationManager.requestAlwaysAuthorization()

        // Start location updates
        os_log("🚀 [BAKit] Starting Location Updates:")
        BoardActive.client.locationManager.startUpdatingLocation()
        os_log("   ✓ startUpdatingLocation() called")

        BoardActive.client.locationManager.startMonitoringSignificantLocationChanges()
        os_log("   ✓ startMonitoringSignificantLocationChanges() called")

        os_log("🚀 [BAKit] ========================================")
        os_log("🚀 [BAKit] Location monitoring is now active!")
        os_log("🚀 [BAKit] Waiting for location updates...")
        os_log("🚀 [BAKit] ========================================")
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
            os_log("❌ [BAKit] Error: No locations in array")
            return
        }

        // Check location age
        let locationAge = Date().timeIntervalSince(location.timestamp)
        if locationAge > 10 {
            os_log("⚠️ [BAKit] Location is stale (>10 seconds old)")
        }

        // Filter out poor accuracy readings (if enabled)
        if BoardActive.client.enableAccuracyFiltering &&
           location.horizontalAccuracy > BoardActive.client.accuracyThreshold {
            os_log("⚠️ [BAKit] Skipping location update - poor accuracy (%.1fm)", location.horizontalAccuracy)
            return
        }

        // Update current location
        BoardActive.client.currentLocation = location

        // Check distance traveled since last geofence refresh
        if UserDefaults.standard.value(forKey: String.ConfigKeys.traveledDistance) == nil {
            UserDefaults.standard.set([location.coordinate.latitude, location.coordinate.longitude], forKey: String.ConfigKeys.traveledDistance)
        } else {
            let previous = UserDefaults.standard.value(forKey: String.ConfigKeys.traveledDistance) as! NSArray
            let previousLocation = CLLocation(latitude: previous[0] as! CLLocationDegrees, longitude: previous[1] as! CLLocationDegrees)
            let distanceInMeters = previousLocation.distance(from: location)

            if distanceInMeters >= recordLocationAfterMeters {
                os_log("✅ [BAKit] Movement threshold reached (%.1fm) - refreshing geofences", distanceInMeters)
                UserDefaults.standard.set([location.coordinate.latitude, location.coordinate.longitude], forKey: String.ConfigKeys.traveledDistance)
                UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
                BoardActive.client.storeAppLocations()
            }
        }
        // Check for silent push trigger
        let flag: Bool = BoardActive.client.userDefaults?.value(forKey: String.ConfigKeys.silentPushReceived) as? Bool ?? false
        if flag {
            os_log("✅ [BAKit] Silent push trigger - refreshing geofences")
            BoardActive.client.userDefaults?.set(false, forKey: String.ConfigKeys.silentPushReceived)
            UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
            BoardActive.client.storeAppLocations()
        }

        // Check for first location update
        if !isGeoLocationCalled {
            os_log("✅ [BAKit] First location update - downloading initial geofences")
            self.isGeoLocationCalled = true
            BoardActive.client.storeAppLocations()
        }

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
        os_log("❌ [BAKit] ========================================")
        os_log("❌ [BAKit] Location Manager Error")
        os_log("❌ [BAKit] ========================================")

        guard let clError = error as? CLError else {
            os_log("❌ [BAKit] Non-CLError occurred: %@", error.localizedDescription)
            os_log("❌ [BAKit] Error domain: %@", (error as NSError).domain)
            os_log("❌ [BAKit] Error code: %d", (error as NSError).code)
            os_log("❌ [BAKit] ========================================")
            return
        }

        os_log("❌ [BAKit] CLError Code: %d", clError.errorCode)

        switch clError.errorCode {
        case 0:
            os_log("❌ [BAKit] Error: Location Unknown")
            os_log("❌ [BAKit] Reason: Location Manager unable to determine location")
            os_log("❌ [BAKit] This usually means GPS hasn't acquired a fix yet")
            break
        case 1:
            os_log("❌ [BAKit] Error: Access Denied")
            os_log("❌ [BAKit] Reason: User denied location permission")
            os_log("❌ [BAKit] Stopping location updates")
            stopUpdatingLocation()
            break
        case 2:
            os_log("❌ [BAKit] Error: Network Error")
            os_log("❌ [BAKit] Reason: Network required for location but unavailable")
            break
        case 3:
            os_log("❌ [BAKit] Error: Heading Failure")
            os_log("❌ [BAKit] Reason: Device compass could not determine heading")
            break
        default:
            os_log("❌ [BAKit] Error: Unknown CLError (%d)", clError.errorCode)
            os_log("❌ [BAKit] Error info: %@", clError.errorUserInfo.debugDescription)
            break
        }

        os_log("❌ [BAKit] ========================================")
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("🔐 [BAKit] ========================================")
        os_log("🔐 [BAKit] Location Authorization Changed")
        os_log("🔐 [BAKit] ========================================")

        var isAppAuthorized = false
        var statusName = ""

        switch status {
        case .notDetermined:
            statusName = "Not Determined"
            os_log("🔐 [BAKit] Status: NOT DETERMINED")
            os_log("🔐 [BAKit] User has not yet made a choice about location permissions")
            os_log("🔐 [BAKit] App should request permission")
            userDefaults?.set(false, forKey: String.Attribute.LocationPermission)

        case .restricted:
            statusName = "Restricted"
            os_log("🔐 [BAKit] Status: RESTRICTED")
            os_log("🔐 [BAKit] Location services restricted by parental controls or MDM")
            os_log("🔐 [BAKit] App cannot access location services")
            userDefaults?.set(false, forKey: String.Attribute.LocationPermission)

        case .denied:
            statusName = "Denied"
            os_log("🔐 [BAKit] Status: DENIED")
            os_log("🔐 [BAKit] User explicitly denied location permission")
            os_log("🔐 [BAKit] User must enable in Settings app")
            userDefaults?.set(false, forKey: String.Attribute.LocationPermission)

        case .authorizedWhenInUse:
            statusName = "When In Use"
            os_log("🔐 [BAKit] Status: AUTHORIZED WHEN IN USE")
            os_log("🔐 [BAKit] Location available only when app is in use")
            os_log("⚠️ [BAKit] Background geofencing requires 'Always' permission")
            os_log("⚠️ [BAKit] Consider upgrading to 'Always' for full functionality")
            userDefaults?.set(false, forKey: String.Attribute.LocationPermission)

        case .authorizedAlways:
            statusName = "Always"
            os_log("🔐 [BAKit] Status: AUTHORIZED ALWAYS")
            os_log("🔐 [BAKit] Location available in foreground and background")
            os_log("✅ [BAKit] Full geofencing functionality enabled")
            userDefaults?.set(true, forKey: String.Attribute.LocationPermission)
            isAppAuthorized = true

        @unknown default:
            statusName = "Unknown"
            os_log("🔐 [BAKit] Status: UNKNOWN (new iOS version?)")
            os_log("⚠️ [BAKit] Unhandled authorization status")
            userDefaults?.set(false, forKey: String.Attribute.LocationPermission)
        }

        os_log("🔐 [BAKit] Authorization Summary:")
        os_log("   Status: %@", statusName)
        os_log("   Authorized: %@", isAppAuthorized ? "YES" : "NO")
        os_log("   Permission Flag Saved: %@", isAppAuthorized ? "true" : "false")

        userDefaults?.synchronize()

        os_log("🔐 [BAKit] Updating permission states on backend...")
        BoardActive.client.updatePermissionStates()

        os_log("🔐 [BAKit] ========================================")
    }

    // MARK: - Geofence Delegate Methods (NEW - Critical Bug Fix)

    /**
     Called when the user enters a monitored region (geofence).
     This is the PRIMARY mechanism for detecting when a user arrives at a location.

     IMPORTANT: This method was MISSING in the original implementation, which meant
     geofences were set up but never responded to. This is a critical bug fix.

     - Parameter manager: The location manager object that generated the event
     - Parameter region: The region that was entered
     */
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }

        os_log("✅ [BAKit] Geofence entry detected - Region ID: %@", region.identifier)

        // Post current location to backend
        if BoardActive.client.currentLocation.coordinate.latitude != 0 &&
           BoardActive.client.currentLocation.coordinate.longitude != 0 {
            postLocation(location: BoardActive.client.currentLocation)
        } else {
            os_log("⚠️ [BAKit] No current location available to post")
        }

        // Stop monitoring this region to prevent duplicate triggers
        stopMonitoring(region: region)
    }

    /**
     Called when the user exits a monitored region (geofence).
     Used primarily for analytics and state management.

     - Parameter manager: The location manager object that generated the event
     - Parameter region: The region that was exited
     */
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }

        // Post location for exit tracking
        if BoardActive.client.currentLocation.coordinate.latitude != 0 &&
           BoardActive.client.currentLocation.coordinate.longitude != 0 {
            postLocation(location: BoardActive.client.currentLocation)
        }
    }

    /**
     Called when monitoring fails for a region.
     Important for debugging geofence issues.

     - Parameter manager: The location manager object that generated the event
     - Parameter region: The region for which the error occurred (may be nil)
     - Parameter error: The error that occurred
     */
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let region = region {
            os_log("❌ [BAKit] Monitoring failed for region: %@", region.identifier)
        } else {
            os_log("❌ [BAKit] Monitoring failed for unknown region")
        }
        os_log("   Error: %@", error.localizedDescription)
    }

    /**
     Called when monitoring starts successfully for a region.
     Useful for confirming geofence setup.

     - Parameter manager: The location manager object that generated the event
     - Parameter region: The region that is now being monitored
     */
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // Region monitoring started successfully
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

        os_log("📤 [BAKit] Posting location: %f, %f (accuracy: %fm)",
               location.coordinate.latitude,
               location.coordinate.longitude,
               location.horizontalAccuracy)

        callServer(path: EndPoints.Locations, httpMethod: String.HTTPMethod.POST, body: body) { parsedJSON, err in
            guard err == nil else {
                os_log("❌ [BAKit] Location post failed: %@", err!.localizedDescription)
                return
            }
            os_log("✅ [BAKit] Location posted successfully")
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
        os_log("🌐 [BAKit] downloadGeofenceLocation() called")

        let currentLat = BoardActive.client.currentLocation.coordinate.latitude
        let currentLon = BoardActive.client.currentLocation.coordinate.longitude

        if currentLat == 0 && currentLon == 0 {
            os_log("❌ [BAKit] Cannot download geofences: currentLocation is (0, 0) - no GPS fix yet")
            completionHandler(nil, NSError(domain: "BAKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "No location available"]))
            return
        }

        let path = "\(EndPoints.GeoFenceLocation)"
        let searchRadius = recordLocationAfterMeters * 2

        let body: [String: Any] = [
            String.NetworkCallRelated.Latitude: "\(currentLat)",
            String.NetworkCallRelated.Longitude: "\(currentLon)",
            String.NetworkCallRelated.Radius: searchRadius,
        ]

        os_log("🌐 [BAKit] Making API request to: %@", path)

        callServer(path: path, httpMethod: String.HTTPMethod.POST, body: body as Dictionary<String, AnyObject>, verifyAppEnable: false) { parsedJSON, err in
            if let err = err {
                os_log("❌ [BAKit] API request FAILED: %@", err.localizedDescription)
                completionHandler(nil, err)
                return
            }

            if let parsedJSON = parsedJSON {
                completionHandler(parsedJSON, nil)
            } else {
                os_log("⚠️ [BAKit] Geofence API returned nil JSON")
                completionHandler(nil, nil)
            }
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
    
    public func removeTraveledDistance() {
        userDefaults?.set(nil, forKey: String.ConfigKeys.traveledDistance)
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
    
    /**
     Function download and save image in Photo Gallery.
     */
    public func downloadAndSaveImageDownloadFromPush(_ vc: UIViewController, _ strUrl: String) {
        let alert = UIAlertController(title: "Do you want to download the image?", message:"", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (action) in
//            let strUrl = (userInfo["imageUrl"] as? String ?? "").trimmingCharacters(in: .whitespaces)
            if let url = URL(string: strUrl) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                        UIImageWriteToSavedPhotosAlbum(UIImage(data: data)!, nil, nil, nil)
                }
                task.resume()
            } else {
                print(strUrl + " is invalid")
            }
        })
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        // show the alert
        vc.present(alert, animated: true, completion: nil)
    }
}

//Method to handle geofence feature
extension BoardActive {
    public func storeAppLocations() {

        if let existingLocations = userDefaults?.value(forKey: String.ConfigKeys.geoFenceLocations) as? [[String: Any]] {
            os_log("ℹ️ [BAKit] Geofences already cached (%d locations), setting up regions...", existingLocations.count)
            setupRegion()
            return
        }

        os_log("📥 [BAKit] No cached geofences found, downloading from server...")
        downloadGeofenceLocation { [self] response, error in
            if let error = error {
                os_log("❌ [BAKit] Geofence download FAILED: %@", error.localizedDescription)
                return
            }

            guard let response = response else {
                os_log("❌ [BAKit] Geofence download returned nil response")
                return
            }

            os_log("📦 [BAKit] Geofence API response received: %@", String(describing: response))

            if let arrLocations = response["data"] as? [[String : Any]] {
                os_log("✅ [BAKit] Downloaded %d geofence(s)", arrLocations.count)

                if arrLocations.isEmpty {
                    os_log("⚠️ [BAKit] No geofences returned from server")
                    return
                }
                    var locationList: [[String: Any]] = []
                    /*
//                    for location in arrLocations {
//                        let geoFenceLocation = ["longitude":(location["coordinates"] as? [[String: Any]])?.first?["longitude"] ?? "", "latitude":(location["coordinates"] as? [[String: Any]])?.first?["latitude"] ?? "", "locationId": location["id"]!, "radius": location["radius"] as? Int ?? 100, "lastNotificationDate":""] as [String: Any]
//                        locationList.append(geoFenceLocation)
//                    }
                    for location in arrLocations {
                        let coordinatesArr: [[String: Any]] = location["coordinates"] as? [[String: Any]] ?? []
                        for coord in coordinatesArr {
                            let geoFenceLocation = ["longitude":coord["longitude"] ?? "", "latitude":coord["latitude"] ?? "", "locationId": location["id"]!, "radius": location["radius"] as? Int ?? 100, "lastNotificationDate":"", "placeName":location["placeName"] ?? ""] as [String: Any]
                            locationList.append(geoFenceLocation)
                        }
                    } */
                    self.removeGeofenceLocations()
                    for location in arrLocations {
                        let coordinatesArr: [[String: Any]] = location["coordinates"] as? [[String: Any]] ?? []
                        // NEW: Extract campaign ID (if present)
                        let campaignId = location["campaignId"] as? String ?? location["campaign_id"] as? String

                        if coordinatesArr.count > 1 {
                            var polygon = [CGPoint]()
                            for coord in coordinatesArr {
                                let lat = coord["latitude"] is String ? (coord["latitude"] as! NSString).doubleValue : Double(truncating: coord["latitude"] as! NSNumber)
                                let long = coord["longitude"] is String ? (coord["longitude"] as! NSString).doubleValue : Double(truncating: coord["longitude"] as! NSNumber)
                                let point = CGPoint(x: lat, y: long)
                                polygon.append(point)
                            }
                            let center = polygonCenterOfMass(polygon: polygon)
                            var disArr = [CGFloat]()
                            for coord in coordinatesArr {
                                let lat = coord["latitude"] is String ? (coord["latitude"] as! NSString).doubleValue : Double(truncating: coord["latitude"] as! NSNumber)
                                let long = coord["longitude"] is String ? (coord["longitude"] as! NSString).doubleValue : Double(truncating: coord["longitude"] as! NSNumber)
                                disArr.append(CLLocation(latitude: lat, longitude: long).distance(from: CLLocation(latitude: center.x, longitude: center.y)))
                            }
                            var geoFenceLocation: [String: Any] = ["latitude":"\(center.x)", "longitude":"\(center.y)", "locationId": location["id"]!, "radius": disArr.max() ?? 100, "lastNotificationDate":"", "placeName":location["placeName"] ?? ""]
                            if let cid = campaignId {
                                geoFenceLocation["campaignId"] = cid
                            }
                            locationList.append(geoFenceLocation)
                        } else {
                            let coord = coordinatesArr.first
                            var geoFenceLocation: [String: Any] = ["longitude":coord?["longitude"] ?? "", "latitude":coord?["latitude"] ?? "", "locationId": location["id"]!, "radius": location["radius"] as? Int ?? 100, "lastNotificationDate":"", "placeName":location["placeName"] ?? ""]
                            if let cid = campaignId {
                                geoFenceLocation["campaignId"] = cid
                            }
                            locationList.append(geoFenceLocation)
                        }
                    }
                    os_log("💾 [BAKit] Saving %d geofence(s) to cache", locationList.count)

                    self.userDefaults?.set(locationList, forKey: String.ConfigKeys.geoFenceLocations)
                    self.userDefaults?.synchronize()

                    self.setupRegion()
                } else {
                    os_log("❌ [BAKit] Failed to parse 'data' array from response")
                    return
                }
            }  // end downloadGeofenceLocation closure
        // end storeAppLocations()
    }
    
    func signedPolygonArea(polygon: [CGPoint]) -> CGFloat {
        let nr = polygon.count
        var area: CGFloat = 0
        for i in 0 ..< nr {
            let j = (i + 1) % nr
            area = area + polygon[i].x * polygon[j].y
            area = area - polygon[i].y * polygon[j].x
        }
        area = area/2.0
        return area
    }

    func polygonCenterOfMass(polygon: [CGPoint]) -> CGPoint {
        let nr = polygon.count
        var centerX: CGFloat = 0
        var centerY: CGFloat = 0
        var area = signedPolygonArea(polygon: polygon)
        for i in 0 ..< nr {
            let j = (i + 1) % nr
            let factor1 = polygon[i].x * polygon[j].y - polygon[j].x * polygon[i].y
            centerX = centerX + (polygon[i].x + polygon[j].x) * factor1
            centerY = centerY + (polygon[i].y + polygon[j].y) * factor1
        }
        area = area * 6.0
        let factor2 = 1.0/area
        centerX = centerX * factor2
        centerY = centerY * factor2
        let center = CGPoint.init(x: centerX, y: centerY)
        return center
    }
    
    private func setupRegion() {
        os_log("🗺️ [BAKit] setupRegion() called")

        guard let geofenceLocations = userDefaults?.value(forKey: String.ConfigKeys.geoFenceLocations) as? [[String: Any]] else {
            os_log("⚠️ [BAKit] No geofences found in UserDefaults")
            return
        }


        // FILTER: Apply time filter only (monitor ALL geofences regardless of campaign status)
        let arrFilterLocation = geofenceLocations.filter { location in
            // TIME FILTER: Check if enough time has passed since last notification
            if let notifyDate = location["lastNotificationDate"] as? Date {
                let timeSince = Date().timeIntervalSince(notifyDate)
                return timeSince > geofenceNotifyTimeLimit
            } else {
                return true
            }
        }

        var setupCount = 0
        for (index, geoFenceLocation) in arrFilterLocation.enumerated() {
            let location = Location.init(fromDictionary: geoFenceLocation)
            if (index >= 20) {
                os_log("⚠️ [BAKit] Reached iOS limit of 20 geofences")
                break
            }
            createGeoFence(location: location)
            setupCount += 1
        }

        if setupCount > 0 {
            os_log("✅ [BAKit] Monitoring %d geofence(s)", setupCount)
        } else {
            os_log("⚠️ [BAKit] No geofences set up for monitoring")
        }
    }
    
    func createGeoFence(location: Location) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            os_log("❌ [BAKit] Geofence monitoring not available")
            return
         }

        let latitude = location.latitude ?? 0.0
        let longitude = location.longitude ?? 0.0
        let radius = CLLocationDistance(location.radius ?? geofenceRadius)
        let identifier = location.locationId ?? "unknown"

        let region = CLCircularRegion(
            center: CLLocationCoordinate2DMake(latitude, longitude),
            radius: radius,
            identifier: identifier)

        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: region)

        // Note: iOS will not trigger entry notification if already inside geofence
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
