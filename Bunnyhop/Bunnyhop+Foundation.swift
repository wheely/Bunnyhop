//
//  Bunnyhop+Foundation.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

public extension JSON {
    /// Converts from NSJSONSerialization's AnyObject
    public static func fromAnyObject(_ anyObject: AnyObject?) -> JSON? {
        switch anyObject {
        
        case _ as NSNull:
            return nil
        
        case let a as NSNumber:
            switch CFNumberGetType(a as CFNumber) {
            case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
                 .charType, .shortType, .intType, .longType, .longLongType,
                 .cfIndexType, .nsIntegerType:
                return a.intValue.JSONValue
            case .float32Type, .float64Type, .floatType, .cgFloatType:
                return a.floatValue.JSONValue
            case .doubleType:
                return a.doubleValue.JSONValue
            }
        
        case let value as String:
            return .stringValue(value)
        
        case let value as [AnyObject]:
            return .arrayValue(value.map{JSON.fromAnyObject($0)})
            
        case let value as [String: AnyObject]:
            var d: [String: JSON?] = [:]
            for (k, v) in value {
                d[k] = JSON.fromAnyObject(v)
            }
            return .dictionaryValue(d)
            
        default:
            break
        }
        
        return nil
    }
    
    public func toAnyObject() -> AnyObject {
        switch self {
        case let .boolValue(v):                 return v as NSNumber
        case let .numberValue(.intValue(v)):    return v as NSNumber
        case let .numberValue(.floatValue(v)):  return v as NSNumber
        case let .numberValue(.doubleValue(v)): return v as NSNumber
        case let .stringValue(v):               return v as NSString
        case let .arrayValue(v):                return v.map{$0.map{$0.toAnyObject()} ?? NSNull()} as NSArray
        
        case let .dictionaryValue(v):
            var d: [String: AnyObject] = [:]
            for (k, v) in v {
                d[k] = v.map{$0.toAnyObject()} ?? NSNull()
            }
            return d as NSDictionary
        }
    }

    // TODO: Add conversion to/from Any for new JSONSerialization
}
