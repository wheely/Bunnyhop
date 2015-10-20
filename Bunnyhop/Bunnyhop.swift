//
//  Bunnyhop.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 16/01/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import Foundation


public enum JSON: Equatable {
    public enum Number: Equatable {
        case IntValue(Int)
        case FloatValue(Float)
        case DoubleValue(Double)
    }
    
    case BoolValue(Bool)
    case NumberValue(Number)
    case StringValue(String)
    case ArrayValue([JSON?])
    case DictionaryValue([String: JSON?])
}


public func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
    switch (lhs, rhs) {
    case let (.IntValue(l),    .IntValue(r))    where l == r:         return true
    case let (.IntValue(l),    .FloatValue(r))  where Float(l) == r:  return true
    case let (.IntValue(l),    .DoubleValue(r)) where Double(l) == r: return true
    
    case let (.FloatValue(l),  .IntValue(r))    where l == Float(r):  return true
    case let (.FloatValue(l),  .FloatValue(r))  where l == r:         return true
    case let (.FloatValue(l),  .DoubleValue(r)) where Double(l) == r: return true
    
    case let (.DoubleValue(l), .IntValue(r))    where l == Double(r): return true
    case let (.DoubleValue(l), .FloatValue(r))  where l == Double(r): return true
    case let (.DoubleValue(l), .DoubleValue(r)) where l == r:         return true
        
    default: return false
    }
}


public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case let (.BoolValue(l), .BoolValue(r))                 where l == r:          return true
    case let (.BoolValue(l), .NumberValue(.IntValue(r)))    where Int(l) == r:     return true
    case let (.BoolValue(l), .NumberValue(.FloatValue(r)))  where Float(l) == r:   return true
    case let (.BoolValue(l), .NumberValue(.DoubleValue(r))) where Double(l) == r:  return true
    case let (.NumberValue(.IntValue(l)),    .BoolValue(r)) where l == Int(r):     return true
    case let (.NumberValue(.FloatValue(l)),  .BoolValue(r)) where l == Float(r):   return true
    case let (.NumberValue(.DoubleValue(l)), .BoolValue(r)) where l == Double(r):  return true

    case let (.NumberValue(l),     .NumberValue(r))         where l == r:          return true
    case let (.StringValue(l),     .StringValue(r))         where l == r:          return true
    case let (.ArrayValue(l),      .ArrayValue(r))          where l.elementsEqual(r, isEquivalent: ==): return true
    case let (.DictionaryValue(l), .DictionaryValue(r))     where l.elementsEqual(r) {$0.0.0 == $0.1.0 && $0.0.1 == $0.1.1}: return true
    
    default: return false
    }
}


// MARK: LiteralConvertible Initializers

extension JSON: BooleanLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible, UnicodeScalarLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, StringLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = .BoolValue(value)
    }
    
    public init(integerLiteral value: Int) {
        self = .NumberValue(Number.IntValue(value))
    }
    
    public init(floatLiteral value: Float) {
        self = .NumberValue(Number.FloatValue(value))
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .StringValue(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .StringValue(value)
    }
    
    public init(stringLiteral value: String) {
        self = .StringValue(value)
    }
}


// MARK: Useful Getters

public extension JSON {
    public var arrayValue: [JSON?]? {
        switch self {
        case let .ArrayValue(v):
            return v
        default:
            return nil
        }
    }
    
    public subscript (index: Int) -> JSON? {
        if let array = arrayValue where index <= array.endIndex {
            return array[index]
        } else {
            return nil
        }
    }
    
