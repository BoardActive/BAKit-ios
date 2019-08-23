//
//  CoreDataStack.swift
//  BAKit
//
//  Created by Ed Salter on 8/7/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import CoreData

public class CoreDataStack: NSObject {
    public static let sharedInstance = CoreDataStack()
    private override init() {}

    lazy var managedObjects:[NSManagedObject]?  = {
        return fetchDataFromDatabase()
    }()

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
    
    public func createNotificationModel(fromDictionary dictionary: [String:Any]) -> NotificationModel {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let notificationModel = NSEntityDescription.insertNewObject(forEntityName: "NotificationModel", into: context) as! NotificationModel
        if let receivedDate = dictionary["date"] as? String {
            notificationModel.date = receivedDate
        } else {
            notificationModel.date = Date().iso8601
        }
        if let aps = dictionary["aps"] as? [String:Any] {
            notificationModel.aps = createAps(fromDictionary: aps)
        } else {
            do {
                let apsData = dictionary["aps"] as! String
                let aps = try JSONSerialization.jsonObject(with: apsData.data(using: .utf8)!, options: []) as! [String:Any]
                notificationModel.aps = createAps(fromDictionary: aps)
            } catch {
                fatalError()
            }
        }
        notificationModel.body = dictionary["body"] as? String
        notificationModel.dateCreated = dictionary["dateCreated"] as? String
        notificationModel.dateLastUpdated = dictionary["dateLastUpdated"] as? String
        notificationModel.gcmmessageId = dictionary["gcm.message_id"] as? String
        notificationModel.googlecae = dictionary["google.c.a.e"] as? String
        notificationModel.imageUrl = dictionary["imageUrl"] as? String
        notificationModel.isTestMessage = dictionary["isTestMessage"] as? String
        if let messageData = dictionary["messageData"] as? [String:Any] {
            notificationModel.messageData = createMessageData(fromDictionary: messageData)
        } else {
            do {
                let messageDataData = dictionary["messageData"] as! String
                let messageData = try JSONSerialization.jsonObject(with: messageDataData.data(using: .utf8)!, options: []) as! [String:Any]
                notificationModel.messageData = createMessageData(fromDictionary: messageData)
            } catch {
                fatalError()
            }
        }
        notificationModel.messageId = dictionary["messageId"] as? String
        notificationModel.notificationId = dictionary["notificationId"] as? String
        notificationModel.tap = dictionary["tap"] as? Bool ?? false
        notificationModel.title = dictionary["title"] as? String
        saveContext()
        NotificationCenter.default.post(Notification(name: Notification.Name("Refresh HomeViewController Tableview")))
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
        if let alert = dictionary["alert"] as? [String:Any] {
            aps.alert = createAlert(fromDictionary: alert)
        } else {
            do {
                let alertData = dictionary["alert"] as! String
                let alert = try JSONSerialization.jsonObject(with: alertData.data(using: .utf8)!, options: []) as! [String:Any]
                aps.alert = createAlert(fromDictionary: alert)
            } catch {
                fatalError()
            }
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
    
    public func createBAKitApp(fromApp app: App) -> BAKitApp {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let baKitApp = NSEntityDescription.insertNewObject(forEntityName: "BAKitApp", into: context) as! BAKitApp
        baKitApp.id = app.id
        baKitApp.name = app.name
        return baKitApp
    }
        
    public func fetchDataFromDatabase() -> [NSManagedObject]? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext

        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationModel")
        let sort = NSSortDescriptor(key: #keyPath(NotificationModel.date), ascending: false)
        request.sortDescriptors = [sort]
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let messageData = data.value(forKey: "messageData") as? NotificationModel {
                    print("FETCHED OBJECT DATE : MessageData :: \(messageData.debugDescription)")
                }
            }
            return result as? [NSManagedObject]
        } catch {
            print("Failed")
        }
        return nil
    }
    
    func deleteStoredData(entity: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // perform the delete
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
        
        let req: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "BAKitApp")
        let dreq = NSBatchDeleteRequest(fetchRequest: req)
        do {
            try persistentContainer.viewContext.execute(dreq)
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func fetchAppsFromDatabase() -> [NSManagedObject]? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BAKitApp")
        let sort = NSSortDescriptor(key: #keyPath(BAKitApp.name), ascending: false)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let app = data.value(forKey: "name") as? String {
                    print("App :: Name: \(app)")
                }
            }
            return result as? [NSManagedObject]
        } catch {
            print("Failed")
        }
        return nil
    }

}

