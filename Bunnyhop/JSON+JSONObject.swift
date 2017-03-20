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
        var json: JSON?

        switch jsonObject {

        case let a as NSNumber:
            switch CFNumberGetType(a as CFNumber) {
            case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
                 .charType, .shortType, .intType, .longType, .longLongType,
                 .cfIndexType, .nsIntegerType:
                json = a.intValue.json
            case .float32Type, .float64Type, .floatType, .cgFloatType:
                json = a.floatValue.json
            case .doubleType:
                json = a.doubleValue.json
            }

        case let value as String:
            json = .stringValue(value)

        case let value as [Any]:
            json = .arrayValue(value.map { JSON(jsonObject: $0) })

        case let value as [String: Any]:
            var d: [String: JSON?] = [:]
            for (k, v) in value {
                d[k] = JSON(jsonObject: v)
            }
            json = .dictionaryValue(d)

        case is NSNull:
            break

        default:
            break
        }

        if let json = json {
            self = json
        } else {
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
        case let .arrayValue(v):                return v.map { $0.map { $0.jsonObject() } ?? NSNull() } as NSArray
        
        case let .dictionaryValue(v):
            var d: [String: Any] = [:]
            for (k, v) in v {
                d[k] = v.map { $0.jsonObject() } ?? NSNull()
            }
            return d as NSDictionary
        }
    }
}
