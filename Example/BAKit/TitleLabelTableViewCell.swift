//
//  TitleLabelTableViewCell.swift
//  BAKit
//
//  Created by Ed Salter on 8/13/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class TitleLabelTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var body: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
