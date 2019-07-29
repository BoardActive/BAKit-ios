//
//  HomeViewController.swift
//  BAKit_Example
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import BAKit

class HomeViewController: UIViewController, BoardActiveDelegate {

    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BoardActive.client.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (!BoardActive.client.userDefaults!.bool(forKey:String.DeviceRegistered)) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func appReceivedRemoteNotification(notification: [AnyHashable: Any]) {
        let tempUserInfo = notification as! [String: Any]
        let notificationModel = NotificationModel(fromDictionary: tempUserInfo)
        
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationViewController else {
            return
        }
        
        viewController.notificationModel = notificationModel
        
        viewController.loadViewIfNeeded()
        
        self.present(viewController, animated: true, completion: nil)
    }

    @IBAction func signOutAction(_ sender: Any) {
        BoardActive.client.signOut()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
