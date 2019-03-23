//
//  Inbox.swift
//  Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Inbox: Codable {
    var inbox: [String]
    enum CodingKeys: String, CodingKey {
        case inbox
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        inbox = try values.decodeIfPresent([String].self, forKey: .inbox)!
    }
}
