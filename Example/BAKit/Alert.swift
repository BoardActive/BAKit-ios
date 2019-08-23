//
//  Alert.swift
//  BAKit
//
//  Created by Ed Salter on 8/7/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import CoreData

class Alert: NSManagedObject {
    @NSManaged var body: String?
    @NSManaged var title: String?
}