    public var dictionaryValue: [String: JSON?]? {
        switch self {
        case let .DictionaryValue(v):
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
    
    public init<T: CollectionType where T.Generator.Element: JSONEncodable>(_ value: T) {
        self = .ArrayValue(value.map{.Some($0.JSONValue)})
    }

    public init<T: CollectionType, E: JSONEncodable where T.Generator.Element == E?>(_ value: T) {
        self = .ArrayValue(value.map{$0?.JSONValue})
    }
    
    public init<T: JSONEncodable>(_ value: [String: T]) {
        self = .DictionaryValue(Dictionary(elements: value.map { ($0, .Some($1.JSONValue)) }))
    }
    
    public init<T: JSONEncodable>(_ value: [String: T?]) {
        self = .DictionaryValue(Dictionary(elements: value.map { ($0, $1?.JSONValue) }))
    }
}

extension JSON: ArrayLiteralConvertible, DictionaryLiteralConvertible {
    public init(arrayLiteral elements: JSONEncodable?...) {
        self = .ArrayValue(elements.map { $0?.JSONValue })
    }
    
    public init(dictionaryLiteral elements: (String, JSONEncodable?)...) {
        self = .DictionaryValue([String: JSON?](elements: elements.map { (key, value) in
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
    
    public func decode<W: RawRepresentable where W.RawValue: JSONDecodable>() -> W? {
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
        case let .BoolValue(v):                 self = v
        case let .NumberValue(.IntValue(v)):    self = Bool(v)
        case let .NumberValue(.FloatValue(v)):  self = Bool(v)
        case let .NumberValue(.DoubleValue(v)): self = Bool(v)
        default: return nil
        }
    }
    
    public var JSONValue: JSON {
        return .BoolValue(self)
    }
}

private extension String {
    func toNumber() -> Int? {
        var v: Int = 0
        if NSScanner(string: self).scanInteger(&v) {
            return v
        }
        return nil
    }
    
    func toNumber() -> Float? {
        var v: Float = 0
        if NSScanner(string: self).scanFloat(&v) {
            return v
        }
        return nil
    }
    
    func toNumber() -> Double? {
        var v: Double = 0
        if NSScanner(string: self).scanDouble(&v) {
            return v
        }
        return nil
    }
}

extension Int: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .NumberValue(.IntValue(v)):    self = v
        case let .NumberValue(.FloatValue(v)):  self = Int(v)
        case let .NumberValue(.DoubleValue(v)): self = Int(v)
        
        case let .StringValue(v):
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
        return .NumberValue(.IntValue(self))
    }
}

extension Float: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .NumberValue(.IntValue(v)):    self = Float(v)
        case let .NumberValue(.FloatValue(v)):  self = v
        case let .NumberValue(.DoubleValue(v)): self = Float(v)
        
        case let .StringValue(v):
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
        return .NumberValue(.FloatValue(self))
    }
}

extension Double: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .NumberValue(.IntValue(v)):    self = Double(v)
        case let .NumberValue(.FloatValue(v)):  self = Double(v)
        case let .NumberValue(.DoubleValue(v)): self = v
        
        case let .StringValue(v):
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
        return .NumberValue(.DoubleValue(self))
    }
}

extension String: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        switch JSONValue {
        case let .StringValue(v):
            self = v
        default:
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .StringValue(self)
    }
}


// MARK: Descriptions

extension JSON.Number: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .IntValue(v): return v.description
        case let .FloatValue(v): return v.description
        case let .DoubleValue(v): return v.description
        }
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .BoolValue(v): return v.description
        case let .NumberValue(v): return v.description
        case let .StringValue(v): return v
        case let .ArrayValue(v): return "[" + v.map{$0?.description ?? "nil"}.joinWithSeparator(", ") + "]"
        case let .DictionaryValue(v): return "[" + v.map{"\($0.0): " + ($0.1?.description ?? "nil")}.joinWithSeparator(", ") + "]"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case let .BoolValue(v): return v.description
        case let .NumberValue(v): return v.description
        case let .StringValue(v): return v.debugDescription
        case let .ArrayValue(v): return "[" + v.map{$0.debugDescription}.joinWithSeparator(", ") + "]"
        case let .DictionaryValue(v): return "[" + v.map{"\($0.0.debugDescription): \($0.1.debugDescription)"}.joinWithSeparator(", ") + "]"
        }
    }
}


// MARK: Helpers

extension Dictionary {
    private init(elements: [Element]) {
        self = elements.reduce([Key: Value]()) {(var dict, pair) in
            dict[pair.0] = pair.1
            return dict
        }
    }
}
