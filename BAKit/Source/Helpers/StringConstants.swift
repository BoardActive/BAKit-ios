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
    
    // MARK: Calculated
    public static let SystemVersion = UIDevice.current.systemVersion

    // MARK: Notification Keys

    public static let InfoUpdateNotification = "infoUpdateNotification"

    // MARK: Default Values

    public static let DefaultFCMToken = "cY0AwQggE4w:APA91bGbR8XaRTgor9fdJROoppVU-e7gezSxsCTqWea7ohavZXaA-c3df77AGWSoFSutFxJAzaX5GhISeQjrSN0LmfnRclBvTU6SRF6ejAsw83Yir0cBXtbnCTYRYNXdcQt82hlSNCdv0"
}
