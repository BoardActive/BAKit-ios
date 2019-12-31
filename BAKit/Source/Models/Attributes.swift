//
//  Attributes.swift
//  BAKit
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
    // permisions
    var dateLocationRequested: Date? = UserDefaults(suiteName: "BAKit")?.object(forKey: "dateLocationRequested") as? Date
    var dateNotificationRequested: Date? = UserDefaults(suiteName: "BAKit")?.object(forKey: "dateNotificationRequested") as? Date
  
    var locationPermission: Bool? = UserDefaults(suiteName: "BAKit")?.bool(forKey: "locationPermission") ?? false
    var notificationPermission: Bool! = UIApplication.shared.isRegisteredForRemoteNotifications
  
    var dateBorn: Date?
    var name: String?
    var email: String?
    var gender: String?
    var phone: String?
    var facebookUrl: String?
    var instagramUrl: String?
    var linkedInUrl: String?
    var twitterUrl: String?

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String: Any]) {
        dateBorn = dictionary["dateBorn"] as? Date
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        gender = dictionary["gender"] as? String
        phone = dictionary["phone"] as? String
        facebookUrl = dictionary["facebookUrl"] as? String
        instagramUrl = dictionary["instagramUrl"] as? String
        linkedInUrl = dictionary["linkedInUrl"] as? String
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
        if dateLocationRequested != nil {
            dictionary["dateLocationRequested"] = dateLocationRequested
        }
        if dateNotificationRequested != nil {
            dictionary["dateNotificationRequested"] = dateNotificationRequested
        }
        if locationPermission != nil {
            dictionary["locationPermission"] = locationPermission
        }
        if notificationPermission != nil {
            dictionary["notificationPermission"] = notificationPermission
        }
        if name != nil {
            dictionary["name"] = name
        }
        if email != nil {
            dictionary["email"] = email
        }
        if gender != nil {
            dictionary["gender"] = gender
        }
        if phone != nil {
            dictionary["phone"] = phone
        }
        if facebookUrl != nil {
            dictionary["facebookUrl"] = facebookUrl
        }
        if instagramUrl != nil {
            dictionary["instagramUrl"] = instagramUrl
        }
        if linkedInUrl != nil {
            dictionary["linkedInUrl"] = linkedInUrl
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
