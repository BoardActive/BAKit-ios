//
//  AlertController.swift
//  Alamofire
//
//  Created by Ed Salter on 3/25/19.
//

import Foundation

public class AlertController: UIAlertController {
    internal lazy var alertWindow: UIWindow = {
        let secondWindow = UIWindow(frame: UIScreen.main.bounds)
        secondWindow.backgroundColor = UIColor.clear
        secondWindow.windowLevel = UIWindowLevelAlert

        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = UIColor.clear
        secondWindow.rootViewController = rootViewController

        return secondWindow
    }()

    public func showAlert(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let rootviewController = alertWindow.rootViewController {
            alertWindow.makeKeyAndVisible()
            rootviewController.present(self, animated: flag, completion: completion)
        }
    }
    
    public func dismissAlert(animated flag: Bool = true, completion: (() -> Void)? = nil){
        if let rootviewController = alertWindow.rootViewController {
            rootviewController.dismiss(animated: flag, completion: completion)
            UIApplication.shared.windows.first!.makeKeyAndVisible()
            
            if !alertWindow.isKeyWindow {
                alertWindow.isHidden = true
            }
            
            alertWindow.removeFromSuperview()
        }
    }
}
