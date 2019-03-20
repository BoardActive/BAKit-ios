//
//  RedeemController.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/13/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

/**
 RedeemController:
 
 This is the UIViewController for an AdDrop's "REDEEM" functionality. The view centers
 an image, which is fetched via an AdDrop's "qrUrl" property.
 
 
 */

class RedeemController: UIViewController {
  
  // [START Declare constants]
  let IMG_BUNDLE = Bundle(identifier: "org.cocoapods.BAKit")
  let VIEW_BG_COLOR: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
  let VIEW_IMG_BORDER_WIDTH: CGFloat = 16
  let VIEW_IMG_CORNER_RADIUS: CGFloat = 8
  let LENGTH_SQUARE = Int((UIScreen.main.bounds.width) * (3/5))  // 1 of these
  let LENGTH_REMAINDER = Int(UIScreen.main.bounds.width * (1/5)) // 2 of these L and R of image
  // [END]
  
  // [START Declare variables]
  var qrUrl: String = ""
  // [END]
  
  // [START Override to force "portrait" mode programatically]
  override var shouldAutorotate: Bool {
    return false
  }
  // [END]
  
  // [START Declare "blur" effect on modal declaration]
    let effect = UIBlurEffect(style: UIBlurEffect.Style.light)
  lazy var blurView = UIVisualEffectView(effect: effect)
  // [END]
  
  // [START Declare view elements]
  lazy var viewRedeemImage: UIImageView = {
    let iv = UIImageView(frame: CGRect(x:0, y: 0, width: (LENGTH_SQUARE - 32), height: (LENGTH_SQUARE - 32)))
    iv.isOpaque = false
    iv.backgroundColor = .clear
    iv.contentMode = UIView.ContentMode.scaleAspectFit
    iv.addExternalBorder(borderWidth: VIEW_IMG_BORDER_WIDTH, borderColor: .white, cornerRadius: VIEW_IMG_CORNER_RADIUS)
    iv.layer.masksToBounds = false
    return iv
  }()
  
  lazy var buttonClose: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-delete-48", in: IMG_BUNDLE, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .white
    btn.addTarget(self, action: #selector(RedeemController.close(_:)), for: .touchUpInside)
    return btn
  }()
  // [END]
  
  // [START Initialize view on load]
  override func viewDidLoad() {
    setupStyles()
    addSubviews()
    setupConstraints()
  }
  // [END]
  
  private func addSubviews() {
    view.addSubview(blurView)
    view.addSubview(buttonClose)
    view.addSubview(viewRedeemImage)
  }
  
  private func setupStyles() {
    self.title = "Redeem"
    view.backgroundColor = VIEW_BG_COLOR
    view.isOpaque = false
    blurView.frame = self.view.bounds
    viewRedeemImage.loadImageUsingCache(withUrl: qrUrl)
  }
  
  private func setupConstraints() {
    // horizontal constraints
    view.addConstraintsWithFormat(format: "H:|-16-[v0(24)]-16-|", views: buttonClose)
    view.addConstraintsWithFormat(
      format: "H:|-" + String(LENGTH_REMAINDER + 16) + "-[v0(" + String(LENGTH_SQUARE - 32) + ")]-" + String(LENGTH_REMAINDER + 16) + "-|",
      views: viewRedeemImage)
    
    // vertical constraints
    view.addConstraintsWithFormat(format: "V:|-32-[v0(24)]-32-[v1(" + String(LENGTH_SQUARE - 32) + ")]", views: buttonClose, viewRedeemImage)
  }
  
  // [START Action *touch* handlers]
  @objc func close(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  // [END]
}

