//
//  Inbox.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import Foundation

struct Inbox{

	var company : Company!
	var onboarding : Onboarding!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		if let companyData = dictionary["company"] as? [String:Any]{
				company = Company(fromDictionary: companyData)
			}
		if let onboardingData = dictionary["onboarding"] as? [String:Any]{
				onboarding = Onboarding(fromDictionary: onboardingData)
			}
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if company != nil{
			dictionary["company"] = company.toDictionary()
		}
		if onboarding != nil{
			dictionary["onboarding"] = onboarding.toDictionary()
		}
		return dictionary
	}

}
