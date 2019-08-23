//
//  NotificationModel.swift
//  BAKit
//
//  Created by Ed Salter on 8/7/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class NotificationModel: NSManagedObject {
    @NSManaged var body: String?
    @NSManaged var dateCreated: String?
    @NSManaged var dateLastUpdated: String?
    @NSManaged var gcmmessageId: String?
    @NSManaged var googlecae: String?
    @NSManaged var imageUrl: String?
    @NSManaged var isTestMessage: String?
    @NSManaged var messageId: String?
    @NSManaged var notificationId: String?
    @NSManaged var title: String?
    @NSManaged var tap: Bool?
    @NSManaged var aps: Aps?
    @NSManaged var messageData: MessageData?
}
