//
//	Attribute.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

public struct Attribute {

	public var custom : Custom!
	public var stock : Stock!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	public init(fromDictionary dictionary: [String:Any]){
		if let customData = dictionary["custom"] as? [String:Any]{
				custom = Custom(fromDictionary: customData)
			}
		if let stockData = dictionary["stock"] as? [String:Any]{
				stock = Stock(fromDictionary: stockData)
			}
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	public func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if custom != nil{
			dictionary["custom"] = custom.toDictionary()
		}
		if stock != nil{
			dictionary["stock"] = stock.toDictionary()
		}
		return dictionary
	}

}
