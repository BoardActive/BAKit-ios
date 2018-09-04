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
  let feedCellId = "addropcardcell"
  var data = [AdDrop]()
  
  weak var navCtrl: UINavigationController?
  weak var homeController: HomeController?
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)   // frame = .zero because we are using constraints to specify demensions
    cv.backgroundColor = .white
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addViews()
    setupViews()
  }
  
  private func addViews() {
    addSubview(collectionView)
  }
  
  private func setupViews() {
    fetchData()
    
    // collectionView constraints
    addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
    addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
    
    // register addrop card cell with this feed's collectionView
    collectionView.register(AdDropCardCell.self, forCellWithReuseIdentifier: feedCellId)
  }
  
  func setData(_ adDrops: [AdDrop]) {
    self.data = adDrops
    self.collectionView.reloadData()
  }
  
  func fetchData() {
    BA.fetchAdDrops()
      .done { adDrops -> Void in
        self.setData(adDrops)
      }.catch { error in
        self.setData([AdDrop]())
    }
  }
  
  /* START: collectionView functions */
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as! AdDropCardCell
    cell.adDrop = datum
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // AdDrop cell vertical constraints: V:|-16-[v0(" + String(imageHeight) + ")]-8-[v1(28)]-8-[v2(13)]-8-[v3(15)]-8-[v4(15)]-16-|
    let imageHeight = (frame.width) * (9 / 16) // 16 = horizontal spacing
    let height = 16 + imageHeight + 8 + 28 + 8 + 13 + 8 + 15 + 8 + 15 + 16 // vertical labels / constraints
    return CGSize(width: frame.width, height: height)
  }
  /* END: collectionView functions */
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
