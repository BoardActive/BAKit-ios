//
//  HomeMenuCell.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/6/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

/**
 HomeMenuCell:
 
 This is the UIViewCell for the tabs within the HomeMenuBar. There are 2 total: one for "Home" (which
 is all AdDrops) and second for "Saved" (which is only AdDrops that have isBookmarked = true)
 
 
 */

class HomeMenuCell: UICollectionViewCell {
  
  // [START Declare view elements]
  let imageView: UIImageView = {
    let imgBundle = Bundle(identifier: "org.cocoapods.BAKit")
    let iv = UIImageView()
    iv.image = UIImage(named: "icons-heart-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    iv.tintColor = .lightGray
    return iv
  }()
  // [END]
  
  // [START Declare variables]
  override var isHighlighted: Bool {
    didSet {
      imageView.tintColor = isHighlighted ? .darkGray : .lightGray
    }
  }
  
  override var isSelected: Bool {
    didSet {
      imageView.tintColor = isSelected ? .black : .lightGray
    }
  }
  // [END]
  
  
  // [START Initialize view]
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubviews()
    setupStyles()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // [END]
  private func addSubviews() {
    addSubview(imageView)
  }
  
  private func setupStyles() {
    addConstraintsWithFormat(format: "H:[v0(24)]", views: imageView)
    addConstraintsWithFormat(format: "V:[v0(24)]", views: imageView)
    
    // align center X, align center Y
    addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
  }
}
