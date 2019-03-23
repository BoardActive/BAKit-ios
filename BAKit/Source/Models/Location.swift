//
//  Location.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/24/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import Foundation

class Location {
    // Meta members
    var id: Int
    var dateCreated: String? // TODO: should be String?
    var dateUpdated: String? // "

    var latitude: String // TODO: should be float?
    var longitude: String // "

    init(_ json: [String: Any]) {
        // Meta members
        id = json["id"] as! Int

        dateCreated = json["created_at"] as? String
        dateUpdated = json["updated_at"] as? String

        // Coordinates of address
        latitude = json["latitude"] as! String
        longitude = json["longitude"] as! String
    }
}
