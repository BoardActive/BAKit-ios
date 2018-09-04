//
//  AdDropController.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/3/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class AdDropCardCell: UICollectionViewCell {
  let BA = BoardActive.client
  let imgBundle = Bundle(identifier: "org.cocoapods.BAKit")
  
  var adDrop: AdDrop? {
    didSet {
      if let a = adDrop {
        // images
        self.viewImage.loadImageUsingCache(withUrl: a.imageUrl!)
        
        // labels
        self.labelCategory.textColor = a.categoryColor
        self.labelCategory.text = a.category.uppercased()
        self.labelTitle.text = a.title
        self.labelDescription.text = a.description
        
        // adding "target" within saveBtn init block for some reason doesn't work, but it works here..
        // TODO probably because this is using details controller...
        buttonSave.addTarget(self, action: #selector(AdDropCardCell.toggleSave(_:)), for: .touchUpInside)
        
        // if bookmarked switch out icon from black outline to red fill
        refreshSaveBtnState()
      }
    }
  }
  
  let viewImage: UIImageView = {
    let imageHeight = (UIScreen.main.bounds.width * (9/16)) // 16:9 aspect ratio, 32 = spacing
    let iv = UIImageView(frame: CGRect(x:0, y: 0, width: UIScreen.main.bounds.width, height: imageHeight))
    iv.contentMode = UIViewContentMode.scaleAspectFit
    return iv
  }()
  
  lazy var buttonSave: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-heart-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .black
    return btn
  }()
  
  let labelCategory: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
    return lbl
  }()
  
  let labelTitle: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
    return lbl
  }()
  
  let labelDescription: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 14)
    return lbl
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubviews()
    setupStyles()
  }
  
  private func addSubviews() {
    addSubview(viewImage)
    addSubview(buttonSave)
    addSubview(labelCategory)
    addSubview(labelTitle)
    addSubview(labelDescription)
    
    setupLayouts()
  }
  
  private func refreshSaveBtnState() {
    if adDrop?.isBookmarked != nil && (adDrop?.isBookmarked)! {
      if let img = UIImage(named: "icons-heart-filled-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
        buttonSave.setImage(img, for: .normal)
        buttonSave.tintColor = .red
      }
    } else {
      if let img = UIImage(named: "icons-heart-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
        buttonSave.setImage(img, for: .normal)
        buttonSave.tintColor = .black
      }
    }
    // update view on next cycle
    layoutIfNeeded()
  }
  
  private func setupStyles() {
    backgroundColor = .white
    
    // border
    //    viewImage.layer.cornerRadius = 6
    //    viewImage.layer.borderWidth = 1.0
    //    viewImage.layer.borderColor = UIColor.clear.cgColor
    
    // shadow
    //    layer.shadowColor = UIColor.gray.cgColor
    //    layer.shadowOffset = CGSize(width: 0, height: 2.0)
    //    layer.shadowRadius = 2.0
    //    layer.shadowOpacity = 0.5
    //    layer.masksToBounds = false
    //    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
  }
  
  private func setupLayouts() {
    // horizontal constraints
    addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: viewImage)
    addConstraintsWithFormat(format: "H:|-16-[v0(28)]", views: buttonSave)
    addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: labelCategory)
    addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: labelTitle)
    addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: labelDescription)
    
    // vertical constraints
    let imageHeight = Int(((UIScreen.main.bounds.width) * (9/16)))
    addConstraintsWithFormat(format: "V:|-16-[v0(" + String(imageHeight) + ")]-8-[v1(28)]-8-[v2(13)]-8-[v3(15)]-8-[v4(15)]-16-|",
                             views: viewImage, buttonSave, labelCategory, labelTitle, labelDescription)
  }
  
  @objc func toggleSave (_ sender: UIButton) {
    adDrop?.toggleAdDropBookmark()
    refreshSaveBtnState()
    
    BA.toggleAdDropBookmark(adDrop!)
      .catch { error in
        // revert on fail
        self.adDrop?.toggleAdDropBookmark()
        self.refreshSaveBtnState()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) has not been implemented")
  }
}
