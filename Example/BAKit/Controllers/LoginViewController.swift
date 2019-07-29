
//
//  ViewController.swift
//  BAKit
//
//  Created by HVNT on 08/23/2018.
//  Copyright (c) 2018 HVNT. All rights reserved.
//

import UIKit
import MapKit
import BAKit
import UserNotifications
import Firebase

class LoginViewController: UIViewController, MKMapViewDelegate, BoardActiveDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BoardActive.client.delegate = self
        
        map.delegate = self
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
    }
    
    @IBAction func attributesTest(_ sender: Any) {
        let attributes = Attributes.init(fromDictionary: ["stock":["email":"dev@boardactive.com", "gender":"male", "facebookUrl":"NOTnil", "instagramUrl":"NOTnil", "linkedInUrl":"NOTnil"]])
        
        
        print("Attributes :: \(attributes)")
    }
    
    let regionRadius: CLLocationDistance = 100
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 
                                                                  regionRadius, regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
