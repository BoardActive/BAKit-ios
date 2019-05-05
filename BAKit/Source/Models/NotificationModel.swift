//
//  NotificationModel.swift
//
//  Created by Ed Salter on 4/3/19
//  Copyright (c) BoardActive. All rights reserved.
//

import Foundation
import SwiftyJSON

//Codable
public struct NotificationModel  {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    enum CodingKeys: String, CodingKey {
        case messageId = "messageId"
        case body = "body"
        case messageData = "messageData"
        case notificationId = "notificationId"
        case aps = "aps"
        case isTestMessage = "isTestMessage"
        case dateLastUpdated = "dateLastUpdated"
        case tap = "tap"
        case googlecae = "google.c.a.e"
        case dateCreated = "dateCreated"
        case title = "title"
        case imageUrl = "imageUrl"
        case gcmMessageId = "gcm.message_id"
    }
    
    // MARK: Properties
    public var messageId: String?
    public var body: String?
    public var messageData: Any? // DO NOT DRILL DOWN
    public var notificationId: String?
    public var aps: Any? // DO NOT DRILL DOWN
    public var isTestMessage: String?
    public var dateLastUpdated: String?
    public var tap: Bool? = false
    public var googlecae: String?
    public var dateCreated: String?
    public var title: String?
    public var imageUrl: String?
    public var gcmMessageId: String?
    
    // MARK: SwiftyJSON Initializers
    /// Initiates the instance based on the object.
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public init(json: JSON) {
        messageId = json[CodingKeys.messageId.rawValue].string
        body = json[CodingKeys.body.rawValue].string
        body = body?.replacingOccurrences(of: "\\", with: "")
        messageData = json[CodingKeys.messageData.rawValue]
        notificationId = json[CodingKeys.notificationId.rawValue].string
        aps = json[CodingKeys.aps.rawValue]
        isTestMessage = json[CodingKeys.isTestMessage.rawValue].string
        dateLastUpdated = json[CodingKeys.dateLastUpdated.rawValue].string
        tap = json[CodingKeys.tap.rawValue].boolValue
        googlecae = json[CodingKeys.googlecae.rawValue].string
        dateCreated = json[CodingKeys.dateCreated.rawValue].string
        title = json[CodingKeys.title.rawValue].string
        title = title?.replacingOccurrences(of: "\\", with: "")
        imageUrl = json[CodingKeys.imageUrl.rawValue].string
        imageUrl = imageUrl?.replacingOccurrences(of: "\\", with: "")
        gcmMessageId = json[CodingKeys.gcmMessageId.rawValue].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = messageId { dictionary[CodingKeys.messageId.rawValue] = value }
        if let value = body { dictionary[CodingKeys.body.rawValue] = value }
        if let value = messageData { dictionary[CodingKeys.messageData.rawValue] = value }
        if let value = notificationId { dictionary[CodingKeys.notificationId.rawValue] = value }
        if let value = aps { dictionary[CodingKeys.aps.rawValue] = value }
        if let value = isTestMessage { dictionary[CodingKeys.isTestMessage.rawValue] = value }
        if let value = dateLastUpdated { dictionary[CodingKeys.dateLastUpdated.rawValue] = value }
        dictionary[CodingKeys.tap.rawValue] = tap
        if let value = googlecae { dictionary[CodingKeys.googlecae.rawValue] = value }
        if let value = dateCreated { dictionary[CodingKeys.dateCreated.rawValue] = value }
        if let value = title { dictionary[CodingKeys.title.rawValue] = value }
        if let value = imageUrl { dictionary[CodingKeys.imageUrl.rawValue] = value }
        if let value = gcmMessageId { dictionary[CodingKeys.gcmMessageId.rawValue] = value }
        return dictionary
    }
    
    public func isValidNotification() -> Bool {
        return (gcmMessageId != nil && !gcmMessageId!.isEmpty && notificationId != nil && !notificationId!.isEmpty && notificationId != nil && !notificationId!.isEmpty)
    }
    
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        messageId = try values.decodeIfPresent(String.self, forKey: .messageId)
//        body = try values.decodeIfPresent(String.self, forKey: .body)
//        messageData = try values.decodeIfPresent(Any.self, forKey: .messageData)
//        notificationId = try values.decodeIfPresent(String.self, forKey: .notificationId)
//        aps = try values.decodeIfPresent(AnyClass.self, forKey: .aps)
//        isTestMessage = try values.decodeIfPresent(String.self, forKey: .isTestMessage)
//        dateLastUpdated = try values.decodeIfPresent(String.self, forKey: .dateLastUpdated)
//        dateCreated = try values.decodeIfPresent(String.self, forKey: .dateCreated)
//        googlecae = try values.decodeIfPresent(String.self, forKey: .googlecae)
//        title = try values.decodeIfPresent(String.self, forKey: .title)
//        imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
//        gcmMessageId = try values.decodeIfPresent(String.self, forKey: .gcmMessageId)
//    }
}

