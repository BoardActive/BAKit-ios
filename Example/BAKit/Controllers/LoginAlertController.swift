//
//  BespokeAlertController.swift
//  BAKit
//
//  Created by Ed Salter on 7/19/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import BAKit

class LoginAlertController: UIAlertController {
    internal lazy var alertWindow: UIWindow = {
        let secondWindow = UIWindow(frame: UIScreen.main.bounds)
        secondWindow.backgroundColor = UIColor.clear
        secondWindow.windowLevel = UIWindowLevelAlert
        
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = UIColor.clear
        secondWindow.rootViewController = rootViewController
        
        return secondWindow
    }()
    
    var usernameTextField: UITextField?
    var passwordTextField: UITextField?
    var toggle: UISwitch?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure() {
        addTextField { (txtEmail) in
            if let email = BoardActive.client.userDefaults?.string(forKey: "email")  {
                txtEmail.text = email
            }
            self.usernameTextField = txtEmail
            self.usernameTextField?.placeholder = "Email"
        }
        
        addTextField { (txtPassword) in
            if let password = BoardActive.client.userDefaults?.string(forKey: "password")  {
                txtPassword.text = password
            }
            self.passwordTextField = txtPassword
            self.passwordTextField?.placeholder = "Password"
            self.passwordTextField?.isSecureTextEntry = true
        }
        
        let loginAction = UIAlertAction(title: "Log in", style: .default) { (action) in
            if let email = self.usernameTextField?.text, !email.isEmpty,
                let password = self.passwordTextField?.text, !password.isEmpty {
                BoardActive.client.userDefaults?.set(email, forKey: "email")
                BoardActive.client.userDefaults?.set(password, forKey: "password")
                BoardActive.client.userDefaults?.set(BoardActive.client.isDevEnv, forKey: "isDevEnv")
                BoardActive.client.userDefaults?.synchronize()
                
                print("Username = \(email)")
                print("Password = \(password)")
                
                BoardActive.client.postLogin(email: email, password: password)
                
                self.dismissAlert()
            } else {
                print("No Username entered")
                print("No password entered")
            }
        }
        
        let label = UILabel(frame: CGRect(x: 100, y: 145, width: 140, height: 22))
        label.text = "Development"
        self.view.addSubview(label)
        self.addAction(loginAction)
        self.view.addSubview(self.createSwitch()!)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.height * 0.35)
        self.view.addConstraint(height);
        self.showAlert()
    }
    
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
    
    public func createSwitch () -> UISwitch? {
        let switchControl = UISwitch(frame:CGRect(x: 30, y: 140, width: 0, height: 0));
        switchControl.isOn = false
        if (BoardActive.client.userDefaults?.bool(forKey: "isDevEnv") ?? false) {
            switchControl.setOn(true, animated: false);
        } else {
            switchControl.setOn(false, animated: false);
        }
        switchControl.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: .valueChanged);
        return switchControl
    }
    
    @objc
    public func switchValueDidChange(sender:UISwitch!){
        if (sender.isOn) {
            BoardActive.client.isDevEnv = true
        } else {
            BoardActive.client.isDevEnv = false
        }
    }
}
