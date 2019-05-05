//
//  AdDrop.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/24/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import Foundation
import UIKit

class Message {
    // Meta members
    var id: String = ""
    var messageId: String = ""
    var notificationId: String? = ""
    var dateCreated: String? = "" // TODO: set to String?
    var dateUpdated: String? = "" // "

    // Date members
    var dateStart: String? // TODO: set to String?
    var dateExpires: String? // "
    var timeStart: String?
    var timeEnd: String?
    // TODO: combine into single prop?

    // GET /promotions/:id members
    var isBookmarked: Bool = false

    // URLs
    var imageUrl: String? = "" // TODO: set to String?
    var promoUrl: String? = "" // "
    var qrUrl: String? = "" // TODO: String?

    var globalLocations: [Location] = []

    // view only
    var categoryColor: UIColor = .white

    init(_ json: [String: Any]) {
        id = json["promotion_id"] as! String
        messageId = json["advertisement_id"] as! String
        notificationId = json["gcm.message_id"] as? String

        // Example date: "2018-09-01T00:00:00.000Z"
        dateCreated = json["created_at"] as? String
        dateUpdated = json["updated_at"] as? String
        dateStart = json["start_at"] as? String
        dateExpires = json["expire_at"] as? String
        timeStart = json["time_start"] as? String
        timeEnd = json["time_end"] as? String

        // URLs
        if let promoUrlString = json["promotion_link_url"] as? String {
            promoUrl = promoUrlString // URL(string: promoUrlString)
        }
        if let imageUrlString = json["image_url"] as? String {
            imageUrl = imageUrlString // URL(string: imageUrlString)
        }

        // GET /promotions/:id members
        if json["isBookmarked"] != nil {
            isBookmarked = json["isBookmarked"] as! Bool
        } else {
            isBookmarked = false
        }

        if let qrUrlString = json["qrUrl"] as? String {
            qrUrl = qrUrlString // URL(string: qrUrlString)
        }

        if json["locations"] != nil {
            initLocations(locations: json["locations"] as! [[String: Any]])
        }
    }

    func initLocations(locations: [[String: Any]]) {
        var newLocations = [Location]()

        for location in locations {
            newLocations.append(Location(location))
        }

        globalLocations = newLocations
    }

    func isValidModel() -> Bool {
        return (imageUrl != nil)
        // TODO: add more
    }

    func isValidNotification() -> Bool {
        return !id.isEmpty &&
            notificationId != nil &&
            !messageId.isEmpty
    }

    func toggleAdDropBookmark() {
        isBookmarked = !isBookmarked
    }
}
