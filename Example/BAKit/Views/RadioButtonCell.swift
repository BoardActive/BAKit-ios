//
//  RadioButtonCell.swift
//  AdDrop
//
//  Created by Indrajeet Senger on 12/05/20.
//  Copyright © 2020 BoardActive. All rights reserved.
//

import UIKit

protocol RaidoButtonCellDelegate: class {
    func RadioButtonValue(textradio: String, index: Int)
}

class RadioButtonCell: UITableViewCell {
    static var identifier = "RadioButtonCell"
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnOption1: UIButton!
    @IBOutlet weak var btnOption2: UIButton!
    
    weak var delegateRadioButtonCell: RaidoButtonCellDelegate!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRadioCell(title: String, titleOption1: String, titleOption2: String, buttonTag: Int, value: String) {
        lblTitle.text = title
        btnOption1.isSelected = false
        btnOption2.isSelected = false
        btnOption1.tag = buttonTag + 101
        btnOption2.tag = buttonTag + 201
        
        if (value == "0") {
            btnOption1.isSelected = true
            btnOption2.isSelected = false
        } else if (value == "1") {
            btnOption1.isSelected = false
            btnOption2.isSelected = true
        }
        else if (value == "") {
            btnOption1.isSelected = true
            btnOption2.isSelected = false
        }else {
            btnOption1.isSelected = false
            btnOption2.isSelected = false
        }

        
        btnOption1.setTitle("  \(titleOption1)", for: .normal)
        btnOption2.setTitle("  \(titleOption2)", for: .normal)
        btnOption1.setTitle("  \(titleOption1)", for: .selected)
        btnOption2.setTitle("  \(titleOption2)", for: .selected)
    }
    
    @IBAction func btnOption1Action(sender: UIButton) {
        if (btnOption1.isSelected) {return}
        btnOption2.isSelected = false
        sender.isSelected = !sender.isSelected
        self.delegateRadioButtonCell.RadioButtonValue(textradio: "0", index: sender.tag - 101)
    }
    
    @IBAction func btnOption2Action(sender: UIButton) {
        if (btnOption2.isSelected) {return}
        btnOption1.isSelected = false
        sender.isSelected = !sender.isSelected
        self.delegateRadioButtonCell.RadioButtonValue(textradio: "1", index: sender.tag - 201)
    }
}
