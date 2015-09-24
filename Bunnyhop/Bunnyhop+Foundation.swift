//
//  Bunnyhop+Foundation.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import Foundation


extension CGFloat: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        if let value: Double = JSONValue.decode() {
            self.init(value)
        } else {
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .NumberValue(.DoubleValue(Double(self)))
    }
}


public extension JSON {
    /// Converts from NSJSONSerialization's AnyObject
    public static func fromAnyObject(anyObject: AnyObject?) -> JSON? {
        if anyObject is NSNull {
            return .Nothing
            
        } else if let a = anyObject as? NSNumber {
            switch CFNumberGetType(a as CFNumber) {
            case .SInt8Type, .SInt16Type, .SInt32Type, .SInt64Type,
                .CharType, .ShortType, .IntType, .LongType, .LongLongType,
                .CFIndexType, .NSIntegerType:
                return JSON(a as Int)
            case .Float32Type, .Float64Type, .FloatType, .CGFloatType:
                return JSON(a as Float)
            case .DoubleType:
                return JSON(a as Double)
            }
            
        } else if let value = anyObject as? String {
            return JSON(value)
            
        } else if let value = anyObject as? [AnyObject] {
            var a = [JSON]()
            for v in value {
                if let v = JSON.fromAnyObject(v) {
                    a.append(v)
                } else {
                    return nil // TODO: add strict and not strict version
                }
            }
            return JSON(a)
            
        } else if let value = anyObject as? [String: AnyObject] {
            var d: [String: JSON] = [:]
            for (k, v) in value {
                if let v = JSON.fromAnyObject(v) {
                    d[k] = v
                } else {
                    return nil // TODO: add strict and not strict version
                }
            }
            return JSON(d)
        }
        
        return nil
    }
    
    public func toAnyObject() -> AnyObject {
        switch self {
        case .Nothing:                          return NSNull()
        case let .BoolValue(v):                 return v as NSNumber
        case let .NumberValue(.IntValue(v)):    return v as NSNumber
        case let .NumberValue(.FloatValue(v)):  return v as NSNumber
        case let .NumberValue(.DoubleValue(v)): return v as NSNumber
        case let .StringValue(v):               return v as NSString
        case let .ArrayValue(v):                return v.map{$0.toAnyObject()} as NSArray
        
        case let .DictionaryValue(v):
            var d: [String: AnyObject] = [:]
            for (k, v) in v {
                d[k] = v.toAnyObject()
            }
            return d
        }
    }
}