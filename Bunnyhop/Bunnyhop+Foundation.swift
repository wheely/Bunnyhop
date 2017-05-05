//
//  Bunnyhop+Foundation.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import Foundation


extension CGFloat: JSONDecodable, JSONEncodable {
    public init(jsonValue: JSON) throws {
        let value: Double = try jsonValue.decode()
        self.init(value)
    }
    
    public var jsonValue: JSON {
        return .numberValue(.doubleValue(Double(self)))
    }
}

public extension JSON {
    /// Converts from NSJSONSerialization's Any
    public static func fromAnyObject(_ jsonObject: Any) -> JSON? {
        switch jsonObject {

        case let nsNumber as NSNumber:
            return nsNumber.json

        case let string as String:
            return .stringValue(string)

        case let array as [Any]:
            return .arrayValue(array.map { JSON.fromAnyObject($0) })

        case let dictionary as [String: Any]:
            return .dictionaryValue(Dictionary(elements: dictionary.map { ($0, JSON.fromAnyObject($1)) }))

        default:
            return nil
        }
    }
    
    public func toAnyObject() -> Any {
        switch self {
        case let .boolValue(bool):                   return bool
        case let .numberValue(.intValue(int)):       return int
        case let .numberValue(.floatValue(float)):   return float
        case let .numberValue(.doubleValue(double)): return double
        case let .stringValue(string):               return string
        case let .arrayValue(array):                 return array.map { $0?.toAnyObject() }

        case let .dictionaryValue(dictionary):
            return Dictionary(elements: dictionary.map { ($0, $1?.toAnyObject()) })
        }
    }
    
    public init?(data: Data, allowFragments: Bool = false) throws {
        let jsonAsAny: Any =
            try JSONSerialization.jsonObject(with: data, options: allowFragments ? .allowFragments : JSONSerialization.ReadingOptions())
        if let jsonValue = JSON.fromAnyObject(jsonAsAny) {
            self = jsonValue
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


// MARK: - Helpers

private extension NSNumber {

    var json: JSON {
        switch CFNumberGetType(self as CFNumber) {
        case .charType:
            return boolValue.jsonValue
        case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
             .shortType, .intType, .longType, .longLongType,
             .cfIndexType, .nsIntegerType:
            return intValue.jsonValue
        case .float32Type, .float64Type, .floatType, .cgFloatType:
            return floatValue.jsonValue
        case .doubleType:
            return doubleValue.jsonValue
        }
    }
}
