//
//  AppPickingViewController.swift
//  BAKit
//
//  Created by Ed Salter on 7/31/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import BAKit

class AppPickingViewController: UITableViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.frame = CGRect(x: (self.view.frame.width/2) - 40, y: (self.view.frame.height/2) - 40, width: 80, height: 80)
        indicatorView.backgroundColor = UIColor.lightGray
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.layer.cornerRadius = 10
        view.addSubview(indicatorView)

      
        configureNavigationBar()
        
        guard let apps = CoreDataStack.sharedInstance.fetchAppsFromDatabase() else {
            let alertController = UIAlertController(title: "No Apps Found", message: "No apps are associated with the current user.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true) {
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        
        StorageObject.container.apps = apps
        
        self.tableView.tableFooterView = UIView()
//        (UIApplication.shared.delegate! as! AppDelegate).setupSDK()
        BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
        NotificationCenter.default.addObserver(self, selector:  #selector(displayNotification), name: Notification.Name("display"), object: nil)
//        if let loc = UserDefaults.standard.value(forKey: "locs") as? [String]{
//            let alertController = UIAlertController(title: "Location", message: "\(loc)", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true) {
//            }
//        }
       
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        if (appDelegate.isNotificationStatusActive) {
            appDelegate.isNotificationStatusActive = false
            guard let notificationModel = StorageObject.container.notification else {
                    return }
            if let _ = notificationModel.aps, let messageId = notificationModel.messageId, let firebaseNotificationId = notificationModel.gcmmessageId, let notificationId = notificationModel.notificationId {
                indicatorView.startAnimating()
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId) {
                    BoardActive.client.postEvent(name: String.Opened, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId) {
//                        BoardActive.client.sendNotification(msg: "both event is updated")
                        DispatchQueue.main.async {
                            self.indicatorView.stopAnimating()
                            let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
                            guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
                                return
                            }
                            self.present(viewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func configureNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 21)!]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorageObject.container.apps.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.font = UIFont(name:"Montserrat-Regular", size:17)
        if let text = StorageObject.container.apps[indexPath.row].value(forKey:"name") as? String {
            cell.textLabel?.text = text
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedApp = StorageObject.container.apps[indexPath.row] as? BAKitApp
        if let appId = selectedApp?.id, let appKey = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey) {
            BoardActive.client.setupEnvironment(appID: "\(appId)", appKey: appKey)
        }
                
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController")
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    @objc func displayNotification() {
            appDelegate.isNotificationStatusActive = false
            guard let notificationModel = StorageObject.container.notification else {
                    return }
            if let _ = notificationModel.aps, let messageId = notificationModel.messageId, let firebaseNotificationId = notificationModel.gcmmessageId, let notificationId = notificationModel.notificationId {
                indicatorView.startAnimating()
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId) {
                    BoardActive.client.postEvent(name: String.Opened, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId) {
//                        BoardActive.client.sendNotification(msg: "both event is updated")
                        DispatchQueue.main.async {
                            self.indicatorView.stopAnimating()
                            let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
                            guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationCollectionViewController") as? NotificationCollectionViewController else {
                                return
                            }
                            self.present(viewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
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

}
