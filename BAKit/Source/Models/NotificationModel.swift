//
//    RootClass.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct NotificationModel {
    
    var aps : Aps!
    var body : String!
    var dateCreated : String!
    var dateLastUpdated : String!
    var gcmmessageId : String!
    var googlecae : String!
    var imageUrl : String!
    var isTestMessage : String!
    var messageData : MessageData!
    var messageId : String!
    var notificationId : String!
    var tap : Bool!
    var title : String!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String:Any]){
        if let apsData = dictionary["aps"] as? [String:Any]{
            aps = Aps(fromDictionary: apsData)
        }
        body = dictionary["body"] as? String
        dateCreated = dictionary["dateCreated"] as? String
        dateLastUpdated = dictionary["dateLastUpdated"] as? String
        gcmmessageId = dictionary["gcm.message_id"] as? String
        googlecae = dictionary["google.c.a.e"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        isTestMessage = dictionary["isTestMessage"] as? String
        if let messageDataData = dictionary["messageData"] as? [String:Any]{
            messageData = MessageData(fromDictionary: messageDataData)
        }
        messageId = dictionary["messageId"] as? String
        notificationId = dictionary["notificationId"] as? String
        tap = dictionary["tap"] as? Bool
        title = dictionary["title"] as? String
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    public func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if aps != nil{
            dictionary["aps"] = aps.toDictionary()
        }
        if body != nil{
            dictionary["body"] = body
        }
        if dateCreated != nil{
            dictionary["dateCreated"] = dateCreated
        }
        if dateLastUpdated != nil{
            dictionary["dateLastUpdated"] = dateLastUpdated
        }
        if gcmmessageId != nil{
            dictionary["gcm.message_id"] = gcmmessageId
        }
        if googlecae != nil{
            dictionary["google.c.a.e"] = googlecae
        }
        if imageUrl != nil{
            dictionary["imageUrl"] = imageUrl
        }
        if isTestMessage != nil{
            dictionary["isTestMessage"] = isTestMessage
        }
        if messageData != nil{
            dictionary["messageData"] = messageData.toDictionary()
        }
        if messageId != nil{
            dictionary["messageId"] = messageId
        }
        if notificationId != nil{
            dictionary["notificationId"] = notificationId
        }
        if tap != nil{
            dictionary["tap"] = tap
        }
        if title != nil{
            dictionary["title"] = title
        }
        return dictionary
    }
    
}
