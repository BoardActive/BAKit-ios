//
//	CreatedBy.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct CreatedBy{

	var avatarUrl : AnyObject!
	var dateCreated : String!
	var dateDeleted : AnyObject!
	var dateLastUpdated : String!
	var email : String!
	var firstName : AnyObject!
	var id : Int!
	var inbox : Inbox!
	var isApprovedByDoug : Bool!
	var isClaimed : Bool!
	var isCompliant : Bool!
	var isRejectedByDoug : Bool!
	var isVerified : Bool!
	var lastName : AnyObject!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		avatarUrl = dictionary["avatarUrl"] as? AnyObject
		dateCreated = dictionary["dateCreated"] as? String
		dateDeleted = dictionary["dateDeleted"] as? AnyObject
		dateLastUpdated = dictionary["dateLastUpdated"] as? String
		email = dictionary["email"] as? String
		firstName = dictionary["firstName"] as? AnyObject
		id = dictionary["id"] as? Int
		if let inboxData = dictionary["inbox"] as? [String:Any]{
				inbox = Inbox(fromDictionary: inboxData)
			}
		isApprovedByDoug = dictionary["isApprovedByDoug"] as? Bool
		isClaimed = dictionary["isClaimed"] as? Bool
		isCompliant = dictionary["isCompliant"] as? Bool
		isRejectedByDoug = dictionary["isRejectedByDoug"] as? Bool
		isVerified = dictionary["isVerified"] as? Bool
		lastName = dictionary["lastName"] as? AnyObject
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if avatarUrl != nil{
			dictionary["avatarUrl"] = avatarUrl
		}
		if dateCreated != nil{
			dictionary["dateCreated"] = dateCreated
		}
		if dateDeleted != nil{
			dictionary["dateDeleted"] = dateDeleted
		}
		if dateLastUpdated != nil{
			dictionary["dateLastUpdated"] = dateLastUpdated
		}
		if email != nil{
			dictionary["email"] = email
		}
		if firstName != nil{
			dictionary["firstName"] = firstName
		}
		if id != nil{
			dictionary["id"] = id
		}
		if inbox != nil{
			dictionary["inbox"] = inbox.toDictionary()
		}
		if isApprovedByDoug != nil{
			dictionary["isApprovedByDoug"] = isApprovedByDoug
		}
		if isClaimed != nil{
			dictionary["isClaimed"] = isClaimed
		}
		if isCompliant != nil{
			dictionary["isCompliant"] = isCompliant
		}
		if isRejectedByDoug != nil{
			dictionary["isRejectedByDoug"] = isRejectedByDoug
		}
		if isVerified != nil{
			dictionary["isVerified"] = isVerified
		}
		if lastName != nil{
			dictionary["lastName"] = lastName
		}
		return dictionary
	}

}
