//
//  NotificationViewController.swift
//  Content Modification
//
//  Created by Ed Salter on 5/3/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import MessageUI

class NotificationViewController: UIViewController {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var homepageButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var notificationMainImageView: UIImageView!
    
    var notificationModel: NotificationModel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        callButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        emailButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        directionsButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        homepageButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        facebookButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        linkedInButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        twitterButton.imageView?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
        
        didReceive(notificationModel: self.notificationModel)
    }
    
    func didReceive(notificationModel: NotificationModel) {
        self.titleLabel.text = notificationModel.title
        self.body.text = notificationModel.body
        self.notificationModel = notificationModel
        
        DispatchQueue.main.async {
            self.notificationMainImageView.loadImageUsingCache(withUrl: notificationModel.imageUrl)
            self.qrImageView.loadImageUsingCache(withUrl: notificationModel.messageData.urlQRCode)
        }

    }
    
    @IBAction func makeCall(_ sender: Any) {
        let number = self.notificationModel.messageData.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let completeNumber = URL(string: "tel://" + number) else {
            return
        }
        UIApplication.shared.open(completeNumber)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([self.notificationModel.messageData.email])
            mail.setMessageBody("", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    @IBAction func getDirections(_ sender: Any) {
        guard let address = self.notificationModel.messageData.storeAddress else {
            return
            
        }
        UIApplication.shared.open(URL(string:"http://maps.apple.com/?address=\(address)")!)
    }
    
    @IBAction func openHomepage(_ sender: Any) {
        guard let url = URL(string: self.notificationModel.messageData.urlLandingPage) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func openFacebook(_ sender: Any) {
        guard let url = URL(string: self.notificationModel.messageData.urlFacebook) else {
            return
        }
        UIApplication.shared.open(url)

    }
    
    @IBAction func openLinkedIn(_ sender: Any) {
        guard let url = URL(string: self.notificationModel.messageData.urlLinkedIn) else {
            return
        }
        UIApplication.shared.open(url)

    }
    
    @IBAction func openTwitter(_ sender: Any) {
        guard let url = URL(string: self.notificationModel.messageData.urlTwitter) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func dismissNotificationViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
