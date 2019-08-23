//
//  StorageObject.swift
//  BAKit_Example
//
//  Created by Ed Salter on 8/1/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import CoreData

public class StorageObject: NSObject {
    public static let container = StorageObject()
    
    public var apps: [NSManagedObject] = [NSManagedObject]()
    public var user: User?
    public var payload: LoginPayload?
    public var userInfo: UserInfo?
    public var notification: NotificationModel?
    
    private override init() {}
}
