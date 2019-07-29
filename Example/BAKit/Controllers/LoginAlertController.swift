////
////  BespokeAlertController.swift
////  BAKit
////
////  Created by Ed Salter on 7/19/19.
////  Copyright © 2019 BoardActive. All rights reserved.
////
//
//import UIKit
//import BAKit
//
//class LoginAlertController: UIAlertController {
//    internal lazy var alertWindow: UIWindow = {
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
//    var usernameTextField: UITextField?
//    var passwordTextField: UITextField?
//    var toggle: UISwitch?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    func configure() {
//        addTextField { (txtEmail) in
//            if let email = BoardActive.client.userDefaults?.string(forKey: "email")  {
//                txtEmail.text = email
//            }
//            self.usernameTextField = txtEmail
//            self.usernameTextField?.placeholder = "Email"
//            self.usernameTextField?.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
//
//        }
//
//        addTextField { (txtPassword) in
//            if let password = BoardActive.client.userDefaults?.string(forKey: "password")  {
//                txtPassword.text = password
//            }
//            self.passwordTextField = txtPassword
//            self.passwordTextField?.placeholder = "Password"
//            self.passwordTextField?.isSecureTextEntry = true
//             self.passwordTextField?.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
//
//        }
//
//        let loginAction = UIAlertAction(title: "Log in", style: .default) { (action) in
//            if let email = self.usernameTextField?.text, !email.isEmpty,
//                let password = self.passwordTextField?.text, !password.isEmpty {
//                BoardActive.client.userDefaults?.set(email, forKey: "email")
//                BoardActive.client.userDefaults?.set(password, forKey: "password")
//                BoardActive.client.userDefaults?.set(BoardActive.client.isDevEnv, forKey: "isDevEnv")
//                BoardActive.client.userDefaults?.synchronize()
//                let vc = UIViewController()
//                self.addChildViewController(<#T##childController: UIViewController##UIViewController#>)
//                print("Username = \(email)")
//                print("Password = \(password)")
//
//                if (BoardActive.client.postLogin(email: email, password: password)) {
//                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
//                    self.definesPresentationContext = true
//                    homeViewController?.modalPresentationStyle = .overCurrentContext
//                    self.present(homeViewController!, animated: true, completion: nil)
//                }
//
//                (UIApplication.shared.delegate as? AppDelegate)?.setupSDK()
//
//                self.dismissAlert()
//            } else {
//                print("No Username entered")
//                print("No password entered")
//
//                self.showAlert()
//            }
//        }
//
//        let label = UILabel(frame: CGRect(x: 100, y: 145, width: 140, height: 22))
//        label.text = "Development"
//        self.view.addSubview(label)
//        if ((self.usernameTextField?.text!.isEmpty)! || (self.passwordTextField?.text!.isEmpty)!) {
//            self.actions[0].isEnabled = false
//        } else {
//            self.actions[0].isEnabled = true
//        }
//        self.view.addSubview(self.createSwitch()!)
//        setValue(UIViewController(), forKey: "contentView")
//        let height:NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.height * 0.35)
//        self.view.addConstraint(height);
//    }
//
//    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
//        guard let vc = vc else { return }
//        setValue(vc, forKey: "contentViewController")
//        if let height = height {
//            vc.preferredContentSize.height = height
//            preferredContentSize.height = height
//        }
//    }
//
//    @objc func textChanged(_ sender: Any) {
//        let textfield = sender as! UITextField
//        var resp : UIResponder! = textfield
//        while !(resp is UIAlertController) { resp = resp.next }
//        let alert = resp as! UIAlertController
//        alert.actions[0].isEnabled = (!(self.usernameTextField?.text!.isEmpty)! && !(self.passwordTextField?.text!.isEmpty)!)
//    }
//
//    public func showAlert(animated flag: Bool = true, completion: (() -> Void)? = nil) {
//        if let rootviewController = self.alertWindow.rootViewController {
//            self.alertWindow.makeKeyAndVisible()
//            rootviewController.present(self, animated: flag, completion: completion)
//        }
//    }
//
//    public func dismissAlert(animated flag: Bool = true, completion: (() -> Void)? = nil){
//        if let rootviewController = self.alertWindow.rootViewController {
//            rootviewController.dismiss(animated: flag, completion: completion)
//            UIApplication.shared.windows.first!.makeKeyAndVisible()
//
//            if !self.alertWindow.isKeyWindow {
//                self.alertWindow.isHidden = true
//            }
//
//            self.alertWindow.removeFromSuperview()
//        }
//    }
//
//    public func createSwitch () -> UISwitch? {
//        let switchControl = UISwitch(frame:CGRect(x: 30, y: 140, width: 0, height: 0));
//        switchControl.isOn = false
//        if (BoardActive.client.userDefaults?.bool(forKey: "isDevEnv") ?? false) {
//            switchControl.setOn(true, animated: false);
//        } else {
//            switchControl.setOn(false, animated: false);
//        }
//        switchControl.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: .valueChanged);
//        return switchControl
//    }
//
//    @objc
//    public func switchValueDidChange(sender:UISwitch!){
//        if (sender.isOn) {
//            BoardActive.client.isDevEnv = true
//        } else {
//            BoardActive.client.isDevEnv = false
//        }
//    }
//}

