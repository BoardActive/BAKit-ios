//
//  NotificationViewController.swift
//  Content Modification
//
//  Created by Ed Salter on 5/3/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import MessageUI

class NotificationVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.register(TitleLabelTableViewCell.self, forCellReuseIdentifier: "titleBodyCell")

        let closeBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), landscapeImagePhone: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(closeNotification))
//        self.navigationController!.navigationItem.rightBarButtonItem = closeBarButtonItem
        self.navigationItem.rightBarButtonItem = closeBarButtonItem

//        callButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//        emailButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//        directionsButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//        homepageButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
        
//        didReceive(notificationModel: StorageObject.container.notification!)
    }
    
//    func didReceive(notificationModel: NotificationModel) {
//        self.titleLabel.text = notificationModel.title
//        self.body.text = notificationModel.body
//        StorageObject.container.notification = notificationModel
//        StorageObject.container.notification = notificationModel
    
//        DispatchQueue.main.async {
//            self.notificationMainImageView.loadImageUsingCache(withUrl: notificationModel.imageUrl)
//            self.qrImageView.loadImageUsingCache(withUrl: notificationModel.messageData.urlQRCode)
//        }

//    }
    
    @IBAction func makeCall(_ sender: Any) {
        let number = StorageObject.container.notification?.messageData?.phoneNumber?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let completeNumber = URL(string: "tel://" + number!) else {
            return
        }
        UIApplication.shared.open(completeNumber)
    }
    
   

    @IBAction func getDirections(_ sender: Any) {
        guard let address = StorageObject.container.notification?.messageData?.storeAddress else {
            return
            
        }
        UIApplication.shared.open(URL(string:"http://maps.apple.com/?address=\(address)")!)
    }
    
//    @IBAction func openHomepage(_ sender: Any) {
//        guard let url = URL(string: (StorageObject.container.notification?.messageData?.urlLandingPage)!) else {
//            return
//        }
//        UIApplication.shared.open(url)
//    }
    
    @IBAction func openFacebook(_ sender: Any) {
        guard let url = URL(string: (StorageObject.container.notification?.messageData?.urlFacebook)!) else {
            return
        }
        UIApplication.shared.open(url)

    }
    
    @IBAction func openLinkedIn(_ sender: Any) {
        guard let url = URL(string: (StorageObject.container.notification?.messageData?.urlLinkedIn)!) else {
            return
        }
        UIApplication.shared.open(url)

    }
    
    @IBAction func openTwitter(_ sender: Any) {
        guard let url = URL(string: (StorageObject.container.notification?.messageData?.urlTwitter)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func openYoutube(_ sender: Any) {
        guard let url = URL(string: (StorageObject.container.notification?.messageData?.urlYoutube)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc
    func closeNotification() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        if indexPath.row == 0 {
//            self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "mainImageViewCell")
//            cell = self.tableView.dequeueReusableCell(withIdentifier: "mainImageViewCell", for: indexPath) as! CustomTableViewCell
            
//            DispatchQueue.main.async {
//                cell!.notificationMainImageView.loadImageUsingCache(withUrl: ((StorageObject.container.notification?.imageUrl) ?? ""))
//            }
//            return cell!
//        }
        
//        if indexPath.row == 2 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "titleBodyCell", for: indexPath) as! TitleLabelTableViewCell
//            if let title = StorageObject.container.notification?.messageData?.title {
//                cell.titleLabel.text = title
//            } else {
//                cell.titleLabel.height = 0
//            }
//            if let body = StorageObject.container.notification?.body {
//                cell.body.text = body
//            } else {
//                cell.body.height = 0
//            }
//            return cell
//        }
//
//        if indexPath.row == 4 {
////            self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "startsEndsCell")
//            cell = self.tableView.dequeueReusableCell(withIdentifier: "startsEndsCell", for: indexPath) as! CustomTableViewCell
//            cell?.startDate.text = StorageObject.container.notification?.messageData?.promoDateStarts
//            cell?.endDate.text = StorageObject.container.notification?.messageData?.promoDateEnds
////            return cell!
//        }
//
//        if indexPath.row == 6 {
////            self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "contactUsCell")
//            cell = self.tableView.dequeueReusableCell(withIdentifier: "contactUsCell", for: indexPath) as! CustomTableViewCell
//            if (StorageObject.container.notification?.messageData?.urlLandingPage?.isEmpty)! {
//                cell?.homepageButton.width = 0
//            } else {
//                cell?.homepageButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//            }
//            if (StorageObject.container.notification?.messageData?.phoneNumber?.isEmpty)! {
//                cell?.callButton.width = 0
//            } else {
//                cell?.callButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//            }
//            if (StorageObject.container.notification?.messageData?.storeAddress?.isEmpty)! {
//                cell?.directionsButton.width = 0
//            } else {
//                cell?.directionsButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//            }
//            if (StorageObject.container.notification?.messageData?.email?.isEmpty)! {
//                cell?.emailButton.width = 0
//            } else {
//                cell?.emailButton.imageView?.tintColor = #colorLiteral(red: 0.1716355085, green: 0.7660725117, blue: 0.9729360938, alpha: 1)
//            }
////            return cell!
//        }
//
//        if indexPath.row == 8 {
////            self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "findUsOnlineCell")
//            cell = self.tableView.dequeueReusableCell(withIdentifier: "findUsOnlineCell", for: indexPath) as! CustomTableViewCell
//            if (StorageObject.container.notification?.messageData?.urlFacebook?.isEmpty)! {
//                cell?.facebookButton.width = 0
//            }
//            if (StorageObject.container.notification?.messageData?.urlTwitter?.isEmpty)! {
//                cell?.twitterButton.width = 0
//            }
//            if (StorageObject.container.notification?.messageData?.urlLinkedIn?.isEmpty)! {
//                cell?.linkedInButton.width = 0
//            }
//            if (StorageObject.container.notification?.messageData?.urlYoutube?.isEmpty)! {
//                cell?.youtubeButton.width = 0
//            }
////            return cell!
//        }
//
//        if indexPath.row == 10 {
////            self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "claimYourReward")
//            cell = self.tableView.dequeueReusableCell(withIdentifier: "findUsOnlineCell", for: indexPath) as! CustomTableViewCell
//            if (StorageObject.container.notification!.messageData?.urlQRCode?.isEmpty)! {
//                cell?.height = 0
//            } else {
//                DispatchQueue.main.async {
//                    cell?.qrImageView.loadImageUsingCache(withUrl: StorageObject.container.notification!.messageData!.urlQRCode!)
//                }
//            }
////            return cell!
//        }
        return CustomTableViewCell()
//        return cell!
    }
}
