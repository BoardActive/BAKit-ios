//
//  AdDropController.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/3/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

/**
 DetailsController:
 
 This is the UIViewController for the details view of an AdDrop. There are 2 ways to get
 to the details view of an AdDrop:
 1) Tap on an AdDrop from within the Home or Saved list views.
 2) Tap on an AdDrop's Notification within the Notification Center.
 
 
 */

class DetailsController: UIViewController {
  
  // [START Declare constants]
  let IMG_BUNDLE = Bundle(identifier: "org.cocoapods.BAKit")
  // [END]
  
  // [START Declare variables]
  var adDrop: Message? {
    didSet {
      if let a = adDrop {
        resetView(a)
      }
    }
  }
  var hasUrlPromo: Bool = false
  var hasUrlQR: Bool = false
  var hasDirections: Bool = false
  weak var feed: FeedCell?
  // [END]
  
  // [START Declare view elements]
  let viewImage: UIImageView = {
    let imageHeight = (UIScreen.main.bounds.width * (9/16)) // 16:9 aspect ratio
    let iv = UIImageView(frame: CGRect(x:0, y: 0, width: UIScreen.main.bounds.width, height: imageHeight))
    //    iv.backgroundColor = .black
    iv.contentMode = UIView.ContentMode.scaleAspectFit
    return iv
  }()
  
  lazy var buttonUrl: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-external-link-48", in: IMG_BUNDLE, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .black
    btn.addTarget(self, action: #selector(DetailsController.openUrl(_:)), for: .touchUpInside)
    return btn
  }()
  
