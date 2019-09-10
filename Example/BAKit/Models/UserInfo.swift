//
//  UserInfo.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import Foundation

public struct UserInfo {

	public var attributes : Attribute!
	public var dateCreated : String!
	public var deviceToken : String!
	public var email : String!
	public var webUserId : Int!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		if let attributesData = dictionary["attributes"] as? [String:Any]{
				attributes = Attribute(fromDictionary: attributesData)
			}
		dateCreated = dictionary["dateCreated"] as? String
		deviceToken = dictionary["deviceToken"] as? String
		email = dictionary["email"] as? String
		webUserId = dictionary["webUserId"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if attributes != nil{
			dictionary["attributes"] = attributes.toDictionary()
		}
		if dateCreated != nil{
			dictionary["dateCreated"] = dateCreated
		}
		if deviceToken != nil{
			dictionary["deviceToken"] = deviceToken
		}
		if email != nil{
			dictionary["email"] = email
		}
		if webUserId != nil{
			dictionary["webUserId"] = webUserId
		}
		return dictionary
	}

}
