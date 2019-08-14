
//
//  ViewController.swift
//  BAKit
//
//  Created by HVNT on 08/23/2018.
//  Copyright (c) 2018 HVNT. All rights reserved.
//

import UIKit
import BAKit
import UserNotifications
import Firebase
import MaterialComponents
import CoreData

class LoginViewController: UIViewController {
    @IBOutlet weak var devEnvSwitch: UISwitch!
    @IBOutlet weak var devEnvLabel: UILabel!
    @IBOutlet weak var emailTextField: MDCTextField!
    @IBOutlet weak var passwordTextField: MDCTextField!
    @IBOutlet weak var isolatedView: ShadowView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        if BoardActive.client.userDefaults!.bool(forKey: String.DeviceRegistered), let anEmail = BoardActive.client.userDefaults!.string(forKey: String.ConfigKeys.Email), let aPassword = BoardActive.client.userDefaults!.string(forKey: String.ConfigKeys.Password)  {
            self.emailTextField.text = anEmail
            self.passwordTextField.text = aPassword
            if (BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey) == String.AppKeys.Dev) {
                devEnvSwitch.setOn(true, animated: false)
                BoardActive.client.isDevEnv = true
            } else {
                devEnvSwitch.setOn(false, animated: false)
                BoardActive.client.isDevEnv = false
            }
            self.signInAction(self)
        }
            
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

//        devEnvSwitch.isHidden = true
//        devEnvLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        self.navigationController!.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            DispatchQueue.main.async {
                self.showCredentialsErrorAlert(error: "Both fields must contain entries.")
            }
            return
        }
        
        if (!email.isEmpty && !password.isEmpty) {
            BoardActive.client.userDefaults?.set(email, forKey: "email")
            BoardActive.client.userDefaults?.set(password, forKey: "password")
            
            if self.devEnvSwitch.isOn {
                BoardActive.client.userDefaults?.set(true, forKey: "isDevEnv")
                BoardActive.client.userDefaults?.synchronize()
            } else {
                BoardActive.client.userDefaults?.set(false, forKey: "isDevEnv")
            }
//            BoardActive.client.userDefaults?.set(, forKey: <#T##String#>)
//            var json: Dictionary<String,Any> = [:]
            let operationQueue = OperationQueue()
            let registerDeviceOperation = BlockOperation {
                BoardActive.client.postLogin(email: email, password: password) { (parsedJSON, err) in
                    guard (err == nil) else {
                        DispatchQueue.main.async {
                            self.showCredentialsErrorAlert(error: err!.localizedDescription)
                        }
                        return
                    }
                    
                    if let parsedJSON = parsedJSON {
                        let payload: LoginPayload = LoginPayload.init(fromDictionary: parsedJSON)
                       
                        if payload.apps.count < 1 {
                            DispatchQueue.main.async {
                                self.showCredentialsErrorAlert(error: parsedJSON["message"] as! String)
                                return
                            }
                        } else {
                            StorageObject.container.payload = payload
                            StorageObject.container.apps = payload.apps
                            print("PAYLOAD :: APPS : \(payload.apps.description)")
                            
                            OperationQueue.main.addOperation {
                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let appPickingViewController = storyBoard.instantiateViewController(withIdentifier: "AppSelectViewController")
                                self.navigationController?.pushViewController(appPickingViewController, animated: true)
                            }
                        }
                    }
                }
                
                if BoardActive.client.isDevEnv {
                    BoardActive.client.userDefaults?.set(String.AppKeys.Dev, forKey: String.ConfigKeys.AppKey)
                } else {
                    BoardActive.client.userDefaults?.set(String.AppKeys.Prod, forKey: String.ConfigKeys.AppKey)
                }
                
                BoardActive.client.userDefaults?.synchronize()
            }

//            let transitionBlockOperation = BlockOperation {
//                DispatchQueue.main.async {
//                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                    let appPickingViewController = storyBoard.instantiateViewController(withIdentifier: "AppSelectViewController")
//                    self.navigationController?.pushViewController(appPickingViewController, animated: true)
//                }
//            }
            
//            transitionBlockOperation.addDependency(registerDeviceOperation)
            operationQueue.addOperation(registerDeviceOperation)
//            operationQueue.addOperation(transitionBlockOperation)
           
//            if payload.apps.count == 1 {
//                let appId = String(payload.apps.first!.id)
//                BoardActive.client.userDefaults?.set(appId, forKey: String.ConfigKeys.AppId)
//                BoardActive.client.userDefaults?.synchronize()
//
//                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController")
//                self.navigationController?.pushViewController(homeViewController, animated: true)
//            } else {
//            }
        } else {
            DispatchQueue.main.async {
                self.showCredentialsErrorAlert(error:"Both fields must contain entries.")
            }
        }
    }

    @objc
    func showCredentialsErrorAlert(error: String) {
        let alert = UIAlertController(title: "Login Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func switchValueDidChange(_ sender: Any) {
        if ((sender as! UISwitch).isOn) {
            BoardActive.client.isDevEnv = true
        } else {
            BoardActive.client.isDevEnv = false
        }
    }
    
    @objc func textChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        var resp : UIResponder! = textfield
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = (!(alert.textFields![0].text!.isEmpty) && !(alert.textFields![0].text!.isEmpty))
    }
    
    var count = 0
    
    @IBAction func tapHandler(_ sender: Any) {
        if count <= 6 {
            count += 1
        } else {
            count = 0
            if (devEnvSwitch.isHidden || devEnvLabel.isHidden) {
                devEnvSwitch.isHidden = false
                devEnvLabel.isHidden = false
            } else {
                devEnvSwitch.isHidden = true
                devEnvLabel.isHidden = true
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
