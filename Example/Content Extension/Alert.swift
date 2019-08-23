//
//    Alert.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct Alert{
    
    var body : String!
    var title : String!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        body = dictionary["body"] as? String
        title = dictionary["title"] as? String
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if body != nil{
            dictionary["body"] = body
        }
        if title != nil{
            dictionary["title"] = title
        }
        return dictionary
    }
    
}
