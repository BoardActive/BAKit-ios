//
//  User.swift
//  BAKit
//
//  Created by Ed Salter on 4/30/19.
//

import Foundation

struct TopLevel: Codable {
    let ageDOB, dateCreated, deviceOS, deviceOSVersion: String
    let deviceToken, deviceType, email, facebookURL: String
    let gender, initialLocationPermission, initialNotificationPermission, instagramURL: String
    let lastOpenedApp, linkedInURL, locationPersmission, notificationPermission: String
    let phoneNumber, twitterURL: String
    
    enum CodingKeys: String, CodingKey {
        case ageDOB = "age (d.o.b.)"
        case dateCreated, deviceOS, deviceOSVersion, deviceToken, deviceType, email
        case facebookURL = "facebookUrl"
        case gender, initialLocationPermission, initialNotificationPermission
        case instagramURL = "instagramUrl"
        case lastOpenedApp
        case linkedInURL = "linkedInUrl"
        case locationPersmission, notificationPermission
        case phoneNumber = "phone number"
        case twitterURL = "twitterUrl"
    }
}

// MARK: Convenience initializers

extension TopLevel {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(TopLevel.self, from: data) else { return nil }
        self = me
    }
    
    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }
    
    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }
    
    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
