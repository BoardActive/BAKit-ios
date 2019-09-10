//
//  LoginPayload.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import Foundation

public struct LoginPayload{

	public var apps : [App]!
	var avatarImageId : AnyObject!
	var avatarUrl : AnyObject!
	var customerId : AnyObject!
	var dateCreated : String!
	var dateDeleted : AnyObject!
	var dateLastUpdated : String!
	var email : String!
	var firstName : AnyObject!
	var googleAvatarUrl : AnyObject!
	var guid : String!
	var id : Int!
	var inbox : Inbox!
	var isApprovedByDoug : Bool!
	var isClaimed : Bool!
	var isCompliant : Bool!
	var isGod : Bool!
	var isRejectedByDoug : Bool!
	var isVerified : Bool!
	var lastName : AnyObject!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		apps = [App]()
		if let appsArray = dictionary["apps"] as? [[String:Any]]{
			for dic in appsArray{
				let value = App(fromDictionary: dic)
				apps.append(value)
			}
		}
		avatarImageId = dictionary["avatarImageId"] as? AnyObject
		avatarUrl = dictionary["avatarUrl"] as? AnyObject
		customerId = dictionary["customerId"] as? AnyObject
		dateCreated = dictionary["dateCreated"] as? String
		dateDeleted = dictionary["dateDeleted"] as? AnyObject
		dateLastUpdated = dictionary["dateLastUpdated"] as? String
		email = dictionary["email"] as? String
		firstName = dictionary["firstName"] as? AnyObject
		googleAvatarUrl = dictionary["googleAvatarUrl"] as? AnyObject
		guid = dictionary["guid"] as? String
		id = dictionary["id"] as? Int
        if let inboxData = dictionary["inbox"] as? [String:Any] {
            inbox = Inbox.init(fromDictionary:inboxData)
        }
		isApprovedByDoug = dictionary["isApprovedByDoug"] as? Bool
		isClaimed = dictionary["isClaimed"] as? Bool
		isCompliant = dictionary["isCompliant"] as? Bool
		isGod = dictionary["isGod"] as? Bool
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
		if apps != nil{
			var dictionaryElements = [[String:Any]]()
			for appsElement in apps {
				dictionaryElements.append(appsElement.toDictionary())
			}
			dictionary["apps"] = dictionaryElements
		}
		if avatarImageId != nil{
			dictionary["avatarImageId"] = avatarImageId
		}
		if avatarUrl != nil{
			dictionary["avatarUrl"] = avatarUrl
		}
		if customerId != nil{
			dictionary["customerId"] = customerId
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
		if googleAvatarUrl != nil{
			dictionary["googleAvatarUrl"] = googleAvatarUrl
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
		if isApprovedByDoug != nil{
			dictionary["isApprovedByDoug"] = isApprovedByDoug
		}
		if isClaimed != nil{
			dictionary["isClaimed"] = isClaimed
		}
		if isCompliant != nil{
			dictionary["isCompliant"] = isCompliant
		}
		if isGod != nil{
			dictionary["isGod"] = isGod
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

//public struct App{
//
//    var createdBy : CreatedBy!
//    var dateCreated : String!
//    var dateLastUpdated : String!
//    var guid : String!
//    var iconUrl : AnyObject!
//    public var id : Int!
//    var inbox : Inbox!
//    var itunesUrl : AnyObject!
//    var lastUpdatedBy : CreatedBy!
//    public var name : String!
//    var playStoreUrl : AnyObject!
//    var users : [User]!
//
//
//    /**
//     * Instantiate the instance using the passed dictionary values to set the properties values
//     */
//    init(fromDictionary dictionary: [String:Any]){
//        if let createdByData = dictionary["createdBy"] as? [String:Any]{
//            createdBy = CreatedBy(fromDictionary: createdByData)
//        }
//        dateCreated = dictionary["dateCreated"] as? String
//        dateLastUpdated = dictionary["dateLastUpdated"] as? String
//        guid = dictionary["guid"] as? String
//        iconUrl = dictionary["iconUrl"] as? AnyObject
//        id = dictionary["id"] as? Int
//        if let inboxData = dictionary["inbox"] as? [String:Any]{
//            inbox = Inbox(fromDictionary: inboxData)
//        }
//        itunesUrl = dictionary["itunesUrl"] as? AnyObject
//        if let lastUpdatedByData = dictionary["lastUpdatedBy"] as? [String:Any]{
//            lastUpdatedBy = CreatedBy(fromDictionary: lastUpdatedByData)
//        }
//        name = dictionary["name"] as? String
//        playStoreUrl = dictionary["playStoreUrl"] as? AnyObject
//        users = [User]()
//        if let usersArray = dictionary["users"] as? [[String:Any]]{
//            for dic in usersArray{
//                let value = User(fromDictionary: dic)
//                users.append(value)
//            }
//        }
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if createdBy != nil{
//            dictionary["createdBy"] = createdBy.toDictionary()
//        }
//        if dateCreated != nil{
//            dictionary["dateCreated"] = dateCreated
//        }
//        if dateLastUpdated != nil{
//            dictionary["dateLastUpdated"] = dateLastUpdated
//        }
//        if guid != nil{
//            dictionary["guid"] = guid
//        }
//        if iconUrl != nil{
//            dictionary["iconUrl"] = iconUrl
//        }
//        if id != nil{
//            dictionary["id"] = id
//        }
//        if inbox != nil{
//            dictionary["inbox"] = inbox.toDictionary()
//        }
//        if itunesUrl != nil{
//            dictionary["itunesUrl"] = itunesUrl
//        }
//        if lastUpdatedBy != nil{
//            dictionary["lastUpdatedBy"] = lastUpdatedBy.toDictionary()
//        }
//        if name != nil{
//            dictionary["name"] = name
//        }
//        if playStoreUrl != nil{
//            dictionary["playStoreUrl"] = playStoreUrl
//        }
//        if users != nil{
//            var dictionaryElements = [[String:Any]]()
//            for usersElement in users {
//                dictionaryElements.append(usersElement.toDictionary())
//            }
//            dictionary["users"] = dictionaryElements
//        }
//        return dictionary
//    }
//
//}
//
//struct CreatedBy{
//
//    var avatarUrl : AnyObject!
//    var dateCreated : String!
//    var dateDeleted : AnyObject!
//    var dateLastUpdated : String!
//    var email : String!
//    var firstName : AnyObject!
//    var id : Int!
//    var inbox : Inbox!
//    var isApprovedByDoug : Bool!
//    var isClaimed : Bool!
//    var isCompliant : Bool!
//    var isRejectedByDoug : Bool!
//    var isVerified : Bool!
//    var lastName : AnyObject!
//
//
//    /**
//     * Instantiate the instance using the passed dictionary values to set the properties values
//     */
//    init(fromDictionary dictionary: [String:Any]){
//        avatarUrl = dictionary["avatarUrl"] as? AnyObject
//        dateCreated = dictionary["dateCreated"] as? String
//        dateDeleted = dictionary["dateDeleted"] as? AnyObject
//        dateLastUpdated = dictionary["dateLastUpdated"] as? String
//        email = dictionary["email"] as? String
//        firstName = dictionary["firstName"] as? AnyObject
//        id = dictionary["id"] as? Int
//        if let inboxData = dictionary["inbox"] as? [String:Any]{
//            inbox = Inbox(fromDictionary: inboxData)
//        }
//        isApprovedByDoug = dictionary["isApprovedByDoug"] as? Bool
//        isClaimed = dictionary["isClaimed"] as? Bool
//        isCompliant = dictionary["isCompliant"] as? Bool
//        isRejectedByDoug = dictionary["isRejectedByDoug"] as? Bool
//        isVerified = dictionary["isVerified"] as? Bool
//        lastName = dictionary["lastName"] as? AnyObject
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if avatarUrl != nil{
//            dictionary["avatarUrl"] = avatarUrl
//        }
//        if dateCreated != nil{
//            dictionary["dateCreated"] = dateCreated
//        }
//        if dateDeleted != nil{
//            dictionary["dateDeleted"] = dateDeleted
//        }
//        if dateLastUpdated != nil{
//            dictionary["dateLastUpdated"] = dateLastUpdated
//        }
//        if email != nil{
//            dictionary["email"] = email
//        }
//        if firstName != nil{
//            dictionary["firstName"] = firstName
//        }
//        if id != nil{
//            dictionary["id"] = id
//        }
//        if inbox != nil{
//            dictionary["inbox"] = inbox.toDictionary()
//        }
//        if isApprovedByDoug != nil{
//            dictionary["isApprovedByDoug"] = isApprovedByDoug
//        }
//        if isClaimed != nil{
//            dictionary["isClaimed"] = isClaimed
//        }
//        if isCompliant != nil{
//            dictionary["isCompliant"] = isCompliant
//        }
//        if isRejectedByDoug != nil{
//            dictionary["isRejectedByDoug"] = isRejectedByDoug
//        }
//        if isVerified != nil{
//            dictionary["isVerified"] = isVerified
//        }
//        if lastName != nil{
//            dictionary["lastName"] = lastName
//        }
//        return dictionary
//    }
//
//}
//
//struct Inbox{
//
//    var company : Company!
//    var onboarding : Onboarding!
//
//
//    /**
//     * Instantiate the instance using the passed dictionary values to set the properties values
//     */
//    init(fromDictionary dictionary: [String:Any]){
//        if let companyData = dictionary["company"] as? [String:Any]{
//            company = Company(fromDictionary: companyData)
//        }
//        if let onboardingData = dictionary["onboarding"] as? [String:Any]{
//            onboarding = Onboarding(fromDictionary: onboardingData)
//        }
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if company != nil{
//            dictionary["company"] = company.toDictionary()
//        }
//        if onboarding != nil{
//            dictionary["onboarding"] = onboarding.toDictionary()
//        }
//        return dictionary
//    }
//
//}
//
//struct User{
//
//    var email : String!
//    var firstName : AnyObject!
//    var id : Int!
//    var inbox : Inbox!
//    var isClaimed : Bool!
//    var isCompliant : Bool!
//    var isVerified : Bool!
//    var lastName : AnyObject!
//    var role : String!
//
//
//    /**
//     * Instantiate the instance using the passed dictionary values to set the properties values
//     */
//    init(fromDictionary dictionary: [String:Any]){
//        email = dictionary["email"] as? String
//        firstName = dictionary["firstName"] as? AnyObject
//        id = dictionary["id"] as? Int
//        if let inboxData = dictionary["inbox"] as? [String:Any]{
//            inbox = Inbox(fromDictionary: inboxData)
//        }
//        isClaimed = dictionary["isClaimed"] as? Bool
//        isCompliant = dictionary["isCompliant"] as? Bool
//        isVerified = dictionary["isVerified"] as? Bool
//        lastName = dictionary["lastName"] as? AnyObject
//        role = dictionary["role"] as? String
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if email != nil{
//            dictionary["email"] = email
//        }
//        if firstName != nil{
//            dictionary["firstName"] = firstName
//        }
//        if id != nil{
//            dictionary["id"] = id
//        }
//        if inbox != nil{
//            dictionary["inbox"] = inbox.toDictionary()
//        }
//        if isClaimed != nil{
//            dictionary["isClaimed"] = isClaimed
//        }
//        if isCompliant != nil{
//            dictionary["isCompliant"] = isCompliant
//        }
//        if isVerified != nil{
//            dictionary["isVerified"] = isVerified
//        }
//        if lastName != nil{
//            dictionary["lastName"] = lastName
//        }
//        if role != nil{
//            dictionary["role"] = role
//        }
//        return dictionary
//    }
//
//}
//
//struct Onboarding{
//
//    var step0 : Int!
//    var step1 : Int!
//    var step2 : Int!
//
//
//    /**
//     * Instantiate the instance using the passed dictionary values to set the properties values
//     */
//    init(fromDictionary dictionary: [String:Any]){
//        step0 = dictionary["step0"] as? Int
//        step1 = dictionary["step1"] as? Int
//        step2 = dictionary["step2"] as? Int
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if step0 != nil{
//            dictionary["step0"] = step0
//        }
//        if step1 != nil{
//            dictionary["step1"] = step1
//        }
//        if step2 != nil{
//            dictionary["step2"] = step2
//        }
//        return dictionary
//    }
//
//}
//
//struct Company{
//
//    var hasRequested : Bool!
//    var intent : String!
//    var name : String!
//    var phone : String!
//    var size : String!
//    var url : String!
//
//
//    /**
//     * Instantiate the instance using the passed dictionary values to set the properties values
//     */
//    init(fromDictionary dictionary: [String:Any]){
//        hasRequested = dictionary["hasRequested"] as? Bool
//        intent = dictionary["intent"] as? String
//        name = dictionary["name"] as? String
//        phone = dictionary["phone"] as? String
//        size = dictionary["size"] as? String
//        url = dictionary["url"] as? String
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if hasRequested != nil{
//            dictionary["hasRequested"] = hasRequested
//        }
//        if intent != nil{
//            dictionary["intent"] = intent
//        }
//        if name != nil{
//            dictionary["name"] = name
//        }
//        if phone != nil{
//            dictionary["phone"] = phone
//        }
//        if size != nil{
//            dictionary["size"] = size
//        }
//        if url != nil{
//            dictionary["url"] = url
//        }
//        return dictionary
//    }

//}
