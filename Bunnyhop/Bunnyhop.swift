//
//  Bunnyhop.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 16/01/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

public enum JSON: Equatable {
    public enum Number: Equatable {
        case intValue(Int)
        case floatValue(Float)
        case doubleValue(Double)
    }
    
    case boolValue(Bool)
    case numberValue(Number)
    case stringValue(String)
    case arrayValue([JSON?])
    case dictionaryValue([String: JSON?])
}


public func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
    switch (lhs, rhs) {
    case let (.intValue(l),    .intValue(r))    where l == r:         return true
    case let (.intValue(l),    .floatValue(r))  where Float(l) == r:  return true
    case let (.intValue(l),    .doubleValue(r)) where Double(l) == r: return true
    
    case let (.floatValue(l),  .intValue(r))    where l == Float(r):  return true
    case let (.floatValue(l),  .floatValue(r))  where l == r:         return true
    case let (.floatValue(l),  .doubleValue(r)) where Double(l) == r: return true
    
    case let (.doubleValue(l), .intValue(r))    where l == Double(r): return true
    case let (.doubleValue(l), .floatValue(r))  where l == Double(r): return true
    case let (.doubleValue(l), .doubleValue(r)) where l == r:         return true
        
    default: return false
    }
}


public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case let (.boolValue(l), .boolValue(r))                 where l == r:          return true
    case let (.boolValue(l), .numberValue(.intValue(r)))    where Int(l) == r:     return true
    case let (.boolValue(l), .numberValue(.floatValue(r)))  where Float(l) == r:   return true
    case let (.boolValue(l), .numberValue(.doubleValue(r))) where Double(l) == r:  return true
    case let (.numberValue(.intValue(l)),    .boolValue(r)) where l == Int(r):     return true
    case let (.numberValue(.floatValue(l)),  .boolValue(r)) where l == Float(r):   return true
    case let (.numberValue(.doubleValue(l)), .boolValue(r)) where l == Double(r):  return true

    case let (.numberValue(l),     .numberValue(r))         where l == r:          return true
    case let (.stringValue(l),     .stringValue(r))         where l == r:          return true
    case let (.arrayValue(l),      .arrayValue(r))          where l.elementsEqual(r, by: ==): return true
    case let (.dictionaryValue(l), .dictionaryValue(r))     where l.elementsEqual(r) {$0.0.0 == $0.1.0 && $0.0.1 == $0.1.1}: return true
    
    default: return false
    }
}


// MARK: LiteralConvertible Initializers

extension JSON: ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolValue(value)
    }

    public init(integerLiteral value: Int) {
        self = .numberValue(Number.intValue(value))
    }

    public init(floatLiteral value: Float) {
        self = .numberValue(Number.floatValue(value))
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .stringValue(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .stringValue(value)
    }
    
    public init(stringLiteral value: String) {
        self = .stringValue(value)
    }
}


// MARK: Useful Getters

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


// MARK: Encoding

public protocol JSONEncodable {
    var JSONValue: JSON { get }
}

extension JSON {
    public init<T: JSONEncodable>(_ value: T) {
        self = value.JSONValue
    }
    
    public init<T: Collection>(_ value: T) where T.Iterator.Element: JSONEncodable {
        self = .arrayValue(value.map{.some($0.JSONValue)})
    }

    public init<T: Collection, E: JSONEncodable>(_ value: T) where T.Iterator.Element == E? {
        self = .arrayValue(value.map{$0?.JSONValue})
    }
    
    public init<T: JSONEncodable>(_ value: [String: T]) {
        self = .dictionaryValue(Dictionary(elements: value.map { ($0, .some($1.JSONValue)) }))
    }
    
    public init<T: JSONEncodable>(_ value: [String: T?]) {
        self = .dictionaryValue(Dictionary(elements: value.map { ($0, $1?.JSONValue) }))
    }
}

extension JSON: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public init(arrayLiteral elements: JSONEncodable?...) {
        self = .arrayValue(elements.map { $0?.JSONValue })
    }
    
    public init(dictionaryLiteral elements: (String, JSONEncodable?)...) {
        self = .dictionaryValue([String: JSON?](elements: elements.map { (key, value) in
            return (key, value?.JSONValue)
        }))
    }
}


// MARK: Decoding

public protocol JSONDecodable {
    init?(JSONValue: JSON)
}

extension JSON {
    public func decode<T: JSONDecodable>() -> T? {
        return T(JSONValue: self)
    }
    
    public func decode<W: RawRepresentable>() -> W? where W.RawValue: JSONDecodable {
        return W.RawValue(JSONValue: self).flatMap{W(rawValue: $0)}
    }
    
    public func decode<T: JSONDecodable>() -> [T?]? {
        return self.arrayValue?.map{$0.flatMap{T(JSONValue: $0)}}
    }
    
