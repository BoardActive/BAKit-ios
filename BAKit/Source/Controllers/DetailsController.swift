//
//  AdDropController.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/3/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {
  let imgBundle = Bundle(identifier: "org.cocoapods.BAKit")
  let BA = BoardActive.client
  
  weak var feed: FeedCell?
  var adDrop: AdDrop? {
    didSet {
      if let a = adDrop {
        resetView(a)
      }
    }
  }
  var hasUrlPromo: Bool = false
  var hasUrlQR: Bool = false
  var hasDirections: Bool = false
  
  // restrict to portrait mode
  override var shouldAutorotate: Bool {
    return false
  }
  
  private func resetView(_ a: AdDrop) {
    // images
    viewImage.loadImageUsingCache(withUrl: a.imageUrl!)
    
    // labels
    labelCategory.textColor = a.categoryColor
    labelCategory.text = a.category.uppercased()
    labelTitle.text = a.title
    labelDescription.text = a.description
    
    hasUrlPromo = !((a.promoUrl ?? "").isEmpty as Bool)
    hasUrlQR = !((a.qrUrl ?? "").isEmpty as Bool)
    hasDirections = !(a.locations ?? []).isEmpty as Bool
    
    // disable btns programatically
    buttonUrl.isEnabled = hasUrlPromo
    // hide btns programatically
    buttonRedeem.isHidden = !hasUrlQR
    buttonDirections.isHidden = !hasDirections
    
    // if bookmarked switch out icon from black outline to red fill
    refreshSaveBtnState()
  }
  
  /*
   UIImageViews
   */
  let viewImage: UIImageView = {
    let imageHeight = (UIScreen.main.bounds.width * (9/16)) // 16:9 aspect ratio
    let iv = UIImageView(frame: CGRect(x:0, y: 0, width: UIScreen.main.bounds.width, height: imageHeight))
    //    iv.backgroundColor = .black
    iv.contentMode = UIViewContentMode.scaleAspectFit
    return iv
  }()
  
  /*
   UIButtons
   */
  lazy var buttonUrl: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-external-link-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .black
    btn.addTarget(self, action: #selector(DetailsController.openUrl(_:)), for: .touchUpInside)
    return btn
  }()
  
  lazy var buttonSave: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-heart-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .black
    // touch action
    btn.addTarget(self, action: #selector(DetailsController.toggleSave(_:)), for: .touchUpInside)
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
  
  /*
   UILabels
   */
  let labelCategory: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
    return lbl
  }()
  
  let labelTitle: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    return lbl
  }()
  
  let labelDescription: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 16)
    return lbl
  }()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchData()
    
    setupStyles()
    addSubviews()
    setupConstraints()
  }
  
  func fetchData() {
    if let id = self.adDrop?.id {
      _ = BA.fetchAdDropById(id)
        .done { adDrop -> Void in
          self.adDrop = adDrop // set member
          self.resetView(adDrop)
      }
    } else {
      print("[BA:DetailsController:fetchData] ERR: No AdDrop id")
    }
  }
  
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
  
  /*
   Button *touch* handlers
   */
  
  // buttonSave
  @objc func toggleSave(_ sender: UIButton) {
    adDrop?.toggleAdDropBookmark()
    refreshSaveBtnState()
    
    BA.toggleAdDropBookmark(adDrop!)
      .done { adDrop -> Void in
        self.feed?.fetchData() // refresh parent list (TODO probably not the most efficient
      }
      .catch { error in
        // on fail revert
        self.adDrop?.toggleAdDropBookmark()
        self.refreshSaveBtnState()
    }
  }
  
  // buttonUrl
  @objc func openUrl(_ sender: UIButton) {
    if let url = URL(string: (adDrop?.promoUrl)!) {
      UIApplication.shared.open(url, options: [:])
    }
  }
  
  // buttonRedeem
  @objc func openRedeemModal(_ sender: UIButton) {
    let redeemController = RedeemController()
    redeemController.modalPresentationStyle = .overCurrentContext
    redeemController.qrUrl = adDrop?.qrUrl ?? ""
    present(redeemController, animated: true, completion: nil)
  }
  
  @objc func openDirections(_ sender: UIButton) {
    let directionsSlug = self.adDrop?.getClosestLocationDirectionsSlug() ?? ""
    let googleUrl = "comgooglemaps://" + "?daddr=" + directionsSlug
    UIApplication.shared.open(URL(string: googleUrl)!, options: [:], completionHandler: nil)
  }
}
