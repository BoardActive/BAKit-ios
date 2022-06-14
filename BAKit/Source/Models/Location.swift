//
//  Location.swift
//  BAKit-iOS
//
//  Created by Indrajeet Senger on 01/06/22.
//

import Foundation

public struct Location {
    
    var longitude: Double?
    var latitude: Double?
    var locationId: String?
    var lastNotificationDate: Date?
    var radius: Int?
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String: Any]) {
        longitude = (dictionary["longitude"] as? NSNumber)?.doubleValue ?? (dictionary["longitude"] as? NSString)?.doubleValue
        latitude = (dictionary["latitude"] as? NSNumber)?.doubleValue ?? (dictionary["latitude"] as? NSString)?.doubleValue
        locationId = "\((dictionary["locationId"] as? NSNumber) ?? 0)"
        lastNotificationDate = dictionary["lastNotificationDate"] as? Date
        radius = dictionary["radius"] as? Int
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    public func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if longitude != nil {
            dictionary["longitude"] = longitude
        }
        if latitude != nil {
            dictionary["latitude"] = latitude
        }
        if locationId != nil {
            dictionary["locationId"] = locationId as? Int
        }
        if lastNotificationDate != nil {
            dictionary["lastNotificationDate"] = lastNotificationDate
        }
        if radius != nil {
            dictionary["radius"] = radius
        }
        return dictionary
    }
}
