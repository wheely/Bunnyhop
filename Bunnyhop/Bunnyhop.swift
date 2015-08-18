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
    
    case Nothing
    case BoolValue(Bool)
    case NumberValue(Number)
    case StringValue(String)
    case ArrayValue([JSON])
    case DictionaryValue([String: JSON])
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
    case let (.Nothing, .Nothing): return true
    
    case let (.BoolValue(l), .BoolValue(r))                 where l == r:         return true
    case let (.BoolValue(l), .NumberValue(.IntValue(r)))    where Int(l) == r:    return true
    case let (.BoolValue(l), .NumberValue(.FloatValue(r)))  where Float(l) == r:  return true
    case let (.BoolValue(l), .NumberValue(.DoubleValue(r))) where Double(l) == r: return true
    case let (.NumberValue(.IntValue(l)),    .BoolValue(r)) where l == Int(r):    return true
    case let (.NumberValue(.FloatValue(l)),  .BoolValue(r)) where l == Float(r):  return true
    case let (.NumberValue(.DoubleValue(l)), .BoolValue(r)) where l == Double(r): return true

    case let (.NumberValue(l),     .NumberValue(r))         where l == r:         return true
    case let (.StringValue(l),     .StringValue(r))         where l == r:         return true
    case let (.ArrayValue(l),      .ArrayValue(r))          where l == r:         return true
    case let (.DictionaryValue(l), .DictionaryValue(r))     where l == r:         return true
    
    default: return false
    }
}


// MARK: Convenience Initializers

extension JSON.Number: IntegerLiteralConvertible, FloatLiteralConvertible {
    public init(_ value: Int) {
        self = .IntValue(value)
    }
    
    public init(integerLiteral value: Int) {
        self.init(value)
    }
    
    public init(_ value: Float) {
        self = .FloatValue(value)
    }
    
    public init(floatLiteral value: Float) {
        self.init(value)
    }
    
    public init(_ value: Double) {
        self = .DoubleValue(value)
    }
}

extension JSON: NilLiteralConvertible, BooleanLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible, UnicodeScalarLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, StringLiteralConvertible, ArrayLiteralConvertible, DictionaryLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .Nothing
    }
    
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
    
    public init(integerLiteral value: Int) {
        self.init(value)
    }
    
    public init(floatLiteral value: Float) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(_ value: [JSON]) {
        self = .ArrayValue(value)
    }
    
    public init(arrayLiteral elements: JSON...) {
        self.init(elements)
    }
    
    public init(_ value: [String: JSON]) {
        self = .DictionaryValue(value)
    }
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self.init(elements.reduce([String: JSON]()) {(var d, pair) in d[pair.0] = pair.1; return d})
    }
}


// MARK: Useful getters

public extension JSON {
    public var arrayValue: [JSON]? {
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
    
    public var dictionaryValue: [String: JSON]? {
        switch self {
        case let .DictionaryValue(v):
            return v
        default:
            return nil
        }
    }
    
    public subscript (key: String) -> JSON? {
        return dictionaryValue?[key]
    }
}


// MARK: Coding & Decoding

public protocol JSONEncodable {
    var JSONValue: JSON { get }
}

public protocol JSONDecodable {
    init?(JSONValue: JSON)
}

public extension JSON {
    public init<T: JSONEncodable>(_ value: T) {
        self = value.JSONValue
    }
    
    public init<C: CollectionType where C.Generator.Element : JSONEncodable>(_ valueCollection: C) {
        self.init(map(valueCollection){$0.JSONValue})
    }
    
    public func decode<T: JSONDecodable>() -> T? {
        return T(JSONValue: self)
    }
    
    public func decode<W: RawRepresentable where W.RawValue: JSONDecodable>() -> W? {
        return W.RawValue(JSONValue: self).flatMap { W(rawValue: $0) }
    }
    
    public func decode<T: JSONDecodable>() -> [T?]? {
        return self.arrayValue?.map{T(JSONValue: $0)}
    }
    
    public func decode<T: JSONDecodable>() -> [T]? {
        return self.decode()?.filter{$0 != nil}.map {$0!}
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

extension JSON.Number: Printable {
    public var description: String {
        switch self {
        case let .IntValue(v): return v.description
        case let .FloatValue(v): return v.description
        case let .DoubleValue(v): return v.description
        }
    }
}

extension JSON: Printable, DebugPrintable {
    public var description: String {
        switch self {
        case .Nothing: return "nil"
        case let .BoolValue(v): return v.description
        case let .NumberValue(v): return v.description
        case let .StringValue(v): return v
        case let .ArrayValue(v): return "[" + ", ".join(v.map{$0.description}) + "]"
        case let .DictionaryValue(v): return "[" + ", ".join(map(v){"\($0.0): \($0.1.description)"}) + "]"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .Nothing: return "{None}"
        case let .BoolValue(v): return v.description
        case let .NumberValue(v): return v.description
        case let .StringValue(v): return v.debugDescription
        case let .ArrayValue(v): return "[" + ", ".join(v.map{$0.debugDescription}) + "]"
        case let .DictionaryValue(v): return "[" + ", ".join(map(v){"\($0.0.debugDescription): \($0.1.debugDescription)"}) + "]"
        }
    }
}


