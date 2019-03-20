//
//  SavedCell.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 8/7/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import UIKit

/**
 SavedCell:
 
 This is just like the FeedCell, but for the Saved tab's list view.
 
 
 TODO:
 SAVED_TEXT_EMPTY_STATE_TITLE be configurable by SDK
 SAVED_TEXT_EMPTY_STATE_DESCRIPTION be configurable by SDK
 Since same as feed cell, is init functions required?
 
 
 */

class SavedCell: FeedCell {
  
  // [START Declare constants]
  let SAVED_TEXT_EMPTY_STATE_TITLE: String = "Save deals you love"
  let SAVED_TEXT_EMPTY_STATE_DESCRIPTION: String = "Click the heart to make the deals you love easier to access later"
  // [END Declare constants]
  
  // [START Initialize view]
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // [END]
  
  // [START FeedCell overrides]
//  override func fetchData() {
//    BA.fetchBookmarkedAdDrops()
//      .done { adDrops -> Void in
//        self.setData(adDrops)
//      }.catch { error in
//        // on fail revert
//        self.setData([Message]())
//    }
//  }
  
  override func setEmptyStateText() {
    emptyStateTitle.text = SAVED_TEXT_EMPTY_STATE_TITLE
    emptyStateDescription.text = SAVED_TEXT_EMPTY_STATE_DESCRIPTION
  }
  // [END]
}
