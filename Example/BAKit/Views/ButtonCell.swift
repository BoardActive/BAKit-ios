//
//  ButtonCell.swift
//  AdDrop
//
//  Created by Indrajeet Senger on 12/05/20.
//  Copyright © 2020 BoardActive. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate: class {
    func buttonAction(sender: UIButton)
}

class ButtonCell: UITableViewCell {
    static var identifier = "ButtonCell"
    
    @IBOutlet weak var button: UIButton!

    weak var delegateButton: ButtonCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnAction(sender: UIButton) {
        delegateButton.buttonAction(sender: sender)
    }
    
    public func setUpButton(title: String) {
        button.setTitle(title, for: .normal)
    }
    
}
