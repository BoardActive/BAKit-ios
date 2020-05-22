//
//  CustomAttributesVC.swift
//  AdDrop
//
//  Created by Rahul Shrimali on 20/05/20.
//  Copyright © 2020 BoardActive. All rights reserved.
//

import UIKit
import BAKit

class UserAttributesVC: UIViewController {
    @IBOutlet weak var tblContentLayout: UITableView!
    let activitiController = UIActivityIndicatorView()
    var arrAttributeList: [AttributeElement] = []
     var temparrrAttributeList: [AttributeElement] = []
    var arrrMeList: [String : Any] = [:]
    var customattributes: [String : Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        registerCells()
        configureActivityIndicator()
        getAttributeList()
        getMe()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func registerCells() {
        tblContentLayout.register(UINib(nibName: TextBoxCell.identifier, bundle: nil), forCellReuseIdentifier: TextBoxCell.identifier)
        tblContentLayout.register(UINib(nibName: DateCell.identifier, bundle: nil), forCellReuseIdentifier: DateCell.identifier)
        tblContentLayout.register(UINib(nibName: RadioButtonCell.identifier, bundle: nil), forCellReuseIdentifier: RadioButtonCell.identifier)
        tblContentLayout.register(UINib(nibName: ButtonCell.identifier, bundle: nil), forCellReuseIdentifier: ButtonCell.identifier)
    }
    
    fileprivate func configureActivityIndicator() {
        activitiController.frame = CGRect(x: (self.view.frame.width/2) - 40, y: (self.view.frame.height/2) - 40, width: 80, height: 80)
        activitiController.backgroundColor = UIColor.lightGray
        activitiController.activityIndicatorViewStyle = .whiteLarge
        activitiController.layer.cornerRadius = 10
        view.addSubview(activitiController)
    }
    
    fileprivate func getAttributeList() {
        activitiController.startAnimating()
        BoardActive.client.getAttributes { (responseArray, error) in
            DispatchQueue.main.async {
                self.activitiController.stopAnimating()
                if (responseArray != nil) {
                    for i in 0..<(responseArray?.count ?? 0) {
                    self.arrAttributeList.append(AttributeElement(dataList: responseArray![i]))
                    }
                    self.arrAttributeList = self.arrAttributeList.filter { $0.isStock! == false }
                    self.tblContentLayout.reloadData()
                }
            }
        }
    }
    
    fileprivate func getMe() {
           activitiController.startAnimating()
           BoardActive.client.getMe { (responseArray, error) in
               DispatchQueue.main.async {
                   self.activitiController.stopAnimating()
                   if (responseArray != nil) {
                    self.arrrMeList = responseArray!
                    print(self.arrrMeList)
                    
                   
                   }
                
                let attributes  = self.arrrMeList["attributes"] as! [String : Any]
                print(attributes)
                self.customattributes = attributes["custom"] as! [String : Any]
                print(self.customattributes)
                
               }
           }
       }
    
    
    fileprivate func configureNavigation() {
        self.navigationController?.title = "User Attributes"
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let btnBack = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        btnBack.setImage(UIImage(named:"back"), for: .normal)
        btnBack.tintColor = .white
        btnBack.addTarget(self, action: Selector(("btnBack")), for: .touchUpInside)
        let baritemBack = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItems?.removeAll()
        self.navigationItem.leftBarButtonItems = [baritemBack]
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardBeginHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect)?.height {
            var contentInset = tblContentLayout.contentInset
            contentInset.bottom = keyboardBeginHeight
            tblContentLayout.contentInset = contentInset
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        tblContentLayout.contentInset = .zero
    }

    
    
    @objc func btnBack() {
        self.navigationController?.popViewController(animated: true)
    }

}


extension UserAttributesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrAttributeList.count == 0) {
            return 0
        }
        return arrAttributeList.count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == arrAttributeList.count) {
            return 72.0
        }
        
        if(arrAttributeList[indexPath.row].type == .boolean) {
            return 70.0

        } else {
            return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row != arrAttributeList.count) {
            let attributeElementObj = arrAttributeList[indexPath.row]
            
            switch attributeElementObj.type {
            case .string, .integer, .double:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextBoxCell.identifier) as? TextBoxCell
                    cell?.delegateTextfieldCell = self
                    if let val = customattributes[attributeElementObj.placeHolder!] {
                        print(val)
                        cell?.setupCell(placeholderText: "", textValue: val as! String, textFieldTag: indexPath.row)
                        return cell!
                        // now val is not nil and the Optional has been unwrapped, so we can use it
                    }
                    cell?.setupCell(placeholderText: attributeElementObj.placeHolder ?? "", textValue: attributeElementObj.value, textFieldTag: indexPath.row)
                    return cell!
                
                case .date:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.identifier) as? DateCell
                    cell?.delegateDateCell = self
                    if let val = customattributes[attributeElementObj.placeHolder!] {
                                           print(val)
                                           cell?.setupCell(placeholderText: "", textValue: val as! String, textFieldTag: indexPath.row)
                                           return cell!
                     }
                    cell?.setupCell(placeholderText: attributeElementObj.placeHolder ?? "", textValue: attributeElementObj.value, textFieldTag: indexPath.row)
                    return cell!
                
                case .boolean:
                    let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.identifier) as? RadioButtonCell
                    cell?.delegateRadioButtonCell = self
                    if (attributeElementObj.placeHolder?.lowercased() == "gender") {
                        if let val = customattributes[attributeElementObj.placeHolder!] {
                                                                 print(val)
                            cell?.delegateRadioButtonCell = self
                            cell?.setRadioCell(title: "", titleOption1: "Female", titleOption2: "Male", buttonTag: indexPath.row, value: val as! String)
                                                                 return cell!
                                           }
                        cell?.setRadioCell(title: attributeElementObj.placeHolder ?? "", titleOption1: "Female", titleOption2: "Male", buttonTag: indexPath.row, value: attributeElementObj.value)
                    } else {
                        if let val = customattributes[attributeElementObj.placeHolder!] {
                                                                                      print(val)
                                                 cell?.setRadioCell(title: "", titleOption1: "No", titleOption2: "Yes", buttonTag: indexPath.row, value: val as! String)
                                                                                      return cell!
                                                                }
                        cell?.delegateRadioButtonCell = self
                        cell?.setRadioCell(title: attributeElementObj.placeHolder ?? "", titleOption1: "No", titleOption2: "Yes", buttonTag: indexPath.row, value: attributeElementObj.value)
                    }
                    return cell!

                default:
                    return UITableViewCell()
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier) as? ButtonCell
            cell?.delegateButton = self
            return cell!
        }
    }
}

