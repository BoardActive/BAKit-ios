//
//  SavedCell.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/7/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class SavedCell: FeedCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func fetchData() {
    BA.fetchBookmarkedAdDrops()
      .done { adDrops -> Void in
        self.setData(adDrops)
      }.catch { error in
        // on fail revert
        self.setData([AdDrop]())
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
