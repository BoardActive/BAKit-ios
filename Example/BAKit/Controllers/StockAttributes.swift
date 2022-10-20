//
//  CustomAttributesVC.swift
//  AdDrop
//
//  Created by Indrajeet Senger on 12/05/20.
//  Copyright © 2020 BoardActive. All rights reserved.
//

import UIKit
import BAKit

class StockAttributes: UIViewController {
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
                    self.arrAttributeList = self.arrAttributeList.filter { $0.isStock! == true }
                    self.getMe()
                } else {
                    self.activitiController.stopAnimating()
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
                    let attributes  = self.arrrMeList["attributes"] as! [String : Any]
                    print(attributes)
                    self.customattributes = attributes["stock"] as! [String : Any]
                    print(self.customattributes)
                   }
                self.tblContentLayout.reloadData()
                
               }
           }
       }
    
    
    fileprivate func configureNavigation() {
        self.title = "Stock Attributes"
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let btnBack = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        btnBack.setImage(UIImage(named:"back"), for: .normal)
        btnBack.tintColor = .white
        btnBack.addTarget(self, action: #selector(self.btnBack), for: .touchUpInside)
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


extension StockAttributes: UITableViewDataSource, UITableViewDelegate {
    
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
                        attributeElementObj.value = val is NSNull ? "" : "\(val)"
                    }
                    cell?.setupCell(placeholderText: attributeElementObj.placeHolder ?? "", textValue: attributeElementObj.value, textFieldTag: indexPath.row)
                    return cell!
                
                case .date:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.identifier) as? DateCell
                    cell?.delegateDateCell = self
                    if let val = customattributes[attributeElementObj.placeHolder!] {
                        attributeElementObj.value = val is NSNull ? "" : "\(val)"
                     }
                    cell?.setupCell(placeholderText: attributeElementObj.placeHolder ?? "", textValue: attributeElementObj.value, textFieldTag: indexPath.row)
                    return cell!
                
                case .boolean:
                    let cell = tableView.dequeueReusableCell(withIdentifier: RadioButtonCell.identifier) as? RadioButtonCell
                    cell?.delegateRadioButtonCell = self
                    if (attributeElementObj.placeHolder?.lowercased() == "gender") {
                        if let val = customattributes[attributeElementObj.placeHolder!] {
                                                                 print(val)
                             let s = String(describing: val)
                            cell?.setRadioCell(title: "", titleOption1: "Female", titleOption2: "Male", buttonTag: indexPath.row, value: s)
                                                                 return cell!
                                           }
                        cell?.setRadioCell(title: attributeElementObj.placeHolder ?? "", titleOption1: "Female", titleOption2: "Male", buttonTag: indexPath.row, value: attributeElementObj.value)
                    } else {
                        if let val = customattributes[attributeElementObj.placeHolder!] {
                            attributeElementObj.value = "\(val)"
                        } else {
                            attributeElementObj.value = "0"
                        }
                        if (attributeElementObj.placeHolder == "notificationPermission" || attributeElementObj.placeHolder == "locationPermission") {
                            cell?.enableDisableRadioButton(enable: false)
                                                  
                        } else {
                            cell?.enableDisableRadioButton(enable: true)
                        }

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
extension StockAttributes: TextBoxCellDelegate,DateCellDelegate,RaidoButtonCellDelegate {
    func storeValue(text: String, index: Int) {
        arrAttributeList[index].value = text
    }
    
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
       }
}


//MARK:- ButtonCellDelegate methods
extension StockAttributes: ButtonCellDelegate {
    func buttonAction(sender: UIButton) {
        var tempData = StorageObject.container.userInfo?.toDictionary()
        var dictStock: [String: Any] = [:]
        for item in arrAttributeList {
            if ((item.isStock == true) && !item.value.isEmpty) {
                if (item.type == .boolean) {
                   dictStock[item.placeHolder!] = item.value == "0" ? false : true
                   
                } else if (item.type == .double){
                   dictStock[item.placeHolder!] = Double(item.value) ?? 0.0
                                   
                } else {
                    dictStock[item.placeHolder!] = item.value
                }
            }
        }
        tempData?["attributes"] = ["stock": dictStock]
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


