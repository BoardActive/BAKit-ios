//
//  Stock.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import Foundation

public struct Stock {
	var dateBorn : AnyObject!
	var dateCreated : String!
	var dateLastOpenedApp : String!
	var dateLocationPermissionRequested : AnyObject!
	var dateNotificationPermissionRequested : AnyObject!
	var deviceOS : String!
	var deviceOSVersion : String!
	var deviceType : String!
	var email : AnyObject!
	var facebookUrl : AnyObject!
	var gender : AnyObject!
	var goalPercentage : Int!
	var instagramUrl : AnyObject!
	var linkedInUrl : AnyObject!
	var locationPermission : Int!
	var name : String!
	var notificationPermission : Int!
	var openedCount : Int!
	var phone : AnyObject!
	var receivedCount : Int!
	var sentCount : Int!
	var twitterUrl : AnyObject!
	var visitedCount : Int!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		dateBorn = dictionary["dateBorn"] as? AnyObject
		dateCreated = dictionary["dateCreated"] as? String
		dateLastOpenedApp = dictionary["dateLastOpenedApp"] as? String
		dateLocationPermissionRequested = dictionary["dateLocationPermissionRequested"] as? AnyObject
		dateNotificationPermissionRequested = dictionary["dateNotificationPermissionRequested"] as? AnyObject
		deviceOS = dictionary["deviceOS"] as? String
		deviceOSVersion = dictionary["deviceOSVersion"] as? String
		deviceType = dictionary["deviceType"] as? String
		email = dictionary["email"] as? AnyObject
		facebookUrl = dictionary["facebookUrl"] as? AnyObject
		gender = dictionary["gender"] as? AnyObject
		goalPercentage = dictionary["goalPercentage"] as? Int
		instagramUrl = dictionary["instagramUrl"] as? AnyObject
		linkedInUrl = dictionary["linkedInUrl"] as? AnyObject
		locationPermission = dictionary["locationPermission"] as? Int
		name = dictionary["name"] as? String
		notificationPermission = dictionary["notificationPermission"] as? Int
		openedCount = dictionary["openedCount"] as? Int
		phone = dictionary["phone"] as? AnyObject
		receivedCount = dictionary["receivedCount"] as? Int
		sentCount = dictionary["sentCount"] as? Int
		twitterUrl = dictionary["twitterUrl"] as? AnyObject
		visitedCount = dictionary["visitedCount"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if dateBorn != nil{
			dictionary["dateBorn"] = dateBorn
		}
		if dateCreated != nil{
			dictionary["dateCreated"] = dateCreated
		}
		if dateLastOpenedApp != nil{
			dictionary["dateLastOpenedApp"] = dateLastOpenedApp
		}
		if dateLocationPermissionRequested != nil{
			dictionary["dateLocationPermissionRequested"] = dateLocationPermissionRequested
		}
		if dateNotificationPermissionRequested != nil{
			dictionary["dateNotificationPermissionRequested"] = dateNotificationPermissionRequested
		}
		if deviceOS != nil{
			dictionary["deviceOS"] = deviceOS
		}
		if deviceOSVersion != nil{
			dictionary["deviceOSVersion"] = deviceOSVersion
		}
		if deviceType != nil{
			dictionary["deviceType"] = deviceType
		}
		if email != nil{
			dictionary["email"] = email
		}
		if facebookUrl != nil{
			dictionary["facebookUrl"] = facebookUrl
		}
		if gender != nil{
			dictionary["gender"] = gender
		}
		if goalPercentage != nil{
			dictionary["goalPercentage"] = goalPercentage
		}
		if instagramUrl != nil{
			dictionary["instagramUrl"] = instagramUrl
		}
		if linkedInUrl != nil{
			dictionary["linkedInUrl"] = linkedInUrl
		}
		if locationPermission != nil{
			dictionary["locationPermission"] = locationPermission
		}
		if name != nil{
			dictionary["name"] = name
		}
		if notificationPermission != nil{
			dictionary["notificationPermission"] = notificationPermission
		}
		if openedCount != nil{
			dictionary["openedCount"] = openedCount
		}
		if phone != nil{
			dictionary["phone"] = phone
		}
		if receivedCount != nil{
			dictionary["receivedCount"] = receivedCount
		}
		if sentCount != nil{
			dictionary["sentCount"] = sentCount
		}
		if twitterUrl != nil{
			dictionary["twitterUrl"] = twitterUrl
		}
		if visitedCount != nil{
			dictionary["visitedCount"] = visitedCount
		}
		return dictionary
	}

}
