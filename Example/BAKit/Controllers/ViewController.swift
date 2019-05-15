
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

class ViewController: UIViewController, MKMapViewDelegate, BoardActiveDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
        
        BoardActive.client.delegate = self
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
    
    func appReceivedRemoteNotification(notification: UNNotification) {
        let tempUserInfo = notification.request.content.userInfo as! [String:Any]
        let notificationModel = NotificationModel(fromDictionary: tempUserInfo)
        
        let storyboard = UIStoryboard(name: "NotificationBoard", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationViewController else {
            return
        }
        
//        viewController.notificationModel = notificationModel
//        viewController.loadViewIfNeeded()
//        viewController.showNotification(animated: true, completion: nil)
    }
}
