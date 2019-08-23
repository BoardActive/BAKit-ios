//
//  NotificationService.swift
//  NotificationPersistenceService
//
//  Created by Ed Salter on 8/22/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UserNotifications
import CoreData

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let groupName = "group.com.boardactive.addrop"
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!.appendingPathComponent("BAKit.sqlite")
        let container = NSPersistentContainer(name: "BAKit")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

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
            
            let userInfo = request.content.userInfo as! [String:Any]
            let _ = createNotificationModel(fromDictionary: userInfo)
            saveContext()

            NotificationCenter.default.post(Notification(name: Notification.Name("Refresh HomeViewController Tableview")))

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
    
    public func createNotificationModel(fromDictionary dictionary: [String:Any]) -> NotificationModel {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let notificationModel = NSEntityDescription.insertNewObject(forEntityName: "NotificationModel", into: context) as! NotificationModel
        if let receivedDate = dictionary["date"] as? String {
            notificationModel.date = receivedDate
        } else {
            notificationModel.date = Date().iso8601
        }
        if let aps = dictionary["aps"] as? [String: Any] {
            notificationModel.aps = createAps(fromDictionary: (aps))
        }
        notificationModel.body = dictionary["body"] as? String
        notificationModel.dateCreated = dictionary["dateCreated"] as? String
        notificationModel.dateLastUpdated = dictionary["dateLastUpdated"] as? String
        notificationModel.gcmmessageId = dictionary["gcm.message_id"] as? String
        notificationModel.googlecae = dictionary["google.c.a.e"] as? String
        notificationModel.imageUrl = dictionary["imageUrl"] as? String
        notificationModel.isTestMessage = dictionary["isTestMessage"] as? String
        if let messageData = dictionary["messageData"] as? [String: Any] {
            notificationModel.messageData = createMessageData(fromDictionary: messageData)
        }
        notificationModel.messageId = dictionary["messageId"] as? String
        notificationModel.notificationId = dictionary["notificationId"] as? String
        notificationModel.tap = dictionary["tap"] as? Bool ?? false
        notificationModel.title = dictionary["title"] as? String
        return notificationModel
    }
    
    public func createAps(fromDictionary dictionary: [String: Any]) -> Aps {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let aps = NSEntityDescription.insertNewObject(forEntityName: "Aps", into: context) as! Aps
        aps.badge = dictionary["badge"] as! Int64
        aps.contentavailable = dictionary["content-available"] as! Int64
        aps.mutablecontent = dictionary["mutable-content"] as! Int64
        aps.category = dictionary["category"] as? String
        aps.sound = dictionary["sound"] as? String
        if let alert = dictionary["alert"] as? [String: Any] {
            aps.alert = createAlert(fromDictionary: (alert))
        }
        return aps
    }
    
    public func createMessageData(fromDictionary dictionary: [String: Any]) -> MessageData {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let messageData = NSEntityDescription.insertNewObject(forEntityName: "MessageData", into: context) as! MessageData
        messageData.email = dictionary["email"] as? String
        messageData.phoneNumber = dictionary["phoneNumber"] as? String
        messageData.promoDateEnds = dictionary["promoDateEnds"] as? String
        messageData.promoDateStarts = dictionary["promoDateStarts"] as? String
        messageData.storeAddress = dictionary["storeAddress"] as? String
        messageData.title = dictionary["title"] as? String
        messageData.urlFacebook = dictionary["urlFacebook"] as? String
        messageData.urlLandingPage = dictionary["urlLandingPage"] as? String
        messageData.urlLinkedIn = dictionary["urlLinkedIn"] as? String
        messageData.urlQRCode = dictionary["urlQRCode"] as? String
        messageData.urlTwitter = dictionary["urlTwitter"] as? String
        messageData.urlYoutube = dictionary["urlYoutube"] as? String
        return messageData
    }
    
    public func createAlert(fromDictionary dictionary: [String: Any]) -> Alert {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let alert = NSEntityDescription.insertNewObject(forEntityName: "Alert", into: context) as! Alert
        alert.title = dictionary["title"] as? String
        alert.body = dictionary["body"] as? String
        return alert
    }
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
