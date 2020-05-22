//
//  AttributeList.swift
//  AdDrop
//
//  Created by Indrajeet Senger on 13/05/20.
//  Copyright © 2020 BoardActive. All rights reserved.
//

import Foundation
import Foundation

// MARK: - AttributeElement
public class AttributeElement: Codable {
    var id: Int?
    var placeHolder: String?
    var type: TypeEnum?
    var isStock: Bool?
    var value: String = ""

    init(dataList: [String: Any]) {
        if let id = dataList["id"] as? Int {
            self.id = id
        }
        
        if let placeHolder = dataList["name"] as? String {
            self.placeHolder = placeHolder
        }
        
        if let type = dataList["type"] as? String {
            self.type = TypeEnum(rawValue: type)
        }
        
        if let isStock = dataList["isStock"] as? Bool {
            self.isStock = isStock
        }
    }
}

enum TypeEnum: String, Codable {
    case boolean = "boolean"
    case date = "date"
    case double = "double"
    case integer = "integer"
    case string = "string"
}
