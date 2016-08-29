//
//  Bunnyhop+Foundation.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import Foundation


extension CGFloat: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        let value: Double = try json.decode()
        self.init(value)
    }
    
    public var json: JSON {
        return .number(.double(Double(self)))
    }
}

public extension JSON {
    /// Converts from NSJSONSerialization's AnyObject
    public static func fromAnyObject(_ anyObject: AnyObject) -> JSON? {
        switch anyObject {
        
        case _ as NSNull:
            return nil
        
        case let a as NSNumber:
            switch CFNumberGetType(a as CFNumber) {
            case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
                 .charType, .shortType, .intType, .longType, .longLongType,
                 .cfIndexType, .nsIntegerType:
                return (a as Int).json
            case .float32Type, .float64Type, .floatType, .cgFloatType:
                return (a as Float).json
            case .doubleType:
                return (a as Double).json
            }
        
        case let value as String:
            return .string(value)
        
        case let value as [AnyObject]:
            return .array(value.map{JSON.fromAnyObject($0)})
            
        case let value as [String: AnyObject]:
            var d: [String: JSON?] = [:]
            for (k, v) in value {
                d[k] = JSON.fromAnyObject(v)
            }
            return .dictionary(d)
            
        default:
            break
        }
        
        return nil
    }
    
    public func toAnyObject() -> AnyObject {
        switch self {
        case let .bool(v):                 return v as NSNumber
        case let .number(.int(v)):    return v as NSNumber
        case let .number(.float(v)):  return v as NSNumber
        case let .number(.double(v)): return v as NSNumber
        case let .string(v):               return v as NSString
        case let .array(v):                return v.map{$0.map{$0.toAnyObject()} ?? NSNull()} as NSArray
        
        case let .dictionary(v):
            var d: [String: AnyObject] = [:]
            for (k, v) in v {
                d[k] = v.map{$0.toAnyObject()} ?? NSNull()
            }
            return d as NSDictionary
        }
    }
    
    public init?(data: Data, allowFragments: Bool = false) throws {
        let jsonAsAnyObject: AnyObject =
            try JSONSerialization.jsonObject(with: data, options: allowFragments ? .allowFragments : JSONSerialization.ReadingOptions())
        if let json = JSON.fromAnyObject(jsonAsAnyObject) {
            self = json
        } else {
            return nil
        }
    }
    
    public func encode(_ prettyPrinted: Bool = false) -> Data {
        // An instance of JSON type will never throw an error
        return try! JSONSerialization.data(withJSONObject: toAnyObject(),
                                           options: prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions())
    }
}
