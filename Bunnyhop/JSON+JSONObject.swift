//
//  JSON+JSONSerialization.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

/**

 Object that's returned by JSONSerialization's jsonObject(:) method.

 The object must have the following properties:
 - Top level object is an NSArray or NSDictionary
 - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
 - All dictionary keys are NSStrings
 - NSNumbers are not NaN or infinity

 */
public typealias JSONObject = Any

public extension JSON {

    public var jsonObject: JSONObject {
        switch self {
        case let .boolValue(bool):                   return bool
        case let .numberValue(.intValue(int)):       return int
        case let .numberValue(.floatValue(float)):   return float
        case let .numberValue(.doubleValue(double)): return double
        case let .stringValue(string):               return string
        case let .arrayValue(array):                 return array.map { $0?.jsonObject }

        case let .dictionaryValue(dictionary):
            return Dictionary(elements: dictionary.map { ($0, $1?.jsonObject) })
        }
    }

    init?(jsonObject: JSONObject) {
        switch jsonObject {

        case let nsNumber as NSNumber:
            self = nsNumber.json

        case let string as String:
            self = .stringValue(string)

        case let array as [JSONObject]:
            self = .arrayValue(array.map { JSON(jsonObject: $0) })

        case let dictionary as [String: JSONObject]:
            self = .dictionaryValue(Dictionary(elements: dictionary.map { ($0, JSON(jsonObject: $1)) }))

        default:
            return nil
        }
    }
}


// MARK: - Helpers

private extension NSNumber {

    var json: JSON {
        switch CFNumberGetType(self as CFNumber) {
        case .charType:
            return boolValue.json
        case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
             .shortType, .intType, .longType, .longLongType,
             .cfIndexType, .nsIntegerType:
            return intValue.json
        case .float32Type, .float64Type, .floatType, .cgFloatType:
            return floatValue.json
        case .doubleType:
            return doubleValue.json
        }
    }
}
