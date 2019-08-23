//
//  CustomTableViewCell.swift
//  AdDrop
//
//  Created by Ed Salter on 8/1/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var notificationMainImageView: UIImageView!

   

    @IBOutlet weak var promoStarts: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var promoEnds: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var homepageButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    
    @IBOutlet weak var qrImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
