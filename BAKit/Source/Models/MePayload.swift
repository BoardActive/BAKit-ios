//
//  MePayload.swift
//  Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct MePayload: Codable {
    let appId: String?
    let appVersion: String?
    let dateCreated: String?
    let dateLastUpdated: String?
    let deviceOS: String?
    let deviceOSVersion: String?
    let deviceToken: String?
    let email: String?
    let guid: String?
    let id: String?
    let inbox: Inbox?
    let webUserId: String?

    enum CodingKeys: String, CodingKey {
        case appId
        case appVersion
        case dateCreated
        case dateLastUpdated
        case deviceOS
        case deviceOSVersion
        case deviceToken
        case email
        case guid
        case id
        case inbox
        case webUserId
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appId = try values.decodeIfPresent(String.self, forKey: .appId)
        appVersion = try values.decodeIfPresent(String.self, forKey: .appVersion)
        dateCreated = try values.decodeIfPresent(String.self, forKey: .dateCreated)
        dateLastUpdated = try values.decodeIfPresent(String.self, forKey: .dateLastUpdated)
        deviceOS = try values.decodeIfPresent(String.self, forKey: .deviceOS)
        deviceOSVersion = try values.decodeIfPresent(String.self, forKey: .deviceOSVersion)
        deviceToken = try values.decodeIfPresent(String.self, forKey: .deviceToken)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        guid = try values.decodeIfPresent(String.self, forKey: .guid)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        inbox = try Inbox(from: decoder)
        webUserId = try values.decodeIfPresent(String.self, forKey: .webUserId)
    }
}
