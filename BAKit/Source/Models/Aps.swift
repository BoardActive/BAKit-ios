//
//    Ap.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct Aps{
    
    var alert : Alert!
    var badge : Int!
    var category : String!
    var contentavailable : Int!
    var mutablecontent : Int!
    var sound : String!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        if let alertData = dictionary["alert"] as? [String:Any]{
            alert = Alert(fromDictionary: alertData)
        }
        badge = dictionary["badge"] as? Int
        category = dictionary["category"] as? String
        contentavailable = dictionary["content-available"] as? Int
        mutablecontent = dictionary["mutable-content"] as? Int
        sound = dictionary["sound"] as? String
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if alert != nil{
            dictionary["alert"] = alert.toDictionary()
        }
        if badge != nil{
            dictionary["badge"] = badge
        }
        if category != nil{
            dictionary["category"] = category
        }
        if contentavailable != nil{
            dictionary["content-available"] = contentavailable
        }
        if mutablecontent != nil{
            dictionary["mutable-content"] = mutablecontent
        }
        if sound != nil{
            dictionary["sound"] = sound
        }
        return dictionary
    }
    
}
