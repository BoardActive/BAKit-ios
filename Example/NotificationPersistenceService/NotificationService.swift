//
//  NotificationService.swift
//  NotificationPersistenceService
//
//  Created by Ed Salter on 8/22/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UserNotifications
import os.log

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let incr = bestAttemptContent.badge as? Int {
                switch incr {
                case 0:
                    UserDefaults.extensions.badge = 0
                    bestAttemptContent.badge = 0
                default:
                    let current = UserDefaults.extensions.badge
                    let new = current + incr
                    
                    UserDefaults.extensions.badge = new
                    bestAttemptContent.badge = NSNumber(value: new)
                }
            }
            
            if let categoryChosen = UserDefaults.extensions.string(forKey: "categoryIdentifier") {
                bestAttemptContent.categoryIdentifier = categoryChosen
                bestAttemptContent.setValue(categoryChosen, forKey: "categoryIdentifier")
            }
            
            UserDefaults.extensions.synchronize()
            
            os_log("[NotificaitonService] :: didReceive :: bestAttempt: %s", bestAttemptContent.debugDescription)
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
