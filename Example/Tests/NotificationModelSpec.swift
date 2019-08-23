//
//  NotificationModelSpec.swift
//  BAKit_Tests
//
//  Created by Ed Salter on 4/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import BAKit
class NotificationModelSpec: QuickSpec {
    override func spec() {
        describe("struct model that parses push notifications") {
            
        }
    }
    let testNotification = Notification(name: Notification.Name(rawValue: "Foo"), object: nil)
    
    // passes if the closure in expect { ... } posts a notification to the default
    // notification center.
    expect {
    NotificationCenter.default.postNotification(testNotification)
    }.to(postNotifications(equal([testNotification]))
    
    // passes if the closure in expect { ... } posts a notification to a given
    // notification center
    let notificationCenter = NotificationCenter()
    expect {
    notificationCenter.postNotification(testNotification)
    }.to(postNotifications(equal([testNotification]), fromNotificationCenter: notificationCenter))
}
