//
//	User.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct User{

	var email : String!
	var firstName : AnyObject!
	var id : Int!
	var inbox : Inbox!
	var isClaimed : Bool!
	var isCompliant : Bool!
	var isVerified : Bool!
	var lastName : AnyObject!
	var role : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		email = dictionary["email"] as? String
		firstName = dictionary["firstName"] as? AnyObject
		id = dictionary["id"] as? Int
		if let inboxData = dictionary["inbox"] as? [String:Any]{
				inbox = Inbox(fromDictionary: inboxData)
			}
		isClaimed = dictionary["isClaimed"] as? Bool
		isCompliant = dictionary["isCompliant"] as? Bool
		isVerified = dictionary["isVerified"] as? Bool
		lastName = dictionary["lastName"] as? AnyObject
		role = dictionary["role"] as? String
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
		if firstName != nil{
			dictionary["firstName"] = firstName
		}
		if id != nil{
			dictionary["id"] = id
		}
		if inbox != nil{
			dictionary["inbox"] = inbox.toDictionary()
		}
		if isClaimed != nil{
			dictionary["isClaimed"] = isClaimed
		}
		if isCompliant != nil{
			dictionary["isCompliant"] = isCompliant
		}
		if isVerified != nil{
			dictionary["isVerified"] = isVerified
		}
		if lastName != nil{
			dictionary["lastName"] = lastName
		}
		if role != nil{
			dictionary["role"] = role
		}
		return dictionary
	}

}
