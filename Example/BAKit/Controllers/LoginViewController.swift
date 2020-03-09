
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
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var devSwitchStack: UIStackView!
    
    let activitiController = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 20)!]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        activitiController.frame = CGRect(x: (self.view.frame.width/2) - 40, y: (self.view.frame.height/2) - 40, width: 80, height: 80)
        activitiController.backgroundColor = UIColor.lightGray
        activitiController.activityIndicatorViewStyle = .whiteLarge
        activitiController.layer.cornerRadius = 10
        view.addSubview(activitiController)
        
        if BoardActive.client.userDefaults!.bool(forKey: String.ConfigKeys.DeviceRegistered), let anEmail = BoardActive.client.userDefaults!.string(forKey: String.ConfigKeys.Email), let aPassword = BoardActive.client.userDefaults!.string(forKey: String.ConfigKeys.Password)  {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        self.navigationController!.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardBeginHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect)?.height {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 60)
            } else if abs(Int(self.view.frame.origin.y)) == Int(keyboardBeginHeight - 60) {
                self.view.frame.origin.y += (keyboardBeginHeight - keyboardSize.height)
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
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
            DispatchQueue.main.async {
                self.activitiController.startAnimating()
            }
            BoardActive.client.userDefaults?.set(email, forKey: "email")
            BoardActive.client.userDefaults?.set(password, forKey: "password")
            
            if self.devEnvSwitch.isOn {
                BoardActive.client.userDefaults?.set(true, forKey: "isDevEnv")
            } else {
                BoardActive.client.userDefaults?.set(false, forKey: "isDevEnv")
            }
            BoardActive.client.userDefaults?.synchronize()
            
            let operationQueue = OperationQueue()
            let registerDeviceOperation = BlockOperation {
                BoardActive.client.login(email: email, password: password) { (parsedJSON, err) in
                    guard (err == nil) else {
                        DispatchQueue.main.async {
                            self.showCredentialsErrorAlert(error: err!.localizedDescription)
                            self.activitiController.stopAnimating()
                        }
                        
                        
                        return
                    }
                    
                    if let parsedJSON = parsedJSON {
                        let payload: LoginPayload = LoginPayload.init(fromDictionary: parsedJSON)
                        CoreDataStack.sharedInstance.deleteStoredData(entity: "BAKitApp")
                        for app in payload.apps {
//                            let apps = CoreDataStack.sharedInstance.fetchAppsFromDatabase()
                            let newApp = CoreDataStack.sharedInstance.createBAKitApp(fromApp: app)
//                            let appid =  Int(truncatingIfNeeded: app.id)
//                            let newAppId =  Int(truncatingIfNeeded: newApp.id)
                             StorageObject.container.apps.append(newApp)
//                            if  apps!.count > 0 {
//                                if appid != newAppId {
//                                    StorageObject.container.apps.append(newApp)
//                                } else {
//                                    CoreDataStack.sharedInstance.mainContext.delete(newApp)
//                                }
//                            }
//                            else
//                            {
//                                 StorageObject.container.apps.append(newApp)
//                            }
                            
                        }
                        
                        if payload.apps.count < 1 {
                            DispatchQueue.main.async {
                                self.showCredentialsErrorAlert(error: parsedJSON["message"] as! String)
                                return
                            }
                        } else {
                            print("PAYLOAD :: APPS : \(payload.apps.description)")
                            DispatchQueue.main.async {

                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let appPickingViewController = storyBoard.instantiateViewController(withIdentifier: "AppPickingViewController")
                                self.navigationController?.pushViewController(appPickingViewController, animated: true)
                        }
                        }
                        DispatchQueue.main.async {
                        self.activitiController.stopAnimating()
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
            operationQueue.addOperation(registerDeviceOperation)
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
    
    @IBAction func tapHandler(_ sender: UITapGestureRecognizer) {
    if count < 6 {
            count += 1
        } else {
            count = 0
            if (devSwitchStack.isHidden) {
                devSwitchStack.isHidden = false
            } else {
                devSwitchStack.isHidden = true
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