    public func decode<T: JSONDecodable>() -> [T]? {
        return self.decode()?.filter{$0 != nil}.map{$0!}
    }
    
    public func decode<V: JSONDecodable>() -> [String: V?]? {
        if let dictionaryValue = self.dictionaryValue {
            return [String: V?](elements: dictionaryValue.map{($0, $1.flatMap{V(JSONValue: $0)})})
        } else {
            return nil
        }
    }
    
    public func decode<V: JSONDecodable>() -> [String: V]? {
        if let dictionaryValue = self.dictionaryValue {
            return [String: V](elements: dictionaryValue.map{($0, $1.flatMap{V(JSONValue: $0)})}.filter{$1 != nil}.map{($0, $1!)})
        } else {
            return nil
        }
    }
}


// MARK: Encoding & Decoding Conformance For Basic Types

extension JSON: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        self = JSONValue
    }
    
    public var JSONValue: JSON {
        return self
    }
}

extension Bool: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .boolValue(v):                 self = v
        case let .numberValue(.intValue(v)):    self = Bool(v)
        case let .numberValue(.floatValue(v)):  self = Bool(v)
        case let .numberValue(.doubleValue(v)): self = Bool(v)
        default: return nil
        }
    }
    
    public var JSONValue: JSON {
        return .boolValue(self)
    }
}

private extension String {
    func toNumber() -> Int? {
        var v: Int = 0
        if Scanner(string: self).scanInt(&v) {
            return v
        }
        return nil
    }
    
    func toNumber() -> Float? {
        var v: Float = 0
        if Scanner(string: self).scanFloat(&v) {
            return v
        }
        return nil
    }
    
    func toNumber() -> Double? {
        var v: Double = 0
        if Scanner(string: self).scanDouble(&v) {
            return v
        }
        return nil
    }
}

extension Int: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .numberValue(.intValue(v)):    self = v
        case let .numberValue(.floatValue(v)):  self = Int(v)
        case let .numberValue(.doubleValue(v)): self = Int(v)
        
        case let .stringValue(v):
            if let v: Int = v.toNumber() {
                self = v
            } else {
                return nil
            }

        default:
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .numberValue(.intValue(self))
    }
}

extension Float: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .numberValue(.intValue(v)):    self = Float(v)
        case let .numberValue(.floatValue(v)):  self = v
        case let .numberValue(.doubleValue(v)): self = Float(v)
        
        case let .stringValue(v):
            if let v: Float = v.toNumber() {
                self = v
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .numberValue(.floatValue(self))
    }
}

extension Double: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .numberValue(.intValue(v)):    self = Double(v)
        case let .numberValue(.floatValue(v)):  self = Double(v)
        case let .numberValue(.doubleValue(v)): self = v
        
        case let .stringValue(v):
            if let v: Double = v.toNumber() {
                self = v
            } else {
                return nil
            }
        
        default:
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .numberValue(.doubleValue(self))
    }
}

extension String: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .stringValue(v):
            self = v
        default:
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .stringValue(self)
    }
}


// MARK: Descriptions

extension JSON.Number: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .intValue(v): return v.description
        case let .floatValue(v): return v.description
        case let .doubleValue(v): return v.description
        }
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .boolValue(v): return v.description
        case let .numberValue(v): return v.description
        case let .stringValue(v): return v
        case let .arrayValue(v): return "[" + v.map{$0?.description ?? "nil"}.joined(separator: ", ") + "]"
        case let .dictionaryValue(v): return "[" + v.map{"\($0.0): " + ($0.1?.description ?? "nil")}.joined(separator: ", ") + "]"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case let .boolValue(v): return v.description
        case let .numberValue(v): return v.description
        case let .stringValue(v): return v.debugDescription
        case let .arrayValue(v): return "[" + v.map{$0.debugDescription}.joined(separator: ", ") + "]"
        case let .dictionaryValue(v): return "[" + v.map{"\($0.0.debugDescription): \($0.1.debugDescription)"}.joined(separator: ", ") + "]"
        }
    }
}


// MARK: Helpers

private extension Dictionary {
     init(elements: [Element]) {
        self = elements.reduce([Key: Value]()) {(dict, pair) in
            var dict = dict
            dict[pair.0] = pair.1
            return dict
        }
    }
}

private extension Int {
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}

private extension Float {
    init(_ bool: Bool) {
        self = bool ? 1.0 : 0.0
    }
}

private extension Double {
    init(_ bool: Bool) {
        self = bool ? 1.0 : 0.0
    }
}

private extension Bool {
    init(_ int: Int) {
        self = int != 0
    }
    init(_ float: Float) {
        self = float != 0.0
    }
    init(_ double: Double) {
        self = double != 0.0
    }
}
