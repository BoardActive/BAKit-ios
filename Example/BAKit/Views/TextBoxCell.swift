//
//  TextBoxCell.swift
//  RegistrationTemplate
//
//  Created by Indrajeet Senger on 29/04/20.
//  Copyright © 2020 Indrajeet Senger. All rights reserved.
//

import UIKit

protocol TextBoxCellDelegate: class {
    func storeValues(textString: String, index: Int)
}

class TextBoxCell: UITableViewCell {

    static var identifier = "TextBoxCell"
    
    @IBOutlet weak var txtField: UITextField!
    
    weak var delegateTextfieldCell: TextBoxCellDelegate! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtField.delegate = self
        self.perform(#selector(formatCell), with: nil, afterDelay: 0.2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func formatCell() {
        addBottomBorder()
    }

    func setupCell(placeholderText: String, textValue: String, textFieldTag: Int) {
        self.txtField.text = ""
        self.txtField.tag = 101 + textFieldTag
        if (textValue.isEmpty) {
            txtField.placeholder = placeholderText
        } else {
            txtField.text = textValue
        }
        
    
//        self.txtField.isSecureTextEntry = data.isSecureText!
//        if (self.txtField.text?.isEmpty ?? true) {
//            self.txtField.setCustomTextField(txtFieldPlaceHolder: data.placeHolderText, textColor: Color.themeColor, placeHolderColor: Color.themeColor, txtFieldFont: CustomFonts.textFieldFont, isLeftPadding: true, txtFieldLeftPadding: 5.0)
//        } else {
//            self.txtField.text = data.value
//        }
    }
    
    func addBottomBorder() {
       let bottomLine = CALayer()
       bottomLine.frame = CGRect(x: 0.0, y: txtField.frame.size.height-5, width: txtField.frame.size.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        txtField.layer.addSublayer(bottomLine)
    }
}

extension TextBoxCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegateTextfieldCell?.storeValues(textString: textField.text!, index: textField.tag - 101)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        self.delegateTextfieldCell?.storeValues(textString: textField.text ?? "", index: textField.tag - 101)
        return true
    }
}
