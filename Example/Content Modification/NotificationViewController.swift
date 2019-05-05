//
//  NotificationViewController.swift
//  Content Modification
//
//  Created by Ed Salter on 5/3/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var body: UILabel!
    private var notificationImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 300, height: 350)
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        
        self.titleLabel.text = (content.userInfo["title"] as! String)
        self.body.text = (content.userInfo["body"] as! String)
        
//        guard let urlImageString = content.userInfo["urlImageString"] as? String else {
//            return
//        }
//
//        self.imageView.download(from: URL(fileURLWithPath: urlImageString))
        
        var images: [UIImage] = []
        
        notification.request.content.attachments.forEach { attachment in
            if attachment.url.startAccessingSecurityScopedResource() {
                if let data = try? Data(contentsOf: attachment.url),
                    let image = UIImage(data: data) {
                    images.append(image)
                }
                
                attachment.url.stopAccessingSecurityScopedResource()
            }
        }
        
        imageView.image = images.first
//        let userInfo = UserDefaults.extensions.value(forKey: "userInfo") as! [String:Any]
//        DispatchQueue.main.async {
//            self.label?.text = userInfo["title"] as? String
//
//            self.imageView.loadImageUsingCache(withUrl: userInfo["imageUrl"] as! String)
//        }
//            (UserDefaults.extensions.imageCache.object(forKey: (userInfo["imageUrl"] as! NSString)) as! UIImage)

    }
}
