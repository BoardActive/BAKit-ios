//
//  Attributes.swift
//  AdDrop
//
//  Created by Ed Salter on 5/23/19.
//

import Foundation

public struct Attributes {
    var custom: Custom!
    var stock: Stock!

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String: Any]) {
        if let customData = dictionary[String.Attribute.Custom] as? [String: Any] {
            custom = Custom(fromDictionary: customData)
        }
        if let stockData = dictionary[String.Attribute.Stock] as? [String: Any] {
            stock = Stock(fromDictionary: stockData)
        }
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    public func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if custom != nil {
            dictionary[String.Attribute.Custom] = custom.toDictionary()
        }
        if stock != nil {
            dictionary[String.Attribute.Stock] = stock.toDictionary()
        }
        return dictionary
    }
}

public struct Stock {
    var dateBorn: Date?
    var dateLocationPermissionRequested: Date? = UserDefaults(suiteName: "BAKit")?.object(forKey: "dateLocationPermissionRequested") as? Date
    var dateNotificationPermissionRequested: Date? = UserDefaults(suiteName: "BAKit")?.object(forKey: "dateNotificationPermissionRequested") as? Date
    var email: String?
    var facebookUrl: String?
    var gender: String?
    var instagramUrl: String?
    var linkedInUrl: String?
    var locationPermission: Bool? = UserDefaults(suiteName: "BAKit")?.bool(forKey: "locationPermission") ?? false
    var name: String?
    var notificationPermission: Bool! = true
    var phone: String?
    var twitterUrl: String?

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String: Any]) {
        dateBorn = dictionary["dateBorn"] as? Date
        email = dictionary["email"] as? String
        facebookUrl = dictionary["facebookUrl"] as? String
        gender = dictionary["gender"] as? String
        instagramUrl = dictionary["instagramUrl"] as? String
        linkedInUrl = dictionary["linkedInUrl"] as? String
        name = dictionary["name"] as? String
        phone = dictionary["phone"] as? String
        twitterUrl = dictionary["twitterUrl"] as? String
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    public func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if dateBorn != nil {
            dictionary["dateBorn"] = dateBorn
        }
        if dateLocationPermissionRequested != nil {
            dictionary["dateLocationPermissionRequested"] = dateLocationPermissionRequested
        }
        if dateNotificationPermissionRequested != nil {
            dictionary["dateNotificationPermissionRequested"] = dateNotificationPermissionRequested
        }
        if email != nil {
            dictionary["email"] = email
        }
        if facebookUrl != nil {
            dictionary["facebookUrl"] = facebookUrl
        }
        if gender != nil {
            dictionary["gender"] = gender
        }
        if instagramUrl != nil {
            dictionary["instagramUrl"] = instagramUrl
        }
        if linkedInUrl != nil {
            dictionary["linkedInUrl"] = linkedInUrl
        }
        if locationPermission != nil {
            dictionary["locationPermission"] = locationPermission
        }
        if name != nil {
            dictionary["name"] = name
        }
        if notificationPermission != nil {
            dictionary["notificationPermission"] = notificationPermission
        }
        if phone != nil {
            dictionary["phone"] = phone
        }
        if twitterUrl != nil {
            dictionary["twitterUrl"] = twitterUrl
        }
        return dictionary
    }
}

public struct Custom {
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String: Any]) {
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    public func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        return dictionary
    }
}