import UIKit
import BAKit
extension UIAlertController {
    
    /// Add two textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - textFieldOne: first textField
    ///   - textFieldTwo: second textField
    
    func addTwoTextFields(height: CGFloat = 60, hInset: CGFloat = 0, vInset: CGFloat = 0, textFieldOne: TextField.Config?, textFieldTwo: TextField.Config?) {
        let textField = TwoTextFieldsViewController(height: height, hInset: hInset, vInset: vInset, textFieldOne: textFieldOne, textFieldTwo: textFieldTwo)
        set(vc: textField, height: height * 2 + 2 * vInset)
    }
}

final class TwoTextFieldsViewController: UIViewController {
    
    fileprivate lazy var textFieldView: UIView = UIView()
    fileprivate lazy var textFieldOne: TextField = TextField()
    fileprivate lazy var textFieldTwo: TextField = TextField()
    
    fileprivate var height: CGFloat
    fileprivate var hInset: CGFloat
    fileprivate var vInset: CGFloat
    
        var usernameTextField: UITextField?
        var passwordTextField: UITextField?

    init(height: CGFloat, hInset: CGFloat, vInset: CGFloat, textFieldOne configurationOneFor: TextField.Config?, textFieldTwo configurationTwoFor: TextField.Config?) {
        self.height = height
        self.hInset = hInset
        self.vInset = vInset
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textFieldView)
        
        textFieldTwo.action { (txtPassword) in
        }

        textFieldView.addSubview(textFieldOne)
        textFieldView.addSubview(textFieldTwo)
        
        textFieldView.width = view.width
        textFieldView.height = height * 2
        textFieldView.maskToBounds = true
        textFieldView.borderWidth = 1
        textFieldView.borderColor = UIColor.lightGray
        textFieldView.cornerRadius = 8
        
        configurationOneFor?(textFieldOne)
        configurationTwoFor?(textFieldTwo)
        
        //preferredContentSize.height = height * 2 + vInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        Log("has deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textFieldView.width = view.width - hInset * 2
        textFieldView.height = height * 1.5
        textFieldView.center.x = view.center.x
        textFieldView.center.y = view.center.y / 1.75
        
        textFieldOne.width = textFieldView.width
        textFieldOne.height = textFieldView.height / 2
        textFieldOne.center.x = textFieldView.width / 2
        textFieldOne.center.y = textFieldView.height / 4
        
        textFieldTwo.width = textFieldView.width
        textFieldTwo.height = textFieldView.height / 2
        textFieldTwo.center.x = textFieldView.width / 2
        textFieldTwo.center.y = textFieldView.height - textFieldView.height / 4
    }

}

