//
//  HomeViewController.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import BAKit
import CoreData
import CoreLocation
import MaterialComponents
import UIKit
import UserNotifications

protocol HomeViewControllerDelegate {
    func toggleMenu()
    func collapseMenu()
}

class HomeViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    private let refreshControl = UIRefreshControl()
    var timer: Timer?
    var delegate: HomeViewControllerDelegate?

    open var models: [NSManagedObject]?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView(notification:)), name: Notification.Name("Refresh HomeViewController Tableview"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createLocalNotification), name: Notification.Name("New Local"), object: nil)

        configureNavigation()
        configureTableView()
        setupLocalNotification()
        (UIApplication.shared.delegate! as! AppDelegate).setupSDK()

        let myTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(createLocalNotification), userInfo: nil, repeats: true)
        RunLoop.current.add(myTimer, forMode: .commonModes)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        models = CoreDataStack.sharedInstance.fetchDataFromDatabase()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        BoardActive.client.stopUpdatingLocation()
    }

    private func configureNavigation() {
        navigationItem.setHidesBackButton(false, animated: false)

        guard let application = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        application.notificationDelegate = self
        navigationController?.navigationBar.tintColor = UIColor.white
    }

    @IBAction func didTapMenuButton(_ sender: Any) {
        delegate?.toggleMenu()
    }

    @IBAction func didTapTrashButton(_ sender: Any) {
        CoreDataStack.sharedInstance.deleteStoredData(entity: "NotificationModel")
        models = nil
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func back(sender: UIBarButtonItem) {
    }

    let basicDictionary = [
        "aps": [
            "badge": 1,
            "content-available": 1,
            "mutable-content": 1,
            "category": "Basic",
            "sound": "default",
            "alert": [
                "title": "alert",
                "body": "body",
                ] as [String: Any],
            ] as [String: Any],
        "date": Date().iso8601,
        "title": "Welcome",
        "body": "Congratulations on successfully downloading BoardActive’s app!",
        "messageId": "0000001",
        "notificationId": "0000001",
        "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
        "isTestMessage": "0",
        "dateCreated": Date().iso8601,
        "dateLastUpdated": Date().iso8601,
        "gcm.message_id": "0000001",
        "google.c.a.e": "0000001",
        "tap": "0",
        "messageData": [
            "body": "Congratulations on successfully downloading BoardActive’s app!",
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
            "urlYoutube": "https://www.youtube.com/embed/5Fi6surCFpQ"] as [String: Any],
        ] as [String: Any]
    
    let bigPictureDictionary = [
        "aps": [
            "badge": 1,
            "content-available": 1,
            "mutable-content": 1,
            "category": "Big Picture",
            "sound": "default",
            "alert": [
                "title": "alert",
                "body": "body",
                ] as [String: Any],
            ] as [String: Any],
        "date": Date().iso8601,
        "title": "Welcome",
        "body": "Congratulations on successfully downloading BoardActive’s app!",
        "messageId": "0000001",
        "notificationId": "0000001",
        "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
        "isTestMessage": "0",
        "dateCreated": Date().iso8601,
        "dateLastUpdated": Date().iso8601,
        "gcm.message_id": "0000001",
        "google.c.a.e": "0000001",
        "tap": "0",
        "messageData": [
            "body": "Congratulations on successfully downloading BoardActive’s app!",
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
            "urlYoutube": "https://www.youtube.com/embed/5Fi6surCFpQ"] as [String: Any],
        ] as [String: Any]
    
    let actionButtonDictionary = [
        "aps": [
            "badge": 1,
            "content-available": 1,
            "mutable-content": 1,
            "category": "Action Button",
            "sound": "default",
            "alert": [
                "title": "alert",
                "body": "body",
                ] as [String: Any],
            ] as [String: Any],
        "date": Date().iso8601,
        "title": "Welcome",
        "body": "Congratulations on successfully downloading BoardActive’s app!",
        "messageId": "0000001",
        "notificationId": "0000001",
        "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
        "isTestMessage": "0",
        "dateCreated": Date().iso8601,
        "dateLastUpdated": Date().iso8601,
        "gcm.message_id": "0000001",
        "google.c.a.e": "0000001",
        "tap": "0",
        "messageData": [
            "body": "Congratulations on successfully downloading BoardActive’s app!",
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
            "urlYoutube": "https://www.youtube.com/embed/5Fi6surCFpQ"] as [String: Any],
        ] as [String: Any]
    
    let bigTextDictionary = [
        "aps": [
            "badge": 1,
            "content-available": 1,
            "mutable-content": 1,
            "category": "Big Text",
            "sound": "default",
            "alert": [
                "title": "alert",
                "body": "body",
                ] as [String: Any],
            ] as [String: Any],
        "date": Date().iso8601,
        "title": "Welcome",
        "body": "Congratulations on successfully downloading BoardActive’s app!",
        "messageId": "0000001",
        "notificationId": "0000001",
        "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
        "isTestMessage": "0",
        "dateCreated": Date().iso8601,
        "dateLastUpdated": Date().iso8601,
        "gcm.message_id": "0000001",
        "google.c.a.e": "0000001",
        "tap": "0",
        "messageData": [
            "body": "Congratulations on successfully downloading BoardActive’s app!",
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
            "urlYoutube": "https://www.youtube.com/embed/5Fi6surCFpQ"] as [String: Any],
        ] as [String: Any]
    
    let inboxStyleDictionary = [
        "aps": [
            "badge": 1,
            "content-available": 1,
            "mutable-content": 1,
            "category": "Inbox Style",
            "sound": "default",
            "alert": [
                "title": "alert",
                "body": "body",
                ] as [String: Any],
            ] as [String: Any],
        "date": Date().iso8601,
        "title": "Welcome",
        "body": "Congratulations on successfully downloading BoardActive’s app!",
        "messageId": "0000001",
        "notificationId": "0000001",
        "imageUrl": "https://ba-us-east-1-develop.s3.amazonaws.com/test-5d3ba9d0-cb1d-49ee-99f3-7bef45994e71",
        "isTestMessage": "0",
        "dateCreated": Date().iso8601,
        "dateLastUpdated": Date().iso8601,
        "gcm.message_id": "0000001",
        "google.c.a.e": "0000001",
        "tap": "0",
        "messageData": [
            "body": "Congratulations on successfully downloading BoardActive’s app!",
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
            "urlYoutube": "https://www.youtube.com/embed/5Fi6surCFpQ"] as [String: Any],
        ] as [String: Any]

    @objc private func setupLocalNotification() {
        if !((BoardActive.client.userDefaults?.bool(forKey: "NOT_FIRSTLOGIN"))!) {
            BoardActive.client.userDefaults?.set(true, forKey: "NOT_FIRSTLOGIN")
            BoardActive.client.userDefaults?.synchronize()

            let content = UNMutableNotificationContent()
            content.title = basicDictionary["title"] as! String
            content.body = basicDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = basicDictionary
            content.categoryIdentifier = "Basic"
            
            let identifier = "UYLLocalNotification"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            print("[HomeViewController] setupLocationNotification() :: \(request.content.userInfo.debugDescription)")
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { error in
                if let error = error {
                    print("\n[HomeViewController] setupLocalNotification :: Error: \(error.localizedDescription) \n")
                }
            })
        }
    }

    @objc
    func createLocalNotification() {
        guard let category = UserDefaults.extensions.value(forKeyPath: "category") as? String else {
            return
        }

        let content = UNMutableNotificationContent()
        if category == "Basic" {
            content.title = basicDictionary["title"] as! String
            content.body = basicDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = basicDictionary
            content.categoryIdentifier = "Basic"
        } else if category == "Big Picture" {
            content.title = bigPictureDictionary["title"] as! String
            content.body = bigPictureDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = bigPictureDictionary
            content.categoryIdentifier = "Big Picture"
        } else if category == "Action Button" {
            content.title = actionButtonDictionary["title"] as! String
            content.body = actionButtonDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = actionButtonDictionary
            content.categoryIdentifier = "Action Button"
        } else if category == "Big Text" {
            content.title = actionButtonDictionary["title"] as! String
            content.body = actionButtonDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = actionButtonDictionary
            content.categoryIdentifier = "Big Text"
        } else if category == "Inbox Style" {
            content.title = inboxStyleDictionary["title"] as! String
            content.body = inboxStyleDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = inboxStyleDictionary
            content.categoryIdentifier = "Inbox Style"
        } else {
            content.title = basicDictionary["title"] as! String
            content.body = basicDictionary["body"] as! String
            content.sound = UNNotificationSound.default()
            content.userInfo = basicDictionary
            content.categoryIdentifier = "Basic"
        }
        
        let identifier = "UYLLocalNotification"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        print("[HomeViewController] setupLocationNotification() :: \(request.content.userInfo.debugDescription)")
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { error in
            if let error = error {
                print("\n[HomeViewController] setupLocalNotification :: Error: \(error.localizedDescription) \n")
            }
        })

    }
    
    @IBAction func didTapSignOutButton(_ sender: Any) {
        CoreDataStack.sharedInstance.deleteStoredData(entity: "NotificationModel")
        CoreDataStack.sharedInstance.deleteStoredData(entity: "BAKitApp")

        UIApplication.shared.applicationIconBadgeNumber = 0

        DispatchQueue.main.async {
            BoardActive.client.stopUpdatingLocation()
        }

        BoardActive.client.userDefaults?.removeObject(forKey: "NOT_FIRSTLOGIN")
        BoardActive.client.userDefaults?.removeObject(forKey: "AppIdSelected")
        BoardActive.client.userDefaults?.removeObject(forKey: "AppSelected")
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.DeviceRegistered)
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.Email)
        BoardActive.client.userDefaults?.removeObject(forKey: String.ConfigKeys.Password)
        BoardActive.client.userDefaults?.removeObject(forKey: .LoggedIn)
        BoardActive.client.userDefaults?.synchronize()
        
        self.parent?.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func didTapShuffleButton(_ sender: Any) {
        // Stop updating location
        self.parent?.navigationController?.popViewController(animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        cell.detailTextLabel?.font = UIFont(name: "Montserrat-Regular", size: 14)

        if let modelObject = models?[indexPath.row] as? NotificationModel {
            cell.textLabel?.text = modelObject.title!
            cell.detailTextLabel?.text = modelObject.date!
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        models?[indexPath.row].setValue(true, forKeyPath: "tap")
        StorageObject.container.notification = models?[indexPath.row] as? NotificationModel
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
            return
        }

        viewController.loadViewIfNeeded()
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    @objc
    func refreshTableView(notification: NSNotification) {
        models = CoreDataStack.sharedInstance.fetchDataFromDatabase()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension HomeViewController: NotificationDelegate {
    func appReceivedRemoteNotification(notification: [AnyHashable: Any]) {
        models = CoreDataStack.sharedInstance.fetchDataFromDatabase()

        let notification = NSNotification(name: NSNotification.Name("Refresh Table"), object: nil)
        refreshTableView(notification: notification)

        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)

        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
            return
        }

        viewController.loadViewIfNeeded()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeViewController: SidePanelViewControllerDelegate {
    func didSelectCellWithTitle(_ title: String) {
        delegate?.toggleMenu()

        if title == "View Token" {
            guard let fcmToken = BoardActive.client.userDefaults?.object(forKey: String.HeaderValues.FCMToken) as? String else {
                return
            }
            let tokenAlert = UIAlertController(title: "Token", message: fcmToken, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            tokenAlert.addAction(okAction)
            present(tokenAlert, animated: true, completion: nil)
        }
        
        if title == "Device" {
            let deviceAlert = UIAlertController(title: "Register Device Response", message: "Under Development", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            deviceAlert.addAction(okAction)
            present(deviceAlert, animated: true, completion: nil)
        }
        
        if title == "App Variables" {
            guard let deviceId = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppId), let deviceKey = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey) else {
                return
            }
            
            let appVariablesAlert = UIAlertController(title: "App Variables", message: "AppId: \(deviceId) \nAppKey: \(deviceKey)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            appVariablesAlert.addAction(okAction)
            present(appVariablesAlert, animated: true, completion: nil)
        }
    }
    
    
}

// MARK: - Cell editing functions

/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
