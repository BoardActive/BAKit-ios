//
//    UserInfo.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct UserInfo {
    var appId : Int!
    var appVersion : String!
    var dateCreated : String!
    var dateLastUpdated : String!
    var deviceOS : String!
    var deviceOSVersion : String!
    var deviceToken : String!
    var deviceType : AnyObject!
    var email : AnyObject!
    var guid : String!
    var id : Int!
    var inbox : Inbox!
    var webUserId : AnyObject!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        
        appId = dictionary["appId"] as? Int
        appVersion = dictionary["appVersion"] as? String
        dateCreated = dictionary["dateCreated"] as? String
        dateLastUpdated = dictionary["dateLastUpdated"] as? String
        deviceOS = dictionary["deviceOS"] as? String
        deviceOSVersion = dictionary["deviceOSVersion"] as? String
        deviceToken = dictionary["deviceToken"] as? String
        deviceType = dictionary["deviceType"] as? AnyObject
        email = dictionary["email"] as? AnyObject
        guid = dictionary["guid"] as? String
        id = dictionary["id"] as? Int
        if let inboxData = dictionary["inbox"] as? [String:Any]{
            inbox = Inbox(fromDictionary: inboxData)
        }
        webUserId = dictionary["webUserId"] as? AnyObject
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if appId != nil{
            dictionary["appId"] = appId
        }
        if appVersion != nil{
            dictionary["appVersion"] = appVersion
        }
        if dateCreated != nil{
            dictionary["dateCreated"] = dateCreated
        }
        if dateLastUpdated != nil{
            dictionary["dateLastUpdated"] = dateLastUpdated
        }
        if deviceOS != nil{
            dictionary["deviceOS"] = deviceOS
        }
        if deviceOSVersion != nil{
            dictionary["deviceOSVersion"] = deviceOSVersion
        }
        if deviceToken != nil{
            dictionary["deviceToken"] = deviceToken
        }
        if deviceType != nil{
            dictionary["deviceType"] = deviceType
        }
        if email != nil{
            dictionary["email"] = email
        }
        if guid != nil{
            dictionary["guid"] = guid
        }
        if id != nil{
            dictionary["id"] = id
        }
        if inbox != nil{
            dictionary["inbox"] = inbox.toDictionary()
        }
        if webUserId != nil{
            dictionary["webUserId"] = webUserId
        }
        return dictionary
    }
    
}
