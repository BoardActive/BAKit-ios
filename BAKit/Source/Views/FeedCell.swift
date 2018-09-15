//
//  FeedCell.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/7/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  let imgBundle = Bundle(identifier: "org.cocoapods.BAKit")
  let BA = BoardActive.client
  let ID_FEED_CELL = "addropcardcell"
  let TAG_COLLECTION_VIEW: Int = 679569
  let TAG_EMPTY_STATE_TITLE: Int = 679567
  let TAG_EMPTY_STATE_DESCRIPTION: Int = 679568
  let TEXT_EMPTY_STATE_TITLE: String = "You have 0 deals"
  let TEXT_EMPTY_STATE_DESCRIPTION: String = "Deals are tied to locations, so the more you move the more deals you get"
  
  var data = [AdDrop]()
  var hasData: Bool = false
  var hadData: Bool = false
  weak var navCtrl: UINavigationController?
  weak var homeController: HomeController?
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)   // frame = .zero because we are using constraints to specify demensions
    cv.tag = self.TAG_COLLECTION_VIEW
    cv.backgroundColor = .white
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()
  
  // TODO empty state title be configurable by SDK
  lazy var emptyStateTitle: UILabel = {
    let lbl = UILabel()
    lbl.tag = self.TAG_EMPTY_STATE_TITLE
    lbl.font = UIFont.systemFont(ofSize: 32, weight: .heavy) // with 36 line height
    return lbl
  }()
  
  // TODO empty state description be configurable by SDK
  lazy var emptyStateDescription: UILabel = {
    let lbl = UILabel()
    lbl.tag = self.TAG_EMPTY_STATE_DESCRIPTION
    lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
    lbl.numberOfLines = 2
    lbl.font = UIFont.systemFont(ofSize: 16)
    return lbl
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    fetchData()
  }
  
  func fetchData() {
    BA.fetchAdDrops()
      .done { adDrops -> Void in
        self.setData(adDrops)
      }.catch { error in
        self.setData([AdDrop]())
    }
  }
  
  func setData(_ adDrops: [AdDrop]) {
    self.hadData = !self.data.isEmpty
    self.data = adDrops
    self.hasData = !self.data.isEmpty
    
    if (!self.hasData) {
      self.showEmptyState()
    } else {
      self.hideEmptyState()
      self.collectionView.reloadData()
    }
  }
  
  func registerCollectionView() {
    // collectionView constraints
    addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
    addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
    
    // register addrop card cell with this feed's collectionView
    collectionView.register(AdDropCardCell.self, forCellWithReuseIdentifier: ID_FEED_CELL)
  }
  
  func registerEmptyState() {
    addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: emptyStateTitle)
    addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: emptyStateDescription)
    addConstraintsWithFormat(format: "V:|-48-[v0(36)]-8-[v1(50)]", views: emptyStateTitle, emptyStateDescription)
  }
  
  func removeSubview (tagNumber: Int) {
    if let viewWithTag = self.viewWithTag(tagNumber) {
      viewWithTag.removeFromSuperview()
    } else {
      // TODO, when initially an empty state, cannot collectionView because does not exist...
      print("Cannot remove subview: ", tagNumber)
    }
  }
  
  func setEmptyStateText() {
    emptyStateTitle.text = TEXT_EMPTY_STATE_TITLE
    emptyStateDescription.text = TEXT_EMPTY_STATE_DESCRIPTION
  }
  
  func showEmptyState() {
    if (self.hadData) {
      self.removeSubview(tagNumber: self.TAG_COLLECTION_VIEW)
    }
    setEmptyStateText()
    
    addSubview(emptyStateTitle)
    addSubview(emptyStateDescription)
    registerEmptyState()
  }
  
  func hideEmptyState() {
    if (!self.hadData) {
      self.removeSubview(tagNumber: self.TAG_EMPTY_STATE_TITLE)
      self.removeSubview(tagNumber: self.TAG_EMPTY_STATE_DESCRIPTION)
    }
    
    addSubview(collectionView)
    registerCollectionView()
  }
  
  // [START collectionView functions]
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailsAdDrop = self.data[indexPath.row]
    let dc = DetailsController()
    dc.feed = self
    dc.adDrop = detailsAdDrop
    navCtrl?.pushViewController(dc, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let datum = self.data[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID_FEED_CELL, for: indexPath) as! AdDropCardCell
    cell.adDrop = datum
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // AdDrop cell vertical constraints: V:|-16-[v0(" + String(imageHeight) + ")]-8-[v1(28)]-8-[v2(13)]-8-[v3(15)]-8-[v4(15)]-16-|
    let imageHeight = (frame.width) * (9 / 16) // 16 = horizontal spacing
    let height = 16 + imageHeight + 8 + 28 + 8 + 13 + 8 + 15 + 8 + 15 + 16 // vertical labels / constraints
    return CGSize(width: frame.width, height: height)
  }
  // [END collectionView functions]
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
