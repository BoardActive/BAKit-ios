//
//  BoardActiveCredentials.swift
//  BAKit
//
//  Created by Ed Salter on 4/24/19.
//

import Foundation
import SwiftyJSON

public struct BoardActiveCredentials: Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    enum CodingKeys: String, CodingKey {
        case email = "Email"
        case baseAPIString = "BaseAPIString"
        case appId = "AppId"
        case appKey = "AppKey"
        case uuid = "UUID"
    }
    
    // MARK: Properties
    public var email: String?
    public var baseAPIString: String?
    public var appId: String?
    public var appKey: String?
    public var uuid: String?
    
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
        email = json[CodingKeys.email.rawValue].string
        baseAPIString = json[CodingKeys.baseAPIString.rawValue].string
        appId = json[CodingKeys.appId.rawValue].string
        appKey = json[CodingKeys.appKey.rawValue].string
        uuid = json[CodingKeys.uuid.rawValue].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = email { dictionary[CodingKeys.email.rawValue] = value }
        if let value = baseAPIString { dictionary[CodingKeys.baseAPIString.rawValue] = value }
        if let value = appId { dictionary[CodingKeys.appId.rawValue] = value }
        if let value = appKey { dictionary[CodingKeys.appKey.rawValue] = value }
        if let value = uuid { dictionary[CodingKeys.uuid.rawValue] = value }
        return dictionary
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        baseAPIString = try values.decodeIfPresent(String.self, forKey: .baseAPIString)
        appId = try values.decodeIfPresent(String.self, forKey: .appId)
        appKey = try values.decodeIfPresent(String.self, forKey: .appKey)
        uuid = try values.decodeIfPresent(String.self, forKey: .uuid)
    }
    
}
