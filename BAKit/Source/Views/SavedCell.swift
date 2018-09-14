//
//  SavedCell.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/7/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

class SavedCell: FeedCell {
  let SAVED_TEXT_EMPTY_STATE_TITLE: String = "Save deals you love"
  let SAVED_TEXT_EMPTY_STATE_DESCRIPTION: String = "Click the heart to make the deals you love easier to access later"
  
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
  
  override func setEmptyStateText() {
    emptyStateTitle.text = SAVED_TEXT_EMPTY_STATE_TITLE
    emptyStateDescription.text = SAVED_TEXT_EMPTY_STATE_DESCRIPTION
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
