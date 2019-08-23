//
//	App.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct App {

	var createdBy : CreatedBy!
	var dateCreated : String!
	var dateLastUpdated : String!
	var guid : String!
	var iconUrl : AnyObject!
	public var id : Int64!
	var inbox : Inbox!
	var itunesUrl : AnyObject!
	var lastUpdatedBy : CreatedBy!
	public var name : String!
	var playStoreUrl : AnyObject!
	var users : [User]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		if let createdByData = dictionary["createdBy"] as? [String:Any]{
				createdBy = CreatedBy(fromDictionary: createdByData)
			}
		dateCreated = dictionary["dateCreated"] as? String
		dateLastUpdated = dictionary["dateLastUpdated"] as? String
		guid = dictionary["guid"] as? String
		iconUrl = dictionary["iconUrl"] as? AnyObject
		id = dictionary["id"] as? Int64
		if let inboxData = dictionary["inbox"] as? [String:Any]{
				inbox = Inbox(fromDictionary: inboxData)
			}
		itunesUrl = dictionary["itunesUrl"] as? AnyObject
		if let lastUpdatedByData = dictionary["lastUpdatedBy"] as? [String:Any]{
				lastUpdatedBy = CreatedBy(fromDictionary: lastUpdatedByData)
			}
		name = dictionary["name"] as? String
		playStoreUrl = dictionary["playStoreUrl"] as? AnyObject
		users = [User]()
		if let usersArray = dictionary["users"] as? [[String:Any]]{
			for dic in usersArray{
				let value = User(fromDictionary: dic)
				users.append(value)
			}
		}
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if createdBy != nil{
			dictionary["createdBy"] = createdBy.toDictionary()
		}
		if dateCreated != nil{
			dictionary["dateCreated"] = dateCreated
		}
		if dateLastUpdated != nil{
			dictionary["dateLastUpdated"] = dateLastUpdated
		}
		if guid != nil{
			dictionary["guid"] = guid
		}
		if iconUrl != nil{
			dictionary["iconUrl"] = iconUrl
		}
		if id != nil{
			dictionary["id"] = id
		}
		if inbox != nil{
			dictionary["inbox"] = inbox.toDictionary()
		}
		if itunesUrl != nil{
			dictionary["itunesUrl"] = itunesUrl
		}
		if lastUpdatedBy != nil{
			dictionary["lastUpdatedBy"] = lastUpdatedBy.toDictionary()
		}
		if name != nil{
			dictionary["name"] = name
		}
		if playStoreUrl != nil{
			dictionary["playStoreUrl"] = playStoreUrl
		}
		if users != nil{
			var dictionaryElements = [[String:Any]]()
			for usersElement in users {
				dictionaryElements.append(usersElement.toDictionary())
			}
			dictionary["users"] = dictionaryElements
		}
		return dictionary
	}

}
