  //
  //  AdDrop.swift
  //  BoardActive.framework
  //
  //  Created by Hunter Brennick on 7/24/18.
  //  Copyright © 2018 BoardActive. All rights reserved.
  //
  
  import Foundation
  import UIKit
  
  class AdDrop {
    
    // Meta members
    var id: Int
    var advertisementId: Int
    var dateCreated: String?       // TODO set to String?
    var dateUpdated: String?       // "
    
    // Visible members
    var title: String
    var description: String
    var category: String
    
    // Date members
    var dateStart: String?       // TODO set to String?
    var dateExpires: String?     // "
    var timeStart: String?
    var timeEnd: String?
    // TODO combine into single prop?
    
    // GET /promotions/:id members
    var isBookmarked: Bool = false
    
    // URLs
    var imageUrl: String?           // TODO set to String?
    var promoUrl: String?           // "
    var qrUrl: String?              // TODO String?
    
    var locations: Array<Location>?
    
    // view only
    var categoryColor: UIColor
    
    init(_ json: [String: Any]) {
      self.id = json["promotion_id"] as! Int
      self.advertisementId = json["advertisement_id"] as! Int
      
      // Visible members
      self.title = json["title"] as! String
      self.description = json["description"] as! String
      self.category = json["category"] as! String
      
      // Example date: "2018-09-01T00:00:00.000Z"
      self.dateCreated = json["created_at"] as? String
      self.dateUpdated = json["updated_at"] as? String
      self.dateStart = json["start_at"] as? String
      self.dateExpires = json["expire_at"] as? String
      
      self.timeStart = json["time_start"] as? String
      self.timeEnd = json["time_end"] as? String
      
      // URLs
      if let promoUrlString = json["promotion_link_url"] as? String {
        self.promoUrl = promoUrlString //URL(string: promoUrlString)
      }
      if let imageUrlString = json["image_url"] as? String {
        self.imageUrl = imageUrlString //URL(string: imageUrlString)
      }
      
      // GET /promotions/:id members
      if json["isBookmarked"] != nil {
        self.isBookmarked = json["isBookmarked"] as! Bool
      } else {
        self.isBookmarked = false
      }
      
      if let qrUrlString = json["qrUrl"] as? String {
        self.qrUrl = qrUrlString // URL(string: qrUrlString)
      }
      
      switch category {
      case "Food":
        self.categoryColor = .blue
      case "Health and Fitness":
        self.categoryColor = .green
      case "Music":
        self.categoryColor = .green
      case "Lifestyles":
        self.categoryColor = .brown
      case "Entertainment":
        self.categoryColor = .red
      default:
        self.categoryColor = .darkGray
      }
      
      if (json["locations"] != nil) {
        initLocations(locations: json["locations"] as! Array<[String: Any]>)
      }
    }
    
    public func isValidModel() -> Bool {
      return (self.imageUrl != nil)
      // TODO add more
    }
    
    public func toggleAdDropBookmark() -> Void {
      self.isBookmarked = !self.isBookmarked
    }
    
    public func getClosestLocationDirectionsSlug() -> String {
      var slug = ""
      if !(locations?.isEmpty ?? true) {
        let closestLocation = locations?.first
        slug = closestLocation?.getDirectionsSlug() ?? ""
      }
      return slug
    }
    
    private func initLocations(locations: Array<[String: Any]>) -> Void {
      var newLocations = [Location]()
      
      for location in locations {
        newLocations.append(Location(location))
      }
      
      self.locations = newLocations
    }
  }
