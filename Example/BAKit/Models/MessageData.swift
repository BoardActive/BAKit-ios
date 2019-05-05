//
//  MessageData.swift
//
//  Created by Ed Salter on 4/3/19
//  Copyright (c) BoardActive. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MessageData {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let urlYoutube = "urlYoutube"
    static let urlFacebook = "urlFacebook"
    static let email = "email"
    static let phoneNumber = "phoneNumber"
    static let promoDateStarts = "promoDateStarts"
    static let urlLinkedIn = "urlLinkedIn"
    static let urlTwitter = "urlTwitter"
    static let title = "title"
    static let urlLandingPage = "urlLandingPage"
    static let promoDateEnds = "promoDateEnds"
    static let storeAddress = "storeAddress"
    static let urlQRCode = "urlQRCode"
  }

  // MARK: Properties
  public var urlYoutube: String?
  public var urlFacebook: String?
  public var email: String?
  public var phoneNumber: String?
  public var promoDateStarts: String?
  public var urlLinkedIn: String?
  public var urlTwitter: String?
  public var title: String?
  public var urlLandingPage: String?
  public var promoDateEnds: String?
  public var storeAddress: String?
  public var urlQRCode: String?

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
    urlYoutube = json[SerializationKeys.urlYoutube].string
    urlFacebook = json[SerializationKeys.urlFacebook].string
    email = json[SerializationKeys.email].string
    phoneNumber = json[SerializationKeys.phoneNumber].string
    promoDateStarts = json[SerializationKeys.promoDateStarts].string
    urlLinkedIn = json[SerializationKeys.urlLinkedIn].string
    urlTwitter = json[SerializationKeys.urlTwitter].string
    title = json[SerializationKeys.title].string
    urlLandingPage = json[SerializationKeys.urlLandingPage].string
    promoDateEnds = json[SerializationKeys.promoDateEnds].string
    storeAddress = json[SerializationKeys.storeAddress].string
    urlQRCode = json[SerializationKeys.urlQRCode].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = urlYoutube { dictionary[SerializationKeys.urlYoutube] = value }
    if let value = urlFacebook { dictionary[SerializationKeys.urlFacebook] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = phoneNumber { dictionary[SerializationKeys.phoneNumber] = value }
    if let value = promoDateStarts { dictionary[SerializationKeys.promoDateStarts] = value }
    if let value = urlLinkedIn { dictionary[SerializationKeys.urlLinkedIn] = value }
    if let value = urlTwitter { dictionary[SerializationKeys.urlTwitter] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    if let value = urlLandingPage { dictionary[SerializationKeys.urlLandingPage] = value }
    if let value = promoDateEnds { dictionary[SerializationKeys.promoDateEnds] = value }
    if let value = storeAddress { dictionary[SerializationKeys.storeAddress] = value }
    if let value = urlQRCode { dictionary[SerializationKeys.urlQRCode] = value }
    return dictionary
  }

}
