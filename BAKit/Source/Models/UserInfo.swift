// To parse the JSON, add this file to your project and do:
//
//   let userInfo = try UserInfo(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseUserInfo { response in
//     if let userInfo = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

public struct UserInfo: Codable {
    let appID: Int?
    let attributes: Attributes?
    let dateCreated, dateLastUpdated, guid: String?
    let id: Int?
    let inbox: Inbox?
    
    enum CodingKeys: String, CodingKey {
        case appID = "appId"
        case attributes, dateCreated, dateLastUpdated, guid, id, inbox
    }
}

public struct Attributes: Codable {
    let custom: Inbox?
    let stock: Stock?
}

public struct Inbox: Codable {
}

public struct Stock: Codable {
    let appVersion, dateBorn: String?
    let deciveType, deviceOS, deviceOSVersion: JSONNull?
    let deviceToken, email: String?
    let facebookURL: JSONNull?
    let gender: String?
    let initialLocationPermission, initialNotificationPermission: Bool?
    let instagramURL, linkedInURL: JSONNull?
    let locationPermission: Bool?
    let name: String?
    let notificationPermission: Bool?
    let phone: String?
    let twitterURL, webUserID: JSONNull?
    
    enum CodingKeys: String, CodingKey {
        case appVersion, dateBorn, deciveType, deviceOS, deviceOSVersion, deviceToken, email
        case facebookURL = "facebookUrl"
        case gender, initialLocationPermission, initialNotificationPermission
        case instagramURL = "instagramUrl"
        case linkedInURL = "linkedInUrl"
        case locationPermission, name, notificationPermission, phone
        case twitterURL = "twitterUrl"
        case webUserID = "webUserId"
    }
}

// MARK: Convenience initializers and mutators

public extension UserInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserInfo.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        appID: Int?? = nil,
        attributes: Attributes?? = nil,
        dateCreated: String?? = nil,
        dateLastUpdated: String?? = nil,
        guid: String?? = nil,
        id: Int?? = nil,
        inbox: Inbox?? = nil
        ) -> UserInfo {
        return UserInfo(
            appID: appID ?? self.appID,
            attributes: attributes ?? self.attributes,
            dateCreated: dateCreated ?? self.dateCreated,
            dateLastUpdated: dateLastUpdated ?? self.dateLastUpdated,
            guid: guid ?? self.guid,
            id: id ?? self.id,
            inbox: inbox ?? self.inbox
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Attributes {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Attributes.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        custom: Inbox?? = nil,
        stock: Stock?? = nil
        ) -> Attributes {
        return Attributes(
            custom: custom ?? self.custom,
            stock: stock ?? self.stock
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Inbox {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Inbox.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        ) -> Inbox {
        return Inbox(
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Stock {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Stock.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        appVersion: String?? = nil,
        dateBorn: String?? = nil,
        deciveType: JSONNull?? = nil,
        deviceOS: JSONNull?? = nil,
        deviceOSVersion: JSONNull?? = nil,
        deviceToken: String?? = nil,
        email: String?? = nil,
        facebookURL: JSONNull?? = nil,
        gender: String?? = nil,
        initialLocationPermission: Bool?? = nil,
        initialNotificationPermission: Bool?? = nil,
        instagramURL: JSONNull?? = nil,
        linkedInURL: JSONNull?? = nil,
        locationPermission: Bool?? = nil,
        name: String?? = nil,
        notificationPermission: Bool?? = nil,
        phone: String?? = nil,
        twitterURL: JSONNull?? = nil,
        webUserID: JSONNull?? = nil
        ) -> Stock {
        return Stock(
            appVersion: appVersion ?? self.appVersion,
            dateBorn: dateBorn ?? self.dateBorn,
            deciveType: deciveType ?? self.deciveType,
            deviceOS: deviceOS ?? self.deviceOS,
            deviceOSVersion: deviceOSVersion ?? self.deviceOSVersion,
            deviceToken: deviceToken ?? self.deviceToken,
            email: email ?? self.email,
            facebookURL: facebookURL ?? self.facebookURL,
            gender: gender ?? self.gender,
            initialLocationPermission: initialLocationPermission ?? self.initialLocationPermission,
            initialNotificationPermission: initialNotificationPermission ?? self.initialNotificationPermission,
            instagramURL: instagramURL ?? self.instagramURL,
            linkedInURL: linkedInURL ?? self.linkedInURL,
            locationPermission: locationPermission ?? self.locationPermission,
            name: name ?? self.name,
            notificationPermission: notificationPermission ?? self.notificationPermission,
            phone: phone ?? self.phone,
            twitterURL: twitterURL ?? self.twitterURL,
            webUserID: webUserID ?? self.webUserID
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: Encode/decode helpers

public class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

fileprivate func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

fileprivate func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseUserInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<UserInfo>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
