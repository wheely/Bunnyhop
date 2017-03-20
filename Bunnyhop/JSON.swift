//
//  JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

public enum JSON {
    case boolValue(Bool)
    case numberValue(Number)
    case stringValue(String)
    case arrayValue([JSON?])
    case dictionaryValue([String: JSON?])
}


// MARK: - Convenience

public extension JSON {

    public var arrayValue: [JSON?]? {
        switch self {
        case let .arrayValue(v):
            return v
        default:
            return nil
        }
    }

    public subscript (index: Int) -> JSON? {
        if let array = arrayValue, index <= array.endIndex {
            return array[index]
        } else {
            return nil
        }
    }

    public var dictionaryValue: [String: JSON?]? {
        switch self {
        case let .dictionaryValue(v):
            return v
        default:
            return nil
        }
    }

    public subscript (key: String) -> JSON? {
        return dictionaryValue?[key] ?? nil
    }
}


// MARK: - Equatable

extension JSON: Equatable {

    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case let (.boolValue(l), .boolValue(r)):
            return l == r
        case let (.numberValue(l), .numberValue(r)):
            return l == r

        // TODO: Research whether Bool-to-Number conversions are actually needed.
        case let (.boolValue(l), .numberValue(.intValue(r))):
            return Int(l) == r
        case let (.boolValue(l), .numberValue(.floatValue(r))):
            return Float(l) == r
        case let (.boolValue(l), .numberValue(.doubleValue(r))):
            return Double(l) == r
        case let (.numberValue(.intValue(l)),    .boolValue(r)):
            return l == Int(r)
        case let (.numberValue(.floatValue(l)),  .boolValue(r)):
            return l == Float(r)
        case let (.numberValue(.doubleValue(l)), .boolValue(r)):
            return l == Double(r)

        case let (.stringValue(l), .stringValue(r)):
            return l == r

        case let (.arrayValue(l), .arrayValue(r)):
            return l.elementsEqual(r, by: ==)

        case let (.dictionaryValue(l), .dictionaryValue(r)):
            return l.elementsEqual(r) { $0.key == $1.key && $0.value == $1.value }
            
        default: return false
        }
    }
}


// MARK: - Literal Initializers

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolValue(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .numberValue(Number.intValue(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Float) {
        self = .numberValue(Number.floatValue(value))
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .stringValue(value)
    }
}

extension JSON: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .stringValue(value)
    }
}

extension JSON: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .stringValue(value)
    }
}


// MARK: - Printing

extension JSON: CustomStringConvertible {

    public var description: String {
        switch self {
        case let .boolValue(v):
            return v.description
        case let .numberValue(v):
            return v.description
        case let .stringValue(v):
            return v
        case let .arrayValue(v):
            return "[" + v.map { $0?.description ?? "nil" }.joined(separator: ", ") + "]"
        case let .dictionaryValue(v):
            return "[" + v.map { "\($0.0): " + ($0.1?.description ?? "nil") }.joined(separator: ", ") + "]"
        }
    }
}

extension JSON: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case let .boolValue(v):
            return v.description
        case let .numberValue(v):
            return v.description
        case let .stringValue(v):
            return v.debugDescription
        case let .arrayValue(v):
            return "[" + v.map { $0.debugDescription }.joined(separator: ", ") + "]"
        case let .dictionaryValue(v):
            return "[" + v.map { "\($0.0.debugDescription): \($0.1.debugDescription)" }.joined(separator: ", ") + "]"
        }
    }
}


// MARK: - Bool to Number Conversion

extension Int {
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}

extension Float {
    init(_ bool: Bool) {
        self = bool ? 1.0 : 0.0
    }
}

extension Double {
    init(_ bool: Bool) {
        self = bool ? 1.0 : 0.0
    }
}

