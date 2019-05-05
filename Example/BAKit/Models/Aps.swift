//
//  Aps.swift
//
//  Created by Ed Salter on 4/3/19
//  Copyright (c) BoardActive. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Aps {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let mutableContent = "mutable-content"
    static let alert = "alert"
    static let contentAvailable = "content-available"
    static let badge = "badge"
  }

  // MARK: Properties
  public var mutableContent: Int?
  public var alert: Alert?
  public var contentAvailable: Int?
  public var badge: Int?

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
    mutableContent = json[SerializationKeys.mutableContent].int
    alert = Alert(json: json[SerializationKeys.alert])
    contentAvailable = json[SerializationKeys.contentAvailable].int
    badge = json[SerializationKeys.badge].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = mutableContent { dictionary[SerializationKeys.mutableContent] = value }
    if let value = alert { dictionary[SerializationKeys.alert] = value.dictionaryRepresentation() }
    if let value = contentAvailable { dictionary[SerializationKeys.contentAvailable] = value }
    if let value = badge { dictionary[SerializationKeys.badge] = value }
    return dictionary
  }

}
