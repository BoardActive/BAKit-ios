//
//  NotificationViewController.swift
//  Inbox Style
//
//  Created by Ed Salter on 9/3/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var firstBullet: UILabel?
    @IBOutlet var secondBullet: UILabel?
    @IBOutlet var thirdBullet: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstBullet?.text = "\u{2022} This is the first list item!"
        secondBullet?.text = "\u{2022} This is the second list item!"
        thirdBullet?.text = "\u{2022} This is the third list item!"
    }
    
    func didReceive(_ notification: UNNotification) {
//        self.label?.text = notification.request.content.body
    }

}
