//
//  HomeViewController.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import BAKit
import UserNotifications
import MaterialComponents
import CoreData
import CoreLocation

class HomeViewController: UIViewController, NotificationDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    private let refreshControl = UIRefreshControl()
    private var models: [NSManagedObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        BoardActive.client.editUser(attributes: Attributes(fromDictionary: ["demoAppUser": true]), httpMethod: String.HTTPMethod.PUT)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView(notification:)), name: Notification.Name("Refresh HomeViewController Tableview"), object: nil)
        
        configureNavigation()
        configureTableView()
        setupLocalNotification()
        
        (UIApplication.shared.delegate! as! AppDelegate).setupSDK()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        models = CoreDataStack.sharedInstance.fetchDataFromDatabase()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func appReceivedRemoteNotification(notification: [AnyHashable: Any]) {
        models = CoreDataStack.sharedInstance.fetchDataFromDatabase()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
            return
        }
        
        viewController.loadViewIfNeeded()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func configureNavigation() {
        self.navigationItem.setHidesBackButton(false, animated: false)
        let trashImage = #imageLiteral(resourceName: "Trash")
        let trashButton = UIBarButtonItem(image: trashImage,  style: .plain, target: self, action: #selector(didTapTrashButton(sender:)))

        let shuffleBackImage = #imageLiteral(resourceName: "shuffle")
        self.navigationController?.navigationBar.backIndicatorImage = shuffleBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = shuffleBackImage
        let logoutImage = #imageLiteral(resourceName: "logout")
        let logOutBarButtonItem = UIBarButtonItem(image: logoutImage, landscapeImagePhone: logoutImage, style: .plain, target: self, action: #selector(signOutAction(_:)))
        navigationItem.setRightBarButtonItems([logOutBarButtonItem, trashButton], animated: true)

        
        (UIApplication.shared.delegate as! AppDelegate).notificationDelegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @objc
    func didTapTrashButton(sender: AnyObject) {
        CoreDataStack.sharedInstance.deleteStoredData(entity: "NotificationModel")
        models = nil
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    private func setupLocalNotification() {
        if !((BoardActive.client.userDefaults?.bool(forKey: "NOT_FIRSTLOGIN"))!) {
            BoardActive.client.userDefaults?.set(true, forKey: "NOT_FIRSTLOGIN")
            BoardActive.client.userDefaults?.synchronize()

            let dictionary = [
                "aps":[
                    "badge": 1,
                    "content-available": 1,
                    "mutable-content": 1,
                    "category": "PreviewNotification",
                    "sound": "default",
                    "alert":[
                        "title": "alert",
                        "body": "body"
                    ] as [String:Any]
                ] as [String:Any],
                "date": Date().iso8601,
                "title": "Welcome",
                "body":"Congratulations on successfully downloading BoardActive’s app!",
                "messageId": "0000001",
                "notificationId": "0000001",
                "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
                "isTestMessage":"0",
                "dateCreated":Date().iso8601,
                "dateLastUpdated": Date().iso8601,
                "gcmmessageId":"0000001",
                "googlecae":"0000001",
                "tap": "0",
                "messageData":[
                    "body":"Congratulations on successfully downloading BoardActive’s app!",
                    "email": "taylor@boardactive.com",
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

            let content = UNMutableNotificationContent()
            content.title = dictionary["title"] as! String
            content.body = dictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = dictionary

            let identifier = "UYLLocalNotification"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            print("[HomeViewController] setupLocationNotification() :: \(request.content.userInfo.debugDescription)")
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("\n[HomeViewController] setupLocalNotification :: Error: \(error.localizedDescription) \n")
                }
            })
        }
    }
    
    @objc
    func refreshTableView(notification: NSNotification) {
        models = CoreDataStack.sharedInstance.fetchDataFromDatabase()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc
    func signOutAction(_ sender: Any) {
        
        CoreDataStack.sharedInstance.deleteStoredData(entity: "NotificationModel")
        CoreDataStack.sharedInstance.deleteStoredData(entity: "BAKitApp")
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        DispatchQueue.main.async {
            BoardActive.client.stopUpdatingLocation()
        }
        
        BoardActive.client.userDefaults?.removeObject(forKey: "NOT_FIRSTLOGIN")
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.DeviceRegistered)
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.Email)
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.Password)
        BoardActive.client.userDefaults?.removeObject(forKey: .LoggedIn)
        BoardActive.client.userDefaults?.synchronize()

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = models?.count {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.font = UIFont(name:"Montserrat-SemiBold", size:17)
        cell.detailTextLabel?.font = UIFont(name:"Montserrat-Regular", size:14)
        
        if let modelObject = models?[indexPath.row] as? NotificationModel {
            cell.textLabel?.text = modelObject.title!
            cell.detailTextLabel?.text = modelObject.date!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        models?[indexPath.row].setValue(true, forKeyPath: "tap")
        StorageObject.container.notification = models?[indexPath.row] as? NotificationModel
        
        guard let notificationModel = StorageObject.container.notification else {
            return
        }
        
        if let _ = notificationModel.aps, let messageId = notificationModel.messageId, let firebaseNotificationId = notificationModel.gcmmessageId {
            BoardActive.client.postEvent(name: String.Opened, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
        }
        
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
            return
        }
        
        viewController.loadViewIfNeeded()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
