////
////  NotificationView.swift
////  BAKit-BAKit
////
////  Created by Ed Salter on 4/8/19.
////
//
import UIKit
import os.log
import BAKit
//
class NotificationViewController: UIViewController {
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var notificationImageView: UIImageView!
//    @IBOutlet weak var bodyTextView: UITextView!
//    @IBOutlet weak var dismissButton: UIButton!
//    @IBOutlet weak var messageDataImageView: UIImageView!
//    
//    public var alertModel: Alert!
//    public var messageData: MessageData!
//    public var apsModel: Aps!
//    
//    public var notificationModel: NotificationModel!
//        
//    private lazy var displayWindow: UIWindow = {
//        let secondWindow = UIWindow(frame: UIScreen.main.bounds)
//        secondWindow.backgroundColor = UIColor.clear
//        secondWindow.windowLevel = UIWindowLevelAlert
//        
//        let rootViewController = UIViewController()
//        rootViewController.view.backgroundColor = UIColor.clear
//        secondWindow.rootViewController = rootViewController
//        
//        return secondWindow
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let group = DispatchGroup()
//        
//        group.enter()
//        DispatchQueue.main.async {
//            self.populateModels(notificationModel: self.notificationModel)
//            group.leave()
//        }
//        group.wait()
//
////        let imageURLString = self.notificationModel.dictionaryRepresentation()["imageUrl"] as! String
////        self.notificationImageView!.loadImageUsingCache(withUrl: imageURLString)
////        let qrCodeURLString = self.notificationModel.dictionaryRepresentation()["urlQRCode"] as! String
////        self.messageDataImageView!.loadImageUsingCache(withUrl: qrCodeURLString)
//        
//        self.titleLabel.text = String(alertModel.title!)
//        
//        self.bodyTextView.text = alertModel.body!
////        self.populateBody(model: self.notificationModel)
//    }
//
//    public func populateModels(notificationModel: NotificationModel) {
//        if notificationModel.isValidNotification() {
//            apsModel = Aps(object: self.notificationModel.aps!)
//            alertModel = Alert(object: self.apsModel.alert!)
//            messageData = MessageData(object: self.notificationModel.messageData!)
//        }
//    }
//    
//    private func populateBody(model: NotificationModel) {
//        var notificationBody = ""
//        var bodyString: NSAttributedString
//        
//        let startDateString = "Start Date: \(messageData.promoDateStarts ?? "")\n"
//        
//        let endDateString = "End Date: \(messageData.promoDateEnds ?? "")\n"
//        
//        let landingPage: String = "Landing page: \(messageData.urlLandingPage ?? "")\n"
//    
//        let landingPageMutAttrString = NSMutableAttributedString(string: landingPage)
//        if !landingPageMutAttrString.setAsLink(textToFind: messageData.urlLandingPage ?? "", linkURL: messageData.urlLandingPage ?? "") {
//            fatalError("NotificationViewController :: landingPageMutAttrString :: \(landingPageMutAttrString.debugDescription)")
//        }
//        let finalLandingPageAttrString:NSAttributedString = landingPageMutAttrString.copy() as! NSAttributedString
//        
//        let phoneNumber = "Phone Number: \(messageData.phoneNumber ?? "")\n"
//        let phoneNumberMutAttrString = NSMutableAttributedString(string: phoneNumber)
//        if let number = messageData.phoneNumber {
//            var intermediateNumber = number.replacingOccurrences(of: "+", with: " ")
//            intermediateNumber = number.replacingOccurrences(of: "(", with: " ")
//            intermediateNumber = number.replacingOccurrences(of: ")", with: " ")
////            intermediateNumber = number.replacingOccurrences(of: "-", with: " ")
//            intermediateNumber = number.replacingOccurrences(of: " ", with: "")
//            let finalNumber = "tel:" + intermediateNumber
//            
//            if !phoneNumberMutAttrString.setAsLink(textToFind: number, linkURL: finalNumber) {
//                fatalError("NotificationViewController :: landingPageMutAttrString :: \(landingPageMutAttrString.debugDescription)")
//            }
//        }
//        let finalPhoneNumberAttrString:NSAttributedString = phoneNumberMutAttrString.copy() as! NSAttributedString
//        
//        let email = "Email: \(messageData.email ?? "")\n"
//        let emailMutAttrString = NSMutableAttributedString(string: email)
//        if !emailMutAttrString.setAsLink(textToFind: messageData.email ?? "", linkURL: "mailto:\(email)") {
//            fatalError("NotificationViewController :: emailMutAttrString :: \(emailMutAttrString.debugDescription)")
//        }
//        let finalEmailAttrString:NSAttributedString = emailMutAttrString.copy() as! NSAttributedString
//    
//        let facebook = "Facebook: \(messageData.urlFacebook ?? "")\n"
//        let facebookMutAttrString = NSMutableAttributedString(string: facebook)
//        if !facebookMutAttrString.setAsLink(textToFind: messageData.urlFacebook ?? "", linkURL: facebookMutAttrString.string) {
//            fatalError("NotificationViewController :: facebookMutAttrString :: \(facebookMutAttrString.debugDescription)")
//        }
//        let finalFacebookAttrString:NSAttributedString = facebookMutAttrString.copy() as! NSAttributedString
//        
//        let linkedIn = "LinkedIn: \(messageData.urlLinkedIn ?? "")\n"
//        let linkedInMutAttrString = NSMutableAttributedString(string: linkedIn)
//        if !linkedInMutAttrString.setAsLink(textToFind: messageData.urlLinkedIn ?? "", linkURL: messageData.urlLinkedIn ?? "") {
//            fatalError("NotificationViewController :: facebookMutAttrString :: \(linkedInMutAttrString.debugDescription)")
//        }
//        let finalLinkedInAttrString: NSAttributedString = linkedInMutAttrString.copy() as! NSAttributedString
//        
//        let twitter = "Twitter: \(messageData.urlTwitter ?? "")\n"
//        let twitterMutAttrString = NSMutableAttributedString(string: twitter)
//        if !twitterMutAttrString.setAsLink(textToFind: messageData.urlTwitter ?? "", linkURL: messageData.urlTwitter ?? "") {
//            fatalError("NotificationViewController :: twitterMutAttrString :: \(twitterMutAttrString.debugDescription)")
//        }
//        let finalTwitterAttrString:NSAttributedString = twitterMutAttrString.copy() as! NSAttributedString
//        
//        let youTube = "YouTube: \(messageData.urlYoutube ?? "")\n"
//        let youTubeMutAttrString = NSMutableAttributedString(string: youTube)
//        if !youTubeMutAttrString.setAsLink(textToFind: messageData.urlYoutube ?? "", linkURL: messageData.urlYoutube ?? "") {
//            fatalError("NotificationViewController :: youTubeMutAttrString :: \(youTubeMutAttrString.debugDescription)")
//        }
//        let finalYouTubeAttrString:NSAttributedString = youTubeMutAttrString.copy() as! NSAttributedString
//        
//        bodyString = finalLandingPageAttrString
//        bodyString = bodyString + finalPhoneNumberAttrString + finalEmailAttrString
//        bodyString = bodyString + finalFacebookAttrString + finalLinkedInAttrString
//        bodyString = bodyString + finalTwitterAttrString + finalYouTubeAttrString
//        
//        // Create textview just for landingPageMutAttrString and set text equal to it + textView.isUserInteractionEnabled = true & textView.isEditable = false
//        
////        notificationBody = bodyString + "\n"
//        self.bodyTextView.text = bodyString.string
//    }
//    
//    public func showNotification(animated flag: Bool = true, completion: (() -> Void)? = nil) {
//        if let rootviewController = displayWindow.rootViewController {
//            displayWindow.isHidden = false
//            displayWindow.makeKeyAndVisible()
//            rootviewController.present(self, animated: flag, completion: completion)
//        }
//    }
//
//    @IBAction func dismissNotificationController(_ sender: UIButton) {
//        if let rootviewController = displayWindow.rootViewController {
//            for window in UIApplication.shared.windows {
//                if window.windowLevel == UIWindowLevelAlert {
//                    dismiss(animated: true, completion: nil)
//                    window.isHidden = true
//                    window.removeFromSuperview()
//                }
//            }
//        }
//        
//        UIApplication.shared.windows.first!.makeKeyAndVisible()
//    }
}
