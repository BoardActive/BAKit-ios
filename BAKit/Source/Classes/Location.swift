//
//  Location.swift
//  BoardActive.framework
//
//  Created by Hunter Brennick on 7/24/18.
//  Copyright © 2018 BoardActive. All rights reserved.
//

import Foundation

class Location {
  // Meta members
  var id: Int
  var dateCreated: String?   // TODO should be String?
  var dateUpdated: String?   // "
  
//  // Visible members
//  var addressOne: String?
//  var addressTwo: String?
//  var city: String?
//  var state: String?
//  var zipCode: String?      // TODO should be Int?
//  var country: String?
//  
  var latitude: String      // TODO should be float?
  var longitude: String     // "
//  
  init(_ json: [String: Any]) {
    // Meta members
    self.id = json["id"] as! Int
    
    self.dateCreated = json["created_at"] as? String
    self.dateUpdated = json["updated_at"] as? String
    
//    // Physical address
//    self.addressOne = json["address_one"] as? String
//    self.addressTwo = json["address_two"] as? String
//    self.city = json["city"] as? String
//    self.state = json["state"] as? String
//    self.zipCode = json["zip_code"] as? String
//    self.country = json["country"] as? String
    
    // Coordinates of address
    self.latitude = json["latitude"] as! String
    self.longitude = json["longitude"] as! String
  }
  
  // preference = address, alternate = latLng
//  func getDirectionsSlug() -> String {
//    var directionsSlug = getAddressSlug()
//    if (directionsSlug.isEmpty) {
//      directionsSlug = getLatLngSlug()
//    }
//    return directionsSlug
//  }
  
  /*
   Returns lat long formatted string for Google map's api
   EXAMPLE: 42.585444,13.007813
   */
  func getLatLngSlug() -> String {
    return self.latitude + "," + self.longitude
  }
  
  /*
   Returns address formatted string for Google map's api
   EXAMPLE: John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York
   AddressOne,+AddressTwo,+City,+State,+Country
   */
//  func getAddressSlug() -> String {
//    var addressSlug = ""
//    let pAddressOne = self.addressOne?.replacingOccurrences(of: " ", with: "+")
//    let pAddressTwo = self.addressTwo?.replacingOccurrences(of: " ", with: "+")
//    let pCity = self.city?.replacingOccurrences(of: " ", with: "+")
//    let pState = self.state?.replacingOccurrences(of: " ", with: "+")
//    let pCountry = self.country?.replacingOccurrences(of: " ", with: "+")
//    
//    if (!(pAddressOne ?? "").isEmpty) {
//      addressSlug = addressSlug + pAddressOne!
//    }
//    if (!(pAddressTwo ?? "").isEmpty) {
//      addressSlug = addressSlug + ",+" + pAddressTwo!
//    }
//    if (!(pCity ?? "").isEmpty) {
//      addressSlug = addressSlug + ",+" + pCity!
//    }
//    if (!(pState ?? "").isEmpty) {
//      addressSlug = addressSlug + ",+" + pState!
//    }
//    if (!(pCountry ?? "").isEmpty) {
//      addressSlug = addressSlug + ",+" + pCountry!
//    }
//    
//    return addressSlug
//  }
}
