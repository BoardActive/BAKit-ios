//
//  MessageData.swift
//  BAKit
//
//  Created by Ed Salter on 8/7/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class MessageData: NSManagedObject {
    @NSManaged var email: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var promoDateEnds: String?
    @NSManaged var promoDateStarts: String?
    @NSManaged var storeAddress: String?
    @NSManaged var title: String?
    @NSManaged var urlFacebook: String?
    @NSManaged var urlLandingPage: String?
    @NSManaged var urlLinkedIn: String?
    @NSManaged var urlQRCode: String?
    @NSManaged var urlTwitter: String?
    @NSManaged var urlYoutube: String?
}
