//
//    MessageData.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct MessageData {
    
    var email : String!
    var phoneNumber : String!
    var promoDateEnds : String!
    var promoDateStarts : String!
    var storeAddress : String!
    var title : String!
    var urlFacebook : String!
    var urlLandingPage : String!
    var urlLinkedIn : String!
    var urlQRCode : String!
    var urlTwitter : String!
    var urlYoutube : String!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        email = dictionary["email"] as? String
        phoneNumber = dictionary["phoneNumber"] as? String
        promoDateEnds = dictionary["promoDateEnds"] as? String
        promoDateStarts = dictionary["promoDateStarts"] as? String
        storeAddress = dictionary["storeAddress"] as? String
        title = dictionary["title"] as? String
        urlFacebook = dictionary["urlFacebook"] as? String
        urlLandingPage = dictionary["urlLandingPage"] as? String
        urlLinkedIn = dictionary["urlLinkedIn"] as? String
        urlQRCode = dictionary["urlQRCode"] as? String
        urlTwitter = dictionary["urlTwitter"] as? String
        urlYoutube = dictionary["urlYoutube"] as? String
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if email != nil{
            dictionary["email"] = email
        }
        if phoneNumber != nil{
            dictionary["phoneNumber"] = phoneNumber
        }
        if promoDateEnds != nil{
            dictionary["promoDateEnds"] = promoDateEnds
        }
        if promoDateStarts != nil{
            dictionary["promoDateStarts"] = promoDateStarts
        }
        if storeAddress != nil{
            dictionary["storeAddress"] = storeAddress
        }
        if title != nil{
            dictionary["title"] = title
        }
        if urlFacebook != nil{
            dictionary["urlFacebook"] = urlFacebook
        }
        if urlLandingPage != nil{
            dictionary["urlLandingPage"] = urlLandingPage
        }
        if urlLinkedIn != nil{
            dictionary["urlLinkedIn"] = urlLinkedIn
        }
        if urlQRCode != nil{
            dictionary["urlQRCode"] = urlQRCode
        }
        if urlTwitter != nil{
            dictionary["urlTwitter"] = urlTwitter
        }
        if urlYoutube != nil{
            dictionary["urlYoutube"] = urlYoutube
        }
        return dictionary
    }
    
}
