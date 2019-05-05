//
//  Alert.swift
//
//  Created by Ed Salter on 4/3/19
//  Copyright (c) BoardActive. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Alert {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let body = "body"
    static let title = "title"
  }

  // MARK: Properties
  public var body: String?
  public var title: String?

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
    body = json[SerializationKeys.body].string
    body = body?.replacingOccurrences(of: "\\", with: "")
    
    title = json[SerializationKeys.title].string
    title = title?.replacingOccurrences(of: "\\", with: "")
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = body { dictionary[SerializationKeys.body] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    return dictionary
  }

}
