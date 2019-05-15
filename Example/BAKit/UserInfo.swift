//
//  New.swift
//
//  Created by Ed Salter on 5/14/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UserInfo {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  public struct SerializationKeys {
    static let webUserId = "webUserId"
    static let email = "email"
    static let deviceOSVersion = "deviceOSVersion"
    static let deviceType = "deviceType"
    static let guid = "guid"
    static let appVersion = "appVersion"
    static let dateLastUpdated = "dateLastUpdated"
    static let deviceToken = "deviceToken"
    static let inbox = "inbox"
    static let deviceOS = "deviceOS"
    static let id = "id"
    static let appId = "appId"
    static let dateCreated = "dateCreated"
  }

  // MARK: Properties
  public var webUserId: Int?
  public var email: String?
  public var deviceOSVersion: String?
  public var deviceType: String?
  public var guid: String?
  public var appVersion: String?
  public var dateLastUpdated: String?
  public var deviceToken: String?
  public var inbox: Inbox?
  public var deviceOS: String?
  public var id: Int?
  public var appId: Int?
  public var dateCreated: String?

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
    webUserId = json[SerializationKeys.webUserId].int
    email = json[SerializationKeys.email].string
    deviceOSVersion = json[SerializationKeys.deviceOSVersion].string
    deviceType = json[SerializationKeys.deviceType].string
    guid = json[SerializationKeys.guid].string
    appVersion = json[SerializationKeys.appVersion].string
    dateLastUpdated = json[SerializationKeys.dateLastUpdated].string
    deviceToken = json[SerializationKeys.deviceToken].string
    inbox = Inbox(json: json[SerializationKeys.inbox])
    deviceOS = json[SerializationKeys.deviceOS].string
    id = json[SerializationKeys.id].int
    appId = json[SerializationKeys.appId].int
    dateCreated = json[SerializationKeys.dateCreated].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = webUserId { dictionary[SerializationKeys.webUserId] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = deviceOSVersion { dictionary[SerializationKeys.deviceOSVersion] = value }
    if let value = deviceType { dictionary[SerializationKeys.deviceType] = value }
    if let value = guid { dictionary[SerializationKeys.guid] = value }
    if let value = appVersion { dictionary[SerializationKeys.appVersion] = value }
    if let value = dateLastUpdated { dictionary[SerializationKeys.dateLastUpdated] = value }
    if let value = deviceToken { dictionary[SerializationKeys.deviceToken] = value }
    if let value = inbox { dictionary[SerializationKeys.inbox] = value.dictionaryRepresentation() }
    if let value = deviceOS { dictionary[SerializationKeys.deviceOS] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = appId { dictionary[SerializationKeys.appId] = value }
    if let value = dateCreated { dictionary[SerializationKeys.dateCreated] = value }
    return dictionary
  }

}
