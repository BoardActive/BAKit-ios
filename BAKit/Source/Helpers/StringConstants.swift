//
//  StringConstants.swift
//  BAKit
//
//  Created by Ed Salter on 3/20/19.
//

import Foundation

extension String {
    // MARK: Network Call Related Keys
    
    public static let DeviceToken = "deviceToken"
    public static let PreviousDeviceToken = "previousDeviceToken"
    public static let FCMToken = "FCMToken"
    public static let MessageId = "messageId"
    public static let MeData = "MeData"
    public static let iOS = "ios"
    public static let AllowOrigin = "*"
    
    // MARK: Calculated
    
    public static let SystemVersion = UIDevice.current.systemVersion
    public static let AppVersion = UIApplication.appVersion
    public static let DeviceType = UIDevice.modelName
    
    // MARK: Notification Keys
    
    public static let InfoUpdateNotification = "infoUpdateNotification"
    
}