  lazy var buttonSave: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-heart-48", in: IMG_BUNDLE, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .black
    // touch action
//    btn.addTarget(self, action: #selector(DetailsController.toggleSave(_:)), for: .touchUpInside)
    return btn
  }()
  
  let buttonRedeem: UIButton = {
    let btn = UIButton()
    let btnTitle = "redeem"
    let btnWidth = (UIScreen.main.bounds.width / 2) - 16 // 16 = padding on left
    btn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: 44)
    btn.backgroundColor = .black
    // label (title)
    btn.setTitle(btnTitle.uppercased(), for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
    // border
    btn.layer.cornerRadius = 4
    btn.layer.borderWidth = 2
    btn.layer.borderColor = UIColor.black.cgColor
    // touch action
    btn.addTarget(self, action: #selector(DetailsController.openRedeemModal(_:)), for: .touchUpInside)
    return btn
  }()
  
  let buttonDirections: UIButton = {
    let btn = UIButton(type: .custom)
    let btnTitle = "directions"
    let btnWidth = (UIScreen.main.bounds.width / 2) - 16 // 16 = padding on left
    btn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: 44)
    btn.backgroundColor = .white
    // label (title)
    btn.setTitle(btnTitle.uppercased(), for: .normal)
    btn.setTitleColor(.black, for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
    // border
    btn.layer.cornerRadius = 4
    btn.layer.borderWidth = 2
    btn.layer.borderColor = UIColor.black.cgColor
    // touch action
    btn.addTarget(self, action: #selector(DetailsController.openDirections(_:)), for: .touchUpInside)
    return btn
  }()
  
  let labelTitle: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    return lbl
  }()
  
  let labelCategory: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
    return lbl
  }()
  
  
  let labelDescription: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 16)
    return lbl
  }()
  // [END]
  
  // [START Override to force "portrait" mode programatically]
  override var shouldAutorotate: Bool {
    return false
  }
  // [END]
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // [START Initialize view on load]
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchData()
    
    setupStyles()
    addSubviews()
    setupConstraints()
  }
  // [END]
  
  // [START Get details of an AdDrop]
  private func fetchData() {
    if let id = self.adDrop?.id {
      BoardActive.client.fetchAdDropById(id)
        .done { adDrop -> Void in
          self.adDrop = adDrop // set member
          self.resetView(adDrop)
      }
    } else {
      print("[BA:DetailsController:fetchData] ERR: No AdDrop id")
    }
  }
  // [END]
  
  private func addSubviews() {
    // primary image
    view.addSubview(viewImage)
    // icon buttons
    view.addSubview(buttonUrl)
    view.addSubview(buttonSave)
    // labels
    view.addSubview(labelCategory)
    view.addSubview(labelTitle)
    view.addSubview(labelDescription)
    // buttons
    view.addSubview(buttonRedeem)
    view.addSubview(buttonDirections)
  }
  
  private func setupStyles() {
    title = "Details"
    view.backgroundColor = .white
  }
  
  private func setupConstraints() {
    // horizontal constraints
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: viewImage)
    view.addConstraintsWithFormat(format: "H:|-16-[v0(28)][v1(24)]-16-|", views: buttonSave, buttonUrl)
    view.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: labelCategory)
    view.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: labelTitle)
    view.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: labelDescription)
    
    let btnWidth = Int((UIScreen.main.bounds.width / 2) - 16) // 16 = padding on left
    view.addConstraintsWithFormat(format: "H:|-16-[v0(" + String(btnWidth) + ")]-16-|", views: buttonRedeem)
    view.addConstraintsWithFormat(format: "H:|-16-[v0(" + String(btnWidth) + ")]-16-|", views: buttonDirections)
    
    let imageHeight = Int((UIScreen.main.bounds.width * (9/16)))
    // vertical constraints
    // 52 = spacing for buttons (12 + 24 + 16)
    view.addConstraintsWithFormat(format: "V:[v0(" + String(imageHeight) + ")]-52-[v1(12)]-8-[v2(21)]-8-[v3(17)]-24-[v4(44)]-12-[v5(44)]",
                                  views: viewImage, labelCategory, labelTitle, labelDescription, buttonRedeem, buttonDirections)
    // horitzontal button alignment
    view.addConstraintsWithFormat(format: "V:|-" + String(imageHeight + 12) + "-[v0(28)]", views: buttonSave)
    view.addConstraintsWithFormat(format: "V:|-" + String(imageHeight + 12) + "-[v0(24)]", views: buttonUrl)
  }
  
  private func refreshSaveBtnState() {
    // TODO i hate this conditional...
    if adDrop?.isBookmarked != nil && (adDrop?.isBookmarked)! {
      if let img = UIImage(named: "icons-heart-filled-48")?.withRenderingMode(.alwaysTemplate) {
        buttonSave.setImage(img, for: .normal)
        buttonSave.tintColor = .red
      }
    } else {
      if let img = UIImage(named: "icons-heart-48")?.withRenderingMode(.alwaysTemplate) {
        buttonSave.setImage(img, for: .normal)
        buttonSave.tintColor = .black
      }
    }
    view.layoutIfNeeded()
  }
  
  private func resetView(_ a: Message) {
    // images
    viewImage.loadImageUsingCache(withUrl: a.imageUrl!)
    
    // labels
//    labelCategory.textColor = a.categoryColor
//    labelCategory.text = a.category.uppercased()
//    labelTitle.text = a.title
//    labelDescription.text = a.description
    
//    hasUrlPromo = !((a.promoUrl ?? "").isEmpty as Bool)
//    hasUrlQR = !((a.qrUrl ?? "").isEmpty as Bool)
//    hasDirections = !(a.locations ?? []).isEmpty as Bool
    
    // disable btns programatically
    buttonUrl.isEnabled = hasUrlPromo
    // hide btns programatically
    buttonRedeem.isHidden = !hasUrlQR
    buttonDirections.isHidden = !hasDirections
    
    // if bookmarked switch out icon from black outline to red fill
    refreshSaveBtnState()
  }
  
  
  // [START Action *touch* handlers]
  @objc func openDirections(_ sender: UIButton) {
//    let directionsSlug = self.adDrop?.getClosestLocationDirectionsSlug() ?? ""
//    let googleUrl = "comgooglemaps://" + "?daddr=" + directionsSlug
//    UIApplication.shared.open(URL(string: googleUrl)!, options: [:], completionHandler: nil)
  }
  
  @objc func openRedeemModal(_ sender: UIButton) {
    let redeemController = RedeemController()
    redeemController.modalPresentationStyle = .overCurrentContext
    redeemController.qrUrl = adDrop?.qrUrl ?? ""
    present(redeemController, animated: true, completion: nil)
  }
  
  @objc func openUrl(_ sender: UIButton) {
    if let url = URL(string: (adDrop?.promoUrl)!) {
      UIApplication.shared.open(url, options: [:])
    }
  }
  
//  @objc func toggleSave(_ sender: UIButton) {
//    adDrop?.toggleAdDropBookmark()
//    refreshSaveBtnState()
//    
//    BA.toggleAdDropBookmark(adDrop!)
//      .done { adDrop -> Void in
//        self.feed?.fetchData() // refresh parent list (TODO implement caching layer)
//      }
//      .catch { error in
//        // on fail revert
//        self.adDrop?.toggleAdDropBookmark()
//        self.refreshSaveBtnState()
//    }
//  }
  // [END]
}
