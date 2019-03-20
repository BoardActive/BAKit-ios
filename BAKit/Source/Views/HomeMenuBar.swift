//
//  HomeMenuBar.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/6/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

/**
 HomeMenuBar:
 
 This is the UIView for the bar at the top of BoardActive that houses the
 tabs to switch between the two primary lists: "Home" and "Saved"
 
 
 */

class HomeMenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // [START Declare constants]
  let IMG_BUNDLE = Bundle(identifier: "org.cocoapods.BAKit")
  let ID_HOME_MENU = "homeMenuBtnId"
  let TITLES_HOME_MENU = ["icons-home-48", "icons-heart-filled-48"]
  // [END]
  
  // [START Declare variables]
  var homeMenuBtnsBarView = UIView()
  var leftAnchorConstraint: NSLayoutConstraint?
  var homeController: HomeController?
  // [END]
  
  // [START Declare view elements]
  lazy var homeMenuBtnsView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()
  // [END]
  
  // [START Initialize view]
  override init(frame: CGRect) {
    super.init(frame: frame)
    homeMenuBtnsView.register(HomeMenuCell.self, forCellWithReuseIdentifier: ID_HOME_MENU)
    
    addSubviews()
    setupStyles()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // [END]
  
  private func addSubviews() {
    addSubview(homeMenuBtnsView)
    addSubview(homeMenuBtnsBarView)
  }
  
  private func setupStyles() {
    backgroundColor = .lightGray
    
    // Home Btns constraints
    addConstraintsWithFormat(format: "H:|[v0]|", views: homeMenuBtnsView)
    addConstraintsWithFormat(format: "V:|[v0]|", views: homeMenuBtnsView)
    
    // Set first Home Btn to Active
    let selectedIndexPath = NSIndexPath(item: 0, section: 0)
    homeMenuBtnsView.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: [])
    
    /* Horizontal Bar (Active Home Btn) */
    homeMenuBtnsBarView.backgroundColor = .black
    homeMenuBtnsBarView.translatesAutoresizingMaskIntoConstraints = false
    
    // Constraints
    leftAnchorConstraint = homeMenuBtnsBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
    leftAnchorConstraint?.isActive = true
    homeMenuBtnsBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    homeMenuBtnsBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
    homeMenuBtnsBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
  }
  
  // [START collectionView functions]
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // scroll to collection view container
    homeController?.scrollToHomeMenu(indexPath.item)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = homeMenuBtnsView.dequeueReusableCell(withReuseIdentifier: ID_HOME_MENU, for: indexPath) as! HomeMenuCell
    cell.imageView.image = UIImage(named: TITLES_HOME_MENU[indexPath.row], in: IMG_BUNDLE, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    cell.tintColor = .lightGray
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: frame.width/2, height: frame.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  // [END]
}
