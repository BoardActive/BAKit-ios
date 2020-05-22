//
//  DateCell.swift
//  AdDrop
//
//  Created by Indrajeet Senger on 12/05/20.
//  Copyright © 2020 BoardActive. All rights reserved.
//

import UIKit
protocol DateCellDelegate: class {
    func storeDateValue(textdate: String, index: Int)
}

class DateCell: UITableViewCell {
    static var identifier = "DateCell"
    @IBOutlet weak var txtField: UITextField!
    var datePicker : UIDatePicker!
    weak var delegateDateCell: DateCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        txtField.delegate = self
        self.perform(#selector(formatCell), with: nil, afterDelay: 0.2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func formatCell() {
        addBottomBorder()
    }
    
    func addBottomBorder() {
       let bottomLine = CALayer()
       bottomLine.frame = CGRect(x: 0.0, y: txtField.frame.size.height-5, width: txtField.frame.size.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        txtField.layer.addSublayer(bottomLine)
    }

    
    private func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        txtField.inputView = self.datePicker

        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        txtField.text = dateFormatter1.string(from: datePicker.date)
        txtField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        txtField.resignFirstResponder()
    }

    
    func setupCell(placeholderText: String, textValue: String, textFieldTag: Int) {
        self.txtField.text = ""
        self.txtField.tag = 101 + textFieldTag
        if (textValue.isEmpty) {
            txtField.placeholder = placeholderText
        } else {
            txtField.text = textValue
        }
    }
}


extension DateCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.txtField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegateDateCell.storeDateValue(textdate: textField.text ?? "", index: textField.tag - 101)
    }
}

