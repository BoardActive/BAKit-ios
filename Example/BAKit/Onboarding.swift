//
//  Onboarding.swift
//  AdDrop
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import Foundation

struct Onboarding {

	var step0 : Int!
	var step1 : Int!
	var step2 : Int!
    var step3 : Int!

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		step0 = dictionary["step0"] as? Int
		step1 = dictionary["step1"] as? Int
		step2 = dictionary["step2"] as? Int
        step3 = dictionary["step3"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if step0 != nil{
			dictionary["step0"] = step0
		}
		if step1 != nil{
			dictionary["step1"] = step1
		}
		if step2 != nil{
			dictionary["step2"] = step2
		}
        if step3 != nil{
            dictionary["step3"] = step3
        }
		return dictionary
	}

}
