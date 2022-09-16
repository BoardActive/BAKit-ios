//
//  StringConstants.swift
//  BAKit
//
//  Created by Ed Salter on 3/20/19.
//

import Foundation

public extension String {
    enum AppKeys {
        public static let Prod = "b70095c6-1169-43d6-a5dd-099877b4acb3"
        public static let Dev  = "d17f0feb-4f96-4c2a-83fd-fd6302ae3a16"
    }

    enum ConfigKeys {
        public static let Apps = "Apps"
        public static let AppId = "AppId"
        public static let AppKey = "AppKey"
        public static let UUID = "UUID"
        public static let Email = "email"
        public static let Password = "password"
        public static let ID = "id"
        public static let DeviceToken = "deviceToken"
        public static let DeviceRegistered = "deviceRegistered"
        public static let geoFenceLocations = "geoFenceLocations"
        public static let userLocations = "userLocations"
    }

    enum HeaderKeys {
        static let AccessControlHeader = "Access-Control-Allow-Origin"
        static let AppIdHeader = "X-BoardActive-App-Id"
        static let AppKeyHeader = "X-BoardActive-App-Key"
        static let AppVersionHeader = "X-BoardActive-App-Version"
        static let DeviceOSHeader = "X-BoardActive-Device-OS"
        static let DeviceOSVersionHeader = "X-BoardActive-Device-OS-Version"
        static let DeviceTokenHeader = "X-BoardActive-Device-Token"
        static let DeviceTypeHeader = "X-BoardActive-Device-Type"
        static let IsTestApp = "X-BoardActive-Is-Test-App"
        static let UUIDHeader = "X-BoardActive-Device-UUID"
        static let ContentTypeHeader = "Content-Type"
        static let AcceptHeader = "Accept"
        static let CacheControlHeader = "Cache-Control"
        static let HostHeader = "Host"
        static let AcceptEncodingHeader = "accept-encoding"
        static let ConnectionHeader = "Connection"
    }

    enum HeaderValues {
        static let WildCards = "*/*"
        static let AppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        static let NoCache = "no-cache"
        static let ApplicationJSON = "application/json"
        static let GzipDeflate = "gzip, deflate"
        static let KeepAlive = "keep-alive"
//        static let DevHostKey = "springer-api.boardactive.com"
        static let DevHostKey = "boardactiveapi.dev.radixweb.net"
        static let ProdHostKey = "api.boardactive.com"
        static let iOS = "iOS"
        static let FCMToken = String.ConfigKeys.DeviceToken
        static let AppId = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppId)
        static let AppKey = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey)
        static let DeviceOSVersion = UIDevice.current.systemVersion
        static let DeviceType = UIDevice.modelName
        static let UUID = UIDevice.current.identifierForVendor!.uuidString
    }

    // MARK: - Network Call Related Keys

    enum NetworkCallRelated {
        static let DeviceToken = String.ConfigKeys.DeviceToken
        static let MessageId = "messageId"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let DeviceTime = "deviceTime"
    }

    // MARK: - Event logging related

    static let Received = "received"
    static let Opened = "opened"

    static let TappedAndTransitioning = "TAPPED & TRANSITIONING"
    static let ReceivedBackground = "RECEIVED BACKGROUND"

    // MARK: - Calculated

    static let SystemVersion = UIDevice.current.systemVersion
    static let AppVersion = UIApplication.appVersion
    static let DeviceType = UIDevice.modelName

    // MARK: - Notification Keys

    enum NotificationKeys {
        static let InfoUpdateNotification = "infoUpdateNotification"
        static let UserSelectedNotificationId = "com.apple.UNNotificationDefaultActionIdentifier"
        static let IncrementAppBadge = "IncrementAppBadge"
        static let DecrementAppBadge = "DecrementAppBadge"
    }

    // MARK: - Config Keys

    static let LoggedIn = "loggedIn"

    enum EventKeys {
        static let EventName = "name"
        static let MessageId = "baMessageId"
        static let NotificationId = "baNotificationId"
//        static let Inbox = "inbox"
        static let FirebaseNotificationId = "firebaseNotificationId"
    }

    enum Attribute {
        static let Attrs = "attributes"
        static let Stock = "stock"
        static let Custom = "custom"
        static let Name = "name" 
        static let Email = String.ConfigKeys.Email
        static let Phone = "phone"
        static let DateBorn = "dateBorn"
        static let Gender = "gender"
        static let Facebook = "facebookUrl"
        static let LinkedIn = "linkedInUrl"
        static let Twitter = "twitterUrl"
        static let Instagram = "instagramUrl"
        static let Avatar = "avatarUrl"
        static let DeviceOS = "deviceOS"
        static let DeviceOSVersion = "deviceOSVersion"
        static let DeviceType = "deviceType"
        static let DeviceToken = String.ConfigKeys.DeviceToken
        public static let DateLocationRequested = "dateLocationRequested"
        static let DateNotificationRequested = "dateNotificationRequested"
        static let LocationPermission = "locationPermission"
        static let NotificationPermission = "notificationPermission"
    }

    enum HTTPMethod {
        public static let GET = "GET"
        public static let POST = "POST"
        public static let PUT = "PUT"
    }
}
