//
//  StringConstants.swift
//  BAKit
//
//  Created by Ed Salter on 3/20/19.
//

import Foundation

public extension String {
    enum ConfigKeys {
        public static let AppId       = "AppId"
        public static let AppKey      = "AppKey"
        public static let UUID        = "UUID"
        public static let Email       = "email"
        public static let Password    = "password"
        public static let ID          = "id"
        public static let DeviceToken = "deviceToken"
    }
    
    enum HeaderKeys {
        static let AccessControlHeader   = "Access-Control-Allow-Origin"
        static let AppIdHeader           = "X-BoardActive-App-Id"
        static let AppKeyHeader          = "X-BoardActive-App-Key"
        static let AppVersionHeader      = "X-BoardActive-App-Version"
        static let DeviceOSHeader        = "X-BoardActive-Device-OS"
        static let DeviceOSVersionHeader = "X-BoardActive-Device-OS-Version"
        static let DeviceTokenHeader     = "X-BoardActive-Device-Token"
        static let DeviceTypeHeader      = "X-BoardActive-Device-Type"
        static let UUIDHeader            = "X-BoardActive-Device-UUID"
        static let ContentTypeHeader     = "Content-Type"
        static let AcceptHeader          = "Accept"
        static let CacheControlHeader    = "Cache-Control"
        static let HostHeader            = "Host"
        static let AcceptEncodingHeader  = "accept-encoding"
        static let ConnectionHeader      = "Connection"
    }
    
    enum HeaderValues {
        static let WildCards       = "*/*"
        static let AppVersion      = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        static let NoCache         = "no-cache"
        static let ApplicationJSON = "application/json"
        static let GzipDeflate     = "gzip, deflate"
        static let KeepAlive       = "keep-alive"
        static let DevHostKey      = "springer-api.boardactive.com"
        static let ProdHostKey     = "api.boardactive.com"
        static let iOS             = "ios"
        static let FCMToken        = String.ConfigKeys.DeviceToken
        static let AppId           = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppId) ?? ""
        static let AppKey          = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey) ?? ""
        static let DeviceOSVersion = UIDevice.current.systemVersion
        static let DeviceType      = UIDevice.modelName
        static let UUID            = UIDevice.current.identifierForVendor!.uuidString
    }
    
    // MARK: Network Call Related Keys
    enum NetworkCallRelated {
        static let DeviceToken = String.ConfigKeys.DeviceToken
        static let MessageId   = "messageId"
        static let Latitude    = "latitude"
        static let Longitude   = "longitude"
        static let DeviceTime  = "deviceTime"
    }
    
    // MARK: Event logging related
    static let Received               = "received"
    static let Opened                 = "opened"
    
    static let TappedAndTransitioning = "TAPPED & TRANSITIONING"
    static let ReceivedBackground     = "RECEIVED BACKGROUND"
    
    // MARK: Calculated
    static let SystemVersion = UIDevice.current.systemVersion
    static let AppVersion = UIApplication.appVersion
    static let DeviceType = UIDevice.modelName
    
    // MARK: Onboarding
    static let Step1HeadlineText = "Welcome to BoardActive"
    static let Step1BodyText     = "This app allows you to try out the BoardActive platform."
    static let Step2HeadlineText = "Allow Notifications"
    static let Step2BodyText     = "Enabling notifications allows your custom messages to be delivered to your phone."
    static let Step3HeadlineText = "Allow Location"
    static let Step3BodyText     = "Enabling Locations activates custom BoardActive Geofences."
    static let Step4HeadlineText = "Get ready to enter your App ID and Email"
    static let Step4BodyText     = "The BoardActive platform provides your App ID and Email at the positions indicated above."
    static let Step5HeadlineText = "App ID and Email"
    static let Step5BodyText     = "Enter the App ID provided when you created your account as well as the associated Email."
    
    // MARK: Notification Keys
    enum NotificationKeys {
        static let InfoUpdateNotification     = "infoUpdateNotification"
        static let UserSelectedNotificationId = "com.apple.UNNotificationDefaultActionIdentifier"
        static let IncrementAppBadge          = "IncrementAppBadge"
        static let DecrementAppBadge          = "DecrementAppBadge"
    }
    
    // MARK: CONFIG KEYS
    static let BAKitFirebaseAppConfigName     = "BAKit_Config"
    static let ClientAppFirebaseAppConfigName = "Client_Config"
    static let BAKit_FirebaseBundle           = "BAKit_FirebaseBundle"
    static let DeviceRegistered               = "deviceRegistered"
    static let LoggedIn                       = "loggedIn"
   
    
    enum EventKeys {
        static let EventName = "name"
        static let MessageId = "messageId"
        static let Inbox = "inbox"
        static let FirebaseNotificationId = "firebaseNotificationId"
    }
    
    enum Attribute {
        static let Attrs                               = "attributes"
        static let Stock                               = "stock"
        static let Custom                              = "custom"
        static let Name                                = "name"
        static let Email                               = String.ConfigKeys.Email
        static let Phone                               = "phone"
        static let DateBorn                            = "dateBorn"
        static let Gender                              = "gender"
        static let Facebook                            = "facebookUrl"
        static let LinkedIn                            = "linkedInUrl"
        static let Twitter                             = "twitterUrl"
        static let Instagram                           = "instagramUrl"
        static let Avatar                              = "avatarUrl"
        static let DeviceOS                            = "deviceOS"
        static let DeviceOSVersion                     = "deviceOSVersion"
        static let DeviceType                          = "deviceType"
        static let DeviceToken                         = String.ConfigKeys.DeviceToken
        public static let DateLocationPermissionRequested     = "dateLocationPermissionRequested"
        static let DateNotificationPermissionRequested = "dateNotificationPermissionRequested"
        static let LocationPermission                  = "locationPermission"
        static let NotificationPermission              = "notificationPermission"
    }
    
    enum HTTPMethod {
        static let GET  = "GET"
        static let POST = "POST"
        static let PUT  = "PUT"
    }
}

