//
//	Company.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Company{

	var hasRequested : Bool!
	var intent : String!
	var name : String!
	var phone : String!
	var size : String!
	var url : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		hasRequested = dictionary["hasRequested"] as? Bool
		intent = dictionary["intent"] as? String
		name = dictionary["name"] as? String
		phone = dictionary["phone"] as? String
		size = dictionary["size"] as? String
		url = dictionary["url"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if hasRequested != nil{
			dictionary["hasRequested"] = hasRequested
		}
		if intent != nil{
			dictionary["intent"] = intent
		}
		if name != nil{
			dictionary["name"] = name
		}
		if phone != nil{
			dictionary["phone"] = phone
		}
		if size != nil{
			dictionary["size"] = size
		}
		if url != nil{
			dictionary["url"] = url
		}
		return dictionary
	}

}