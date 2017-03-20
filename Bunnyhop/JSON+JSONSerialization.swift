//
//  JSON+JSONSerialization.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

public extension JSON {
    
    /// Converts from JSONSerialization's Any.
    public static func from(jsonObject: Any?) -> JSON? {
        switch jsonObject {
        
        case _ as NSNull:
            return nil
        
        case let a as NSNumber:
            switch CFNumberGetType(a as CFNumber) {
            case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
                 .charType, .shortType, .intType, .longType, .longLongType,
                 .cfIndexType, .nsIntegerType:
                return a.intValue.jsonValue
            case .float32Type, .float64Type, .floatType, .cgFloatType:
                return a.floatValue.jsonValue
            case .doubleType:
                return a.doubleValue.jsonValue
            }
        
        case let value as String:
            return .stringValue(value)
        
        case let value as [Any]:
            return .arrayValue(value.map { JSON.from(jsonObject: $0) })
            
        case let value as [String: Any]:
            var d: [String: JSON?] = [:]
            for (k, v) in value {
                d[k] = JSON.from(jsonObject: v)
            }
            return .dictionaryValue(d)
            
        default:
            break
        }
        
        return nil
    }
    
    public func toJSONObject() -> Any {
        switch self {
        case let .boolValue(v):                 return NSNumber(value: v)
        case let .numberValue(.intValue(v)):    return NSNumber(value: v)
        case let .numberValue(.floatValue(v)):  return NSNumber(value: v)
        case let .numberValue(.doubleValue(v)): return NSNumber(value: v)
        case let .stringValue(v):               return NSString(string: v)
        case let .arrayValue(v):                return v.map{ $0.map { $0.toJSONObject() } ?? NSNull() } as NSArray
        
        case let .dictionaryValue(v):
            var d: [String: Any] = [:]
            for (k, v) in v {
                d[k] = v.map { $0.toJSONObject() } ?? NSNull()
            }
            return d as NSDictionary
        }
    }
}
