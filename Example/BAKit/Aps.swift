//
//  Aps.swift
//  BAKit
//
//  Created by Ed Salter on 8/7/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class Aps: NSManagedObject {
    @NSManaged var badge: Int?
    @NSManaged var contentavailable: Int?
    @NSManaged var mutablecontent: Int?
    @NSManaged var category: String?
    @NSManaged var sound: String?
    @NSManaged var alert: Alert?
}