//MARK:- TextBoxCellDelegate methods
extension UserAttributesVC: TextBoxCellDelegate,DateCellDelegate,RaidoButtonCellDelegate {
   
    func storeValues(textString:String, index: Int)
    {
     print(textString)
        arrAttributeList[index].value = textString
    }
    func storeDateValue(textdate: String, index: Int) {
           arrAttributeList[index].value = textdate
       }
    func RadioButtonValue(textradio: String, index: Int) {
           arrAttributeList[index].value = textradio
        print(arrAttributeList[index].value)
       }
}



//MARK:- ButtonCellDelegate methods
extension UserAttributesVC: ButtonCellDelegate {
    func buttonAction(sender: UIButton) {
        var tempData = StorageObject.container.userInfo?.toDictionary()
        var dictCustom: [String: Any] = [:]
        var dictStock: [String: Any] = [:]
        for item in arrAttributeList {
            if ((item.isStock == false) && !item.value.isEmpty) {
                dictCustom[item.placeHolder!] = item.value
            } else if(!item.value.isEmpty) {
                dictStock[item.placeHolder!] = item.value
            }
        }
        tempData?["attributes"] = ["stock": dictStock, "custom": dictCustom]
        self.activitiController.startAnimating()
        BoardActive.client.updateUserData(body: tempData!) { (response, error) in
            DispatchQueue.main.async {
                self.activitiController.stopAnimating()
            }
            print(response)
        }
        print(tempData)
    }
}


