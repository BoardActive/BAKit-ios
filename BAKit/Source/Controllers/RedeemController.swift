//
//  RedeemController.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/13/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class RedeemController: UIViewController {
  let imgBundle = Bundle(identifier: "org.cocoapods.BAKit")
  var qrUrl: String = ""
  
  let squareLength = Int((UIScreen.main.bounds.width) * (3/5))  // 1 of these
  let remainderLength = Int(UIScreen.main.bounds.width * (1/5)) // 2 of these L and R of image
  
  let viewBackgroundColor: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
  let viewRedeemImageBorderWidth: CGFloat = 16
  let viewRedeemImageCornerRadius: CGFloat = 8
  
  // restrict to portrait mode
  override var shouldAutorotate: Bool {
    return false
  }
  
  /*
   "Blur" effect on modal
   */
  let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
  lazy var blurView = UIVisualEffectView(effect: effect)
  
  /*
   UIImageViews
   */
  lazy var viewRedeemImage: UIImageView = {
    let iv = UIImageView(frame: CGRect(x:0, y: 0, width: (squareLength - 32), height: (squareLength - 32)))
    iv.isOpaque = false
    iv.backgroundColor = .clear
    iv.contentMode = UIViewContentMode.scaleAspectFit
    iv.addExternalBorder(borderWidth: viewRedeemImageBorderWidth, borderColor: .white, cornerRadius: viewRedeemImageCornerRadius)
    iv.layer.masksToBounds = false
    return iv
  }()
  
  /*
   UIButtons
   */
  lazy var buttonClose: UIButton = {
    let btn = UIButton()
    if let img = UIImage(named: "icons-delete-48", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
      btn.setImage(img, for: .normal)
    }
    btn.tintColor = .white
    btn.addTarget(self, action: #selector(RedeemController.close(_:)), for: .touchUpInside)
    return btn
  }()
  
  override func viewDidLoad() {
    setupStyles()
    addSubviews()
    setupConstraints()
  }
  
  private func addSubviews() {
    view.addSubview(blurView)
    view.addSubview(buttonClose)
    view.addSubview(viewRedeemImage)
  }
  
  private func setupStyles() {
    self.title = "Redeem"
    view.backgroundColor = viewBackgroundColor
    view.isOpaque = false
    blurView.frame = self.view.bounds
    viewRedeemImage.loadImageUsingCache(withUrl: qrUrl)
  }
  
  private func setupConstraints() {
    // horizontal constraints
    view.addConstraintsWithFormat(format: "H:|-16-[v0(24)]-16-|", views: buttonClose)
    view.addConstraintsWithFormat(
      format: "H:|-" + String(remainderLength + 16) + "-[v0(" + String(squareLength - 32) + ")]-" + String(remainderLength + 16) + "-|",
      views: viewRedeemImage)
    
    // vertical constraints
    view.addConstraintsWithFormat(format: "V:|-32-[v0(24)]-32-[v1(" + String(squareLength - 32) + ")]", views: buttonClose, viewRedeemImage)
  }
  
  @objc func close(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

