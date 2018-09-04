//
//  AppController.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/2/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  let imgBundle = Bundle(identifier: "org.cocoapods.BAKit")
  let homeMenuBarBGMask = UIView()
  let homeMenuBarTitles = ["Home", "Saved"]
  
  let feedCellId = "feedcell"
  let savedCellId = "savedcell"
  let cardCellId = "addropcell"
  
  lazy var BA = BoardActive.client
  
  lazy var homeMenuBar: HomeMenuBar = {
    let hmb = HomeMenuBar()
    hmb.homeController = self
    return hmb
  }()
  
  lazy var buttonClose: UIBarButtonItem = {
    let img = UIImage(named: "icons-close-24", in: imgBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    let btn = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.plain, target: self, action: #selector(HomeController.hideBoardActive(_:)))
    btn.tintColor = .black
    return btn
  }()
  
  // Restricts to portrait mode
  override var shouldAutorotate: Bool {
    return false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Navigation bar default item (hide "Back")
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    navigationItem.backBarButtonItem?.tintColor = .black
    
    addSubviews()
    setupStyles()
    
    // Default feed collection view collection
    collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
    // Saved feed collection view
    collectionView?.register(SavedCell.self, forCellWithReuseIdentifier: savedCellId)
  }
  
  /* START: private functions */
  private func addSubviews() {
    view.addSubview(homeMenuBarBGMask)
    view.addSubview(homeMenuBar)
  }
  
  private func setupStyles() {
    if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.scrollDirection = .horizontal  // Make root collection views horizontally scroll
      flowLayout.minimumLineSpacing = 0         // Remove gap between collection views
    }
    
    collectionView?.backgroundColor = .white
    collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)          // Top menu is 50 px tall
    collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
    collectionView?.isPagingEnabled = true
    
    // Navigation bar styles
    navigationController?.navigationBar.isTranslucent = false
    // navigationController?.hidesBarsOnSwipe = true // TODO animation that hides top bar on scroll down
    
    // Navigation bar header label
    let labelNav = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
    labelNav.text = "Home"
    labelNav.textColor = .black
    labelNav.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
    navigationItem.titleView = labelNav
    navigationItem.rightBarButtonItem = buttonClose
    
    // Home menu bar mask
    homeMenuBarBGMask.backgroundColor = .white   // mask to help animation when scroll occurs and top menu is hidden
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: homeMenuBarBGMask)
    view.addConstraintsWithFormat(format: "V:[v0(50)]", views: homeMenuBarBGMask)
    
    // Home menu bar
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: homeMenuBar)
    view.addConstraintsWithFormat(format: "V:[v0(50)]", views: homeMenuBar)
    homeMenuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
  }
  
  private func setHomeMenuBarTitleByIndex(_ index: Int) {
    if let titleLabel = navigationItem.titleView as? UILabel {
      titleLabel.text = homeMenuBarTitles[index]
    }
  }
  /* END: private functions */
  
  /* START: public functions */
  public func scrollToHomeMenu(_ homeMenuIndex: Int) {
    let indexPath = IndexPath(item: homeMenuIndex, section: 0)
    collectionView?.scrollToItem(at: indexPath, at: [], animated: true)   // scroll bar to new location
    setHomeMenuBarTitleByIndex(homeMenuIndex)                             // update home menu bar title
  }
  /* END: public functions */
  
  /* START: collectionView functions */
  override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let screenWidth = view.frame.width
    let screenOffset = targetContentOffset.pointee.x
    let index = (screenOffset / screenWidth)
    let indexPath = IndexPath(item: Int(index), section: 0)
    
    setHomeMenuBarTitleByIndex(Int(index))  // update home menu bar title
    homeMenuBar.homeMenuBtnsView.selectItem(at: indexPath, animated: true, scrollPosition: [])
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    homeMenuBar.leftAnchorConstraint?.constant = (scrollView.contentOffset.x / 2)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.item == 0 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as! FeedCell
      cell.navCtrl = navigationController
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: savedCellId, for: indexPath) as! SavedCell
      cell.navCtrl = navigationController
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: view.frame.height - 50) // 50 is the size of the menu bar
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  /* END: collectionView functions */
  
  @objc func hideBoardActive(_ sender: UIBarButtonItem) {
    BA.hide()
  }
}
