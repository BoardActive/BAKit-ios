//
//  StringConstants.swift
//  BAKit
//
//  Created by Ed Salter on 3/20/19.
//

import Foundation

extension String {
    public enum HeaderKeys: String {
        case AccessControl   = "Access-Control-Allow-Origin"
        case AppId           = "X-BoardActive-App-Id"
        case AppKey          = "X-BoardActive-App-Key"
        case AppVersion      = "X-BoardActive-App-Version"
        case DeviceOS        = "X-BoardActive-Device-OS"
        case DeviceOSVersion = "X-BoardActive-Device-OS-Version"
        case DeviceToken     = "X-BoardActive-Device-Token"
        case DeviceType      = "X-BoardActive-Device-Type"
        case UUID            = "X-BoardActive-UUID"
    }
    
    // MARK: Network Call Related Keys
    public static let Token       = "token"
    public static let DeviceToken = "deviceToken"
    public static let FCMToken    = "FCMToken"
    public static let MessageId   = "messageId"
    public static let MeData      = "MeData"
    public static let iOS         = "ios"
    public static let AllowOrigin = "*"
    public static let Location    = "location"
    public static let IsTestApp   = "0"
    public static let Latitude    = "latitude"
    public static let Longitude   = "longitude"
    public static let DeviceTime  = "deviceTime"
    
    // MARK: Event logging related
    public static let Received               = "received"
    public static let Opened                 = "opened"
    public static let TappedAndTransitioning = "TAPPED & TRANSITIONING"
    public static let ReceivedBackground     = "RECEIVED BACKGROUND"
    // MARK: Calculated

    public static let SystemVersion = UIDevice.current.systemVersion
    public static let AppVersion = UIApplication.appVersion
    public static let DeviceType = UIDevice.modelName
    
    // MARK: Onboarding
    
    public static let Step1HeadlineText = "Welcome to BoardActive"
    public static let Step1BodyText     = "This app allows you to try out the BoardActive platform."
    public static let Step2HeadlineText = "Allow Notifications"
    public static let Step2BodyText     = "Enabling notifications allows your custom messages to be delivered to your phone."
    public static let Step3HeadlineText = "Allow Location"
    public static let Step3BodyText     = "Enabling Locations activates custom BoardActive Geofences."
    public static let Step4HeadlineText = "Get ready to enter your App ID and Email"
    public static let Step4BodyText     = "The BoardActive platform provides your App ID and Email at the positions indicated above."
    public static let Step5HeadlineText = "App ID and Email"
    public static let Step5BodyText     = "Enter the App ID provided when you created your account as well as the associated Email."
    
    // MARK: Notification Keys

    public static let InfoUpdateNotification     = "infoUpdateNotification"
    public static let UserSelectedNotificationId = "com.apple.UNNotificationDefaultActionIdentifier"
    public static let kIncrementAppBadge: String = "IncrementAppBadge"
    public static let kDecrementAppBadge: String = "DecrementAppBadge"

    // MARK: CONFIG KEYS
    public static let BAKitFirebaseAppConfigName     = "BAKit_Config"
    public static let ClientAppFirebaseAppConfigName = "Client_Config"
    public static let BAKit_FirebaseBundle           = "BAKit_FirebaseBundle"

    public enum ConfigKeys: String {
        case AppId  = "AppId"
        case AppKey = "AppKey"
        case UUID   = "UUID"
    }
    
    public enum EventKeys: String {
        case name
        case messageId
        case inbox
        case firebaseNotificationId
    }
    
    public enum StockAttributes: String {
        case email
        case deviceOS
        case deviceOSVersion
    }
}
