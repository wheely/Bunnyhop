//
//  Bunnyhop+Foundation.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

public extension JSON {
    /// Converts from NSJSONSerialization's AnyObject
    public static func fromAnyObject(anyObject: AnyObject?) -> JSON? {
        switch anyObject {
        
        case _ as NSNull:
            return nil
        
        case let a as NSNumber:
            switch CFNumberGetType(a as CFNumber) {
            case .SInt8Type, .SInt16Type, .SInt32Type, .SInt64Type,
                 .CharType, .ShortType, .IntType, .LongType, .LongLongType,
                 .CFIndexType, .NSIntegerType:
                return (a as Int).JSONValue
            case .Float32Type, .Float64Type, .FloatType, .CGFloatType:
                return (a as Float).JSONValue
            case .DoubleType:
                return (a as Double).JSONValue
            }
        
        case let value as String:
            return .StringValue(value)
        
        case let value as [AnyObject]:
            return .ArrayValue(value.map{JSON.fromAnyObject($0)})
            
        case let value as [String: AnyObject]:
            var d: [String: JSON?] = [:]
            for (k, v) in value {
                d[k] = JSON.fromAnyObject(v)
            }
            return .DictionaryValue(d)
            
        default:
            break
        }
        
        return nil
    }
    
    public func toAnyObject() -> AnyObject {
        switch self {
        case let .BoolValue(v):                 return v as NSNumber
        case let .NumberValue(.IntValue(v)):    return v as NSNumber
        case let .NumberValue(.FloatValue(v)):  return v as NSNumber
        case let .NumberValue(.DoubleValue(v)): return v as NSNumber
        case let .StringValue(v):               return v as NSString
        case let .ArrayValue(v):                return v.map{$0.map{$0.toAnyObject()} ?? NSNull()} as NSArray
        
        case let .DictionaryValue(v):
            var d: [String: AnyObject] = [:]
            for (k, v) in v {
                d[k] = v.map{$0.toAnyObject()} ?? NSNull()
            }
            return d as NSDictionary
        }
    }
}
