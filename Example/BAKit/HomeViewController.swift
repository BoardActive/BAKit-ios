//
//  HomeViewController.swift
//  BAKit_Example
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import BAKit
import UserNotifications
import MaterialComponents
import CoreData

class HomeViewController: UIViewController, NotificationDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupLocalNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func appReceivedRemoteNotification(notification: [AnyHashable: Any]) {
        let tempUserInfo = notification as! [String: Any]
        var notificationModel: NotificationModel
        if let _ = tempUserInfo["aps"] {
            notificationModel = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: tempUserInfo)
        } else {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            notificationModel = NSEntityDescription.insertNewObject(forEntityName: "NotificationModel", into: context) as! NotificationModel
            notificationModel.body = tempUserInfo["body"] as! String
            notificationModel.messageData = CoreDataStack.sharedInstance.createMessageData(fromDictionary: tempUserInfo)
        }
        StorageObject.container.notification = notificationModel
        
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
            return
        }
        
        viewController.loadViewIfNeeded()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func setupNavigation() {
        self.navigationItem.setHidesBackButton(false, animated: false)
        
        let shuffleBackImage = #imageLiteral(resourceName: "shuffle")
        self.navigationController?.navigationBar.backIndicatorImage = shuffleBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = shuffleBackImage
        
        let logOutBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "logout"), landscapeImagePhone: #imageLiteral(resourceName: "logout"), style: .plain, target: self, action: #selector(signOutAction(_:)))
        self.navigationController!.navigationItem.rightBarButtonItem = logOutBarButtonItem
        self.navigationItem.rightBarButtonItem = logOutBarButtonItem
        
        (UIApplication.shared.delegate as! AppDelegate).notificationDelegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func setupLocalNotification() {
        if !((BoardActive.client.userDefaults?.bool(forKey: "NOT_FIRSTLOGIN"))!) {
            BoardActive.client.userDefaults?.set(true, forKey: "NOT_FIRSTLOGIN")
            BoardActive.client.userDefaults?.synchronize()
            
            let dictionary = [
                "aps":[
                    "badge": 1,
                    "contentavailable": 1,
                    "mutablecontent": 1,
                    "category": "PreviewNotification",
                    "sound": "default",
                    "alert":[
                        "title": "alert",
                        "body": "body"
                    ] as [String:Any]
                ] as [String:Any],
                "title": "Welcome",
                "body":"Congratulations on successfully downloading BoardActive’s app!",
                "messageId": "0000001",
                "notificationId": "0000001",
                "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
                "isTestMessage":"0",
                "dateCreated":Date().description,
                "dateLastUpdated": Date().description,
                "gcmmessageId":"0000001",
                "googlecae":"0000001",
                "tap": "1",
                "messageData":[
                    "body":"Congratulations on successfully downloading BoardActive’s app!",
                    "email": "info@boardactive.com",
                    "phoneNumber": "(678) 383-2200",
                    "promoDateEnds": "10/1/19",
                    "promoDateStarts": "5/1/19",
                    "storeAddress": "800 Battery Ave, SE Two Ballpark Center Suite 3132 Atlanta, GA 30339",
                    "title": "An awesome promotion",
                    "urlFacebook": "https://www.facebook.com/BoardActive/",
                    "urlLandingPage": "https://boardactive.com/",
                    "urlLinkedIn": "https://www.linkedin.com/company/boardactive/",
                    "urlQRCode": "https://bit.ly/2FhOjiO",
                    "urlTwitter": "https://twitter.com/boardactive",
                    "urlYoutube": "https://www.youtube.com/embed/5Fi6surCFpQ"] as [String:Any]
                ] as [String : Any]
            
//            let notificationModel = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: dictionary)
//            CoreDataStack.sharedInstance.persistentContainer.viewContext.insert(notificationModel)
            
            let content = UNMutableNotificationContent()
            content.title = dictionary["title"] as! String
            content.body = dictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = dictionary["messageData"] as! [AnyHashable : Any]
            
            let identifier = "UYLLocalNotification"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("[BA:HomeViewController] Local Notification :: \(error.localizedDescription) ")
                }
            })
        }
    }
    
    @objc
    func refreshTableView() {
        self.tableView.reloadData()
    }
    
    @objc
    func signOutAction(_ sender: Any) {
        UIApplication.shared.applicationIconBadgeNumber = 0

        DispatchQueue.main.async {
            BoardActive.client.stopUpdatingLocation()
        }
        
        BoardActive.client.userDefaults?.removeObject(forKey: "NOT_FIRSTLOGIN")
        BoardActive.client.userDefaults?.removeObject(forKey: String.DeviceRegistered)
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.Email)
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.Password)
        BoardActive.client.userDefaults?.removeObject(forKey: .LoggedIn)
        BoardActive.client.userDefaults?.synchronize()

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = CoreDataStack.sharedInstance.managedObjects?.count {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeViewControllerID", for: indexPath)
        guard CoreDataStack.sharedInstance.managedObjects?.count != nil else {
            return cell
        }
        let notificationModelsArray = CoreDataStack.sharedInstance.managedObjects as! [NotificationModel]
        cell.textLabel?.text = notificationModelsArray[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationModelsArray = CoreDataStack.sharedInstance.managedObjects as! [NotificationModel]
        StorageObject.container.notification = notificationModelsArray[indexPath.row]
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC else {
            return
        }
        
        viewController.loadViewIfNeeded()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
