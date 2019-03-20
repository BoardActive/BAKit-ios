//
//	RootClass.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class MePayload : NSObject, NSCoding{

	var appId : Int!
	var appVersion : String!
	var dateCreated : String!
	var dateLastUpdated : String!
	var deviceOS : String!
	var deviceOSVersion : String!
	var deviceToken : String!
	var email : String!
	var guid : String!
	var id : Int!
	var inbox : Inbox!
	var webUserId : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		appId = json["appId"].intValue
		appVersion = json["appVersion"].stringValue
		dateCreated = json["dateCreated"].stringValue
		dateLastUpdated = json["dateLastUpdated"].stringValue
		deviceOS = json["deviceOS"].stringValue
		deviceOSVersion = json["deviceOSVersion"].stringValue
		deviceToken = json["deviceToken"].stringValue
		email = json["email"].stringValue
		guid = json["guid"].stringValue
		id = json["id"].intValue
		let inboxJson = json["inbox"]
		if !inboxJson.isEmpty{
			inbox = Inbox(fromJson: inboxJson)
		}
		webUserId = json["webUserId"].stringValue
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

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         appId = aDecoder.decodeObject(forKey: "appId") as? Int
         appVersion = aDecoder.decodeObject(forKey: "appVersion") as? String
         dateCreated = aDecoder.decodeObject(forKey: "dateCreated") as? String
         dateLastUpdated = aDecoder.decodeObject(forKey: "dateLastUpdated") as? String
         deviceOS = aDecoder.decodeObject(forKey: "deviceOS") as? String
         deviceOSVersion = aDecoder.decodeObject(forKey: "deviceOSVersion") as? String
         deviceToken = aDecoder.decodeObject(forKey: "deviceToken") as? String
         email = aDecoder.decodeObject(forKey: "email") as? String
         guid = aDecoder.decodeObject(forKey: "guid") as? String
         id = aDecoder.decodeObject(forKey: "id") as? Int
         inbox = aDecoder.decodeObject(forKey: "inbox") as? Inbox
         webUserId = aDecoder.decodeObject(forKey: "webUserId") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if appId != nil{
			aCoder.encode(appId, forKey: "appId")
		}
		if appVersion != nil{
			aCoder.encode(appVersion, forKey: "appVersion")
		}
		if dateCreated != nil{
			aCoder.encode(dateCreated, forKey: "dateCreated")
		}
		if dateLastUpdated != nil{
			aCoder.encode(dateLastUpdated, forKey: "dateLastUpdated")
		}
		if deviceOS != nil{
			aCoder.encode(deviceOS, forKey: "deviceOS")
		}
		if deviceOSVersion != nil{
			aCoder.encode(deviceOSVersion, forKey: "deviceOSVersion")
		}
		if deviceToken != nil{
			aCoder.encode(deviceToken, forKey: "deviceToken")
		}
		if email != nil{
			aCoder.encode(email, forKey: "email")
		}
		if guid != nil{
			aCoder.encode(guid, forKey: "guid")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if inbox != nil{
			aCoder.encode(inbox, forKey: "inbox")
		}
		if webUserId != nil{
			aCoder.encode(webUserId, forKey: "webUserId")
		}

	}

}
