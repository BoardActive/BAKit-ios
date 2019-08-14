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
        let tempUserInfo = notification.request.content.userInfo as! [String: Any]
        let notificationModel = CoreDataStack.sharedInstance.createNotificationModel(fromDictionary: tempUserInfo)
        let messageData = CoreDataStack.sharedInstance.createMessageData(fromDictionary: tempUserInfo["messageData"] as! [String : Any])
        notificationModel.messageData = messageData
        titleLabel.text = messageData.title
        bodyLabel.text = notificationModel.body
        mainNotificationImageView.loadImageUsingCache(withUrl: notificationModel.imageUrl!)
    }

}
