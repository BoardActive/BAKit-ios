//
//  NotificationViewController.swift
//  Content Extension
//
//  Created by Ed Salter on 8/5/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mainNotificationImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo as! [String:Any]
        if let urlString = userInfo["imageUrl"] as? String {
//            DispatchQueue.main.async {
                self.mainNotificationImageView.loadImageUsingCache(withUrl: urlString)
//            }
        }
    }
}
