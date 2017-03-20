//
//  JSON+JSONSerialization.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

/// Converts from JSONSerialization's Any.
public typealias JSONObject = Any

public extension JSON {

    init?(jsonObject: JSONObject) {
        switch jsonObject {

        case let nsNumber as NSNumber:
            self = nsNumber.json

        case let string as String:
            self = .stringValue(string)

        case let array as [Any]:
            self = .arrayValue(array.map { JSON(jsonObject: $0) })

        case let dictionary as [String: Any]:
            self = .dictionaryValue(Dictionary(elements: dictionary.map { ($0, JSON(jsonObject: $1)) }))

        case is NSNull: fallthrough
        default:
            return nil
        }
    }
    
    public func jsonObject() -> JSONObject {
        switch self {
        case let .boolValue(v):                 return NSNumber(value: v)
        case let .numberValue(.intValue(v)):    return NSNumber(value: v)
        case let .numberValue(.floatValue(v)):  return NSNumber(value: v)
        case let .numberValue(.doubleValue(v)): return NSNumber(value: v)
        case let .stringValue(v):               return NSString(string: v)
        case let .arrayValue(v):                return v.map { $0?.jsonObject() ?? NSNull() }
        
        case let .dictionaryValue(v):
            return Dictionary(elements: v.map { ($0, $1?.jsonObject() ?? NSNull()) })
        }
    }
}


// MARK: - Helpers

private extension NSNumber {

    var json: JSON {
        switch CFNumberGetType(self as CFNumber) {
        case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
             .charType, .shortType, .intType, .longType, .longLongType,
             .cfIndexType, .nsIntegerType:
            return intValue.json
        case .float32Type, .float64Type, .floatType, .cgFloatType:
            return floatValue.json
        case .doubleType:
            return doubleValue.json
        }
    }
}
