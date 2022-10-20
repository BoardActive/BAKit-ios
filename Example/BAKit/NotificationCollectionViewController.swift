//
//  NotificationCollectionViewController.swift
//  BAKit
//
//  Created by Ed Salter on 8/13/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import MessageUI

private let imageViewReuseIdentifier = "imageViewCell"
private let titleLabelReuseIdentifier = "titleLabelContainer"
private let promoDateReuseIdentifier = "promoDateReuseIdentifier"
private let contactUsReuseIdentifier = "contactUsReuseIdentifier"
private let findUsOnlineReuseIdentifier = "findUsOnlineReuseIdentifier"
private let qrCodeCellReuseIdentifier = "qrCodeCellReuseIdentifier"

class NotificationCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    func setupNavBar() {
        let closeBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), landscapeImagePhone: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(closeNotification))
        navigationItem.rightBarButtonItem = closeBarButtonItem
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @objc func closeNotification() {
//        StorageObject.container.notification = nil
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let urlString = StorageObject.container.notification?.imageUrl, !urlString.isEmpty {
            return 2
        }
        return 6
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: titleLabelReuseIdentifier, for: indexPath) as! TitleCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageViewReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        
        if indexPath.row == 0 {
            if let urlString = StorageObject.container.notification?.imageUrl, !urlString.isEmpty {
                cell.imageView.loadImageUsingCache(withUrl: urlString)
            } else {
                cell.isHidden = true
                cell.height = 0
                cell.width = 0
            }
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: titleLabelReuseIdentifier, for: indexPath) as! TitleCollectionViewCell
            guard let title = StorageObject.container.notification?.title, let body = StorageObject.container.notification?.body else {
                cell.height = 0
                cell.width = 0
                cell.isHidden = true
                cell.layoutIfNeeded()
                return cell
            }
            
            cell.titleLabel.text = title
            cell.bodyLabel.text = body
            
            cell.layoutIfNeeded()
            return cell
        }
        
        if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: promoDateReuseIdentifier, for: indexPath) as! PromodDateCollectionViewCell
            guard let startDateString = StorageObject.container.notification?.messageData?.promoDateStarts, let endDateString = StorageObject.container.notification?.messageData?.promoDateEnds else {
                cell.height = 0
                cell.width = 0
                cell.isHidden = true
                return cell
            }
            
            cell.startDateLabel.text = startDateString
            cell.endDateLabel.text = endDateString
            cell.layoutIfNeeded()
            
            return cell
        }
        
        if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contactUsReuseIdentifier, for: indexPath) as! ContactUsCollectionViewCell
            if let urlString = StorageObject.container.notification?.messageData?.urlLandingPage, let _ = URL(string: urlString) {
                cell.homepageButton.addTarget(self, action: #selector(openHomepage(_:)), for: .touchUpInside)
                cell.homepageButton.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
            } else {
                cell.homepageButton.isUserInteractionEnabled = false
                cell.homepageButton.width = 0
                cell.homepageButton.height = 0
                cell.homepageButton.isHidden = true
            }
            
            if (StorageObject.container.notification?.messageData?.email) != nil {
                cell.emailButton.addTarget(self, action: #selector(sendEmail(_:)), for: .touchUpInside)
                cell.emailButton.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
            } else {
                cell.emailButton.isUserInteractionEnabled = false
                cell.emailButton.width = 0
                cell.emailButton.height = 0
                cell.emailButton.isHidden = true
                cell.contactLbl.isHidden = true
            }
            
            if (StorageObject.container.notification?.messageData?.storeAddress) != nil {
                cell.directionsButton.addTarget(self, action: #selector(getDirections(_:)), for: .touchUpInside)
                cell.directionsButton.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
            } else {
                cell.directionsButton.isUserInteractionEnabled = false
                cell.directionsButton.width = 0
                cell.directionsButton.height = 0
                cell.directionsButton.isHidden = true
            }
            if let number = StorageObject.container.notification?.messageData?.phoneNumber?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(), URL(string: "tel://" + number) != nil {
                cell.callButton.addTarget(self, action: #selector(makeCall(_:)), for: .touchUpInside)
                cell.callButton.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.8823529412, alpha: 1)
            } else {
                cell.callButton.isUserInteractionEnabled = false
                cell.callButton.width = 0
                cell.callButton.height = 0
                cell.callButton.isHidden = true
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        
        if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: findUsOnlineReuseIdentifier, for: indexPath) as! FindUsOnlineCollectionViewCell
            
            if let urlString = StorageObject.container.notification?.messageData?.urlFacebook, let _ = URL(string: urlString)  {
                cell.facebookButton.addTarget(self, action: #selector(openFacebook(_:)), for: .touchUpInside)
            } else {
                cell.facebookButton.isUserInteractionEnabled = false
                cell.facebookButton.width = 0
                cell.facebookButton.height = 0
                cell.facebookButton.isHidden = true
            }
            
            if let urlString = StorageObject.container.notification?.messageData?.urlTwitter, let _ = URL(string: urlString) {
                cell.twitterButton.addTarget(self, action: #selector(openTwitter(_:)), for: .touchUpInside)
            } else {
                cell.twitterButton.isUserInteractionEnabled = false
                cell.twitterButton.width = 0
                cell.twitterButton.height = 0
                cell.twitterButton.isHidden = true
            }
            
            if let urlString = StorageObject.container.notification?.messageData?.urlLinkedIn, let _ = URL(string: urlString)  {
                cell.linkedInButton.addTarget(self, action: #selector(openLinkedIn(_:)), for: .touchUpInside)
            } else {
                cell.linkedInButton.isUserInteractionEnabled = false
                cell.linkedInButton.width = 0
                cell.linkedInButton.height = 0
                cell.linkedInButton.isHidden = true
            }
            
            if let urlString = StorageObject.container.notification?.messageData?.urlYoutube, let _ = URL(string: urlString) {
                cell.youTubeButton.addTarget(self, action: #selector(openYoutube(_:)), for: .touchUpInside)
            } else {
                cell.youTubeButton.isUserInteractionEnabled = false
                cell.youTubeButton.width = 0
                cell.youTubeButton.height = 0
                cell.youTubeButton.isHidden = true
                cell.findUsLbl.isHidden = true
            }
            cell.layoutIfNeeded()
            return cell
        }
        
        if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: qrCodeCellReuseIdentifier, for: indexPath) as! QRCollectionViewCell
            
            if let qrURLString = StorageObject.container.notification?.messageData?.urlQRCode, !qrURLString.isEmpty {
                cell.qrImageView.loadImageUsingCache(withUrl: qrURLString)
            } else {
                cell.isHidden = true
            }
            cell.layoutIfNeeded()
            return cell
        }
        
        return emptyCell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    @objc func openHomepage(_ sender: Any) {
        UIApplication.shared.open(URL(string: (StorageObject.container.notification?.messageData?.urlLandingPage)!)!)
    }
    
    @objc func sendEmail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([(StorageObject.container.notification?.messageData?.email)!])
            mail.setMessageBody("", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func getDirections(_ sender: Any) {
        if let address = StorageObject.container.notification?.messageData?.storeAddress {
            let replacedAddress = address.replacingOccurrences(of: " ", with: "+")
                if let addressURL = URL(string: "http://maps.apple.com/?address=\(replacedAddress)") {
                    UIApplication.shared.open(addressURL)
            }
        }
    }
    
    @objc func makeCall(_ sender: Any) {
        let number = StorageObject.container.notification?.messageData?.phoneNumber?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let completeNumber = URL(string: "tel://" + number!)!
        
        UIApplication.shared.open(completeNumber)
    }
    
    @objc func openFacebook(_ sender: Any) {
        UIApplication.shared.open(URL(string: (StorageObject.container.notification?.messageData?.urlFacebook)!)!)
    }
    
    
    @objc func openTwitter(_ sender: Any) {
        UIApplication.shared.open(URL(string: (StorageObject.container.notification?.messageData?.urlTwitter)!)!)
    }
    
    @objc func openLinkedIn(_ sender: Any) {
        UIApplication.shared.open(URL(string: (StorageObject.container.notification?.messageData?.urlLinkedIn)!)!)
    }
    
    @objc func openYoutube(_ sender: Any) {
        if let url = URL(string: (StorageObject.container.notification?.messageData?.urlYoutube)!) {
            UIApplication.shared.open(url)
        }
    }
    
    
}

extension NotificationCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            if let urlString = StorageObject.container.notification?.imageUrl, !urlString.isEmpty {
                return CGSize(width: 370, height: 194)
            }
            return CGSize.zero
        }
        if indexPath.row == 1 {
            return CGSize(width: 370, height: 120.5)
        }
        if indexPath.row == 2 {
            return CGSize(width: 370, height: 74)
        }
        if indexPath.row == 3 {
            return CGSize(width: 370, height: 146.5)
        }
        if indexPath.row == 4 {
            return CGSize(width: 370, height: 146.5)
        }
        if indexPath.row == 5 {
            return CGSize(width: 370, height: 298)
        }
        return CGSize.zero
    }
}

extension NotificationCollectionViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        self.dismiss(animated: true, completion: nil)
    }
}

