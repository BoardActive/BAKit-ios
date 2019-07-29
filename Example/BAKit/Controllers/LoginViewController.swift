
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

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loginComplete), name: NSNotification.Name("LOGIN"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCredentialsErrorAlert), name: NSNotification.Name("LOGIN ERROR"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signOutShowLogin), name: NSNotification.Name("signout"), object: nil)
        if (BoardActive.client.userDefaults!.bool(forKey:String.DeviceRegistered)) {
            DispatchQueue.main.async {
                self.loginComplete()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInAction(_ sender: Any) {
        var email = BoardActive.client.userDefaults?.string(forKey: "email")  ?? ""
        var password = BoardActive.client.userDefaults?.string(forKey: "password")  ?? ""
        
        if (!email.isEmpty && !password.isEmpty) {
            BoardActive.client.postLogin(email: email, password: password)
            return
        }
        
        let alert = UIAlertController(title: "Login", message: nil, preferredStyle: .alert)
        let configOne: TextField.Config = { textField in
            textField.textColor = .black
            textField.placeholder = "Email"
            textField.left(image: #imageLiteral(resourceName: "user"), color: .black)
            textField.leftViewPadding = 16
            textField.leftTextPadding = 12
            textField.borderWidth = 1
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .none
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.returnKeyType = .continue
            textField.action { txtEmail in
                if let inputText = txtEmail.text {
                    email = inputText
                    textField.text = txtEmail.text
                }
//                textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
            }
        }
        

        let configTwo: TextField.Config = { textField in
            textField.textColor = .black
            textField.placeholder = "Password"
            textField.left(image: #imageLiteral(resourceName: "lock"), color: .black)
            textField.leftViewPadding = 16
            textField.leftTextPadding = 12
            textField.borderWidth = 1
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.clearsOnBeginEditing = true
            textField.autocapitalizationType = .none
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
            textField.action { txtPassword in
                if let inputText = txtPassword.text {
                    password = inputText
                    textField.text = txtPassword.text
                }
//                textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
            }
        }
        // vInset - is top and bottom margin of two textFields
        alert.addTwoTextFields(vInset: 12, textFieldOne: configOne, textFieldTwo: configTwo)
        alert.addAction(image: nil, title: "Sign In", color: nil, style: .default, isEnabled: true) { (action) in
            guard !email.isEmpty || !password.isEmpty else {
                alert.dismiss(animated: false, completion: nil)
                self.showCredentialsErrorAlert()
                return
            }
                BoardActive.client.postLogin(email: email, password: password)
                alert.dismiss(animated: true, completion: nil)
//            } else {
//                let alert = UIAlertController(style: .alert, title: "Sign In Error", message: "Incorrect email or password.")
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: self.signInAction(_:)))
//                alert.show()
//            }
        }
//                alert.dismiss(animated: false, completion: {
//                    }
//                })
//            } else {
//                print("No Username entered")
//                print("No password entered")
//                alert.show()
//            }
        
        
        let switchControl = UISwitch(frame:CGRect(x: 30, y: 160, width: 0, height: 0));
        switchControl.addTarget(self, action: #selector(self.switchValueDidChange(sender:)), for: .valueChanged);
        switchControl.isOn = false
        
        if (BoardActive.client.userDefaults?.bool(forKey: "isDevEnv") ?? false) {
            switchControl.setOn(true, animated: false);
        } else {
            switchControl.setOn(false, animated: false);
        }
        
        let label = UILabel(frame: CGRect(x: 100, y: 165, width: 140, height: 22))
        label.text = "Development"
        alert.view.addSubview(label)
        
        alert.view.addSubview(switchControl)
        alert.show(animated: true, vibrate: false, style: .light, completion: nil)
    }
    //        let alertController = LoginAlertController(title: "Log in", message: "Please enter your credentials", preferredStyle: .alert)
    
    //        alertController.configure()
    //        alertController.showAlert()

    @objc
    func showCredentialsErrorAlert() {
        let alert = UIAlertController(title: "Login Error", message: "Please verify you credentials and login.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.signInAction(self)
        }
        alert.addAction(okAction)
        self.show(alert, sender: nil)
    }
    
    @objc
    public func switchValueDidChange(sender:UISwitch!){
        if (sender.isOn) {
            BoardActive.client.isDevEnv = true
        } else {
            BoardActive.client.isDevEnv = false
        }
    }
    
    @objc
    func loginComplete() {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as? AppDelegate)?.setupSDK()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        self.definesPresentationContext = true
        homeViewController.modalPresentationStyle = .overCurrentContext
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        BoardActive.client.signOut()
    }
    
    @objc func textChanged(_ sender: Any) {

        let textfield = sender as! UITextField
        var resp : UIResponder! = textfield
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = (!(alert.textFields![0].text!.isEmpty) && !(alert.textFields![0].text!.isEmpty))
    }
    
    @objc func signOutShowLogin() {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 0
        }
        
        
    }

}


