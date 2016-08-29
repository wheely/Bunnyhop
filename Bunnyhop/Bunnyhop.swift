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
        case int(Int)
        case float(Float)
        case double(Double)
    }
    
    case bool(Bool)
    case number(Number)
    case string(String)
    case array([JSON?])
    case dictionary([String: JSON?])
}


public func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
    switch (lhs, rhs) {
    case let (.int(l),    .int(r))    where l == r:         return true
    case let (.int(l),    .float(r))  where Float(l) == r:  return true
    case let (.int(l),    .double(r)) where Double(l) == r: return true
    
    case let (.float(l),  .int(r))    where l == Float(r):  return true
    case let (.float(l),  .float(r))  where l == r:         return true
    case let (.float(l),  .double(r)) where Double(l) == r: return true
    
    case let (.double(l), .int(r))    where l == Double(r): return true
    case let (.double(l), .float(r))  where l == Double(r): return true
    case let (.double(l), .double(r)) where l == r:         return true
        
    default: return false
    }
}


public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case let (.bool(l), .bool(r))               where l == r:          return true
    case let (.bool(l), .number(.int(r)))       where Int(l) == r:     return true
    case let (.bool(l), .number(.float(r)))     where Float(l) == r:   return true
    case let (.bool(l), .number(.double(r)))    where Double(l) == r:  return true
    case let (.number(.int(l)),    .bool(r))    where l == Int(r):     return true
    case let (.number(.float(l)),  .bool(r))    where l == Float(r):   return true
    case let (.number(.double(l)), .bool(r))    where l == Double(r):  return true

    case let (.number(l),     .number(r))       where l == r:          return true
    case let (.string(l),     .string(r))       where l == r:          return true
    case let (.array(l),      .array(r))        where l.elementsEqual(r, isEquivalent: ==): return true
    case let (.dictionary(l), .dictionary(r))   where l.elementsEqual(r) { $0.0 == $1.0 && $0.1 == $1.1 }: return true
    
    default: return false
    }
}


// MARK: - LiteralConvertible Initializers

extension JSON: BooleanLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible,
    UnicodeScalarLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, StringLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
    
    public init(integerLiteral value: Int) {
        self = .number(.int(value))
    }
    
    public init(floatLiteral value: Float) {
        self = .number(.float(value))
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}


// MARK: - Encoding

public protocol JSONEncodable {
    var json: JSON { get }
}

extension Collection where Iterator.Element == Optional<JSONEncodable> {
    public var json: JSON {
        return .array(map { $0.map { $0.json } })
    }
}

extension Collection where Iterator.Element == (key: String, value: Optional<JSONEncodable>) {
    public var json: JSON {
        return .dictionary(Dictionary(elements: map { ($0, $1.map { $0.json }) }))
    }
}


// MARK: - Decoding

public protocol JSONDecodable {
    init(json: JSON) throws
}

public protocol JSONDecoder {
    func decode() throws -> JSON?
    func wrapError(_ error: JSON.Error) -> JSON.Error
}

extension JSON {
    public indirect enum Error: ErrorProtocol {
        case typeMismatch(whileDecoding: Any.Type, from: JSON) // Expecting different type of JSON value
        case missingValue            // Trying to decode Optional<JSON>.None to some non-optional JSONDecodable type
        case contansNilElement       // Trying to decode [JSON?] or [String: JSON?] which contains nil into [JSONDecodable] or [String: JSONDecodable]
        case keyError(String, Error) // Error when decoding value for specific key in .DictionaryValue
    }
}

extension JSON.Error: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .typeMismatch(type, json):
            return "Can't initialize \(type) with \(json.debugDescription)"
        case .missingValue:
            return "Missing value"
        case .contansNilElement:
            return "Contains nil element"
        case var .keyError(key, error):
            while true {
                switch error {
                case let .keyError(thisKey, thisError):
                    key = "\(thisKey).\(key)"
                    error = thisError
                default:
                    return "\(key): \(error.description)"
                }
            }
        }
    }
    
    public var debugDescription: String {
        switch self {
            case .typeMismatch: return "{TypeMismatch}"
            case .missingValue: return "{MissingValue}"
            case .contansNilElement: return "{ContansNilElement}"
            case let .keyError(key, error): return "{KeyError(key: \"\(key)\", error: \(error.debugDescription))}"
        }
    }
}

extension JSONDecoder {
    public func decode() throws -> JSON {
        guard let json: JSON = try decode() else {
            throw wrapError(.missingValue)
        }
        return json
    }
    

    // MARK: Decoding Non-Optionals
    
    public func decode<T: JSONDecodable>() throws -> T {
        let json: JSON = try decode()
        do {
            return try T(json: json)
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.Error) throws -> T?)? = nil) throws -> [T?] {
        let json: JSON = try decode()
        guard case let .array(value) = json else {
            throw wrapError(JSON.Error.typeMismatch(whileDecoding: [T?].self, from: json))
        }
        do {
            if let recoverer = recoverer {
                return try value.map {
                    if let json = $0 {
                        do {
                            return try json.decode()
                        } catch let error as JSON.Error {
                            return try recoverer(json, error)
                        }
                    } else {
                        return nil
                    }
                }
            } else {
                return try value.map { try $0.map { try $0.decode() } }
            }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.Error) throws -> T?)? = nil) throws -> [T] {
        let json: JSON = try decode()
        guard case let .array(value) = json else {
            throw wrapError(JSON.Error.typeMismatch(whileDecoding: [T].self, from: json))
        }
        do {
            if let recoverer = recoverer {
                return try value.reduce([]) { (elements, json) in
                    var newElements = elements
                    if let json = json {
                        do {
                            newElements.append(try json.decode())
                        } catch let error as JSON.Error {
                            if let recoveredValue = try recoverer(json, error) {
                                newElements.append(recoveredValue)
                            }
                        }
                    } else if let recoveredValue = try recoverer(nil, .contansNilElement) {
                        newElements.append(recoveredValue)
                    }
                    return newElements
                }
            } else {
                return try value.map {
                    guard let json = $0 else {
                        throw JSON.Error.contansNilElement
                    }
                    return try json.decode()
                }
            }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.Error) throws -> T?)? = nil) throws -> [String: T?] {
        let json: JSON = try decode()
        guard case let .dictionary(value) = json else {
            throw wrapError(JSON.Error.typeMismatch(whileDecoding: [String: T?].self, from: json))
        }
        do {
            if let recoverer = recoverer {
                return Dictionary(elements: try value.map { ($0, try $1.flatMap {
                    do {
                        return try $0.decode()
                    } catch let error as JSON.Error {
                        return try recoverer($0, error)
                    }
                }) })
            } else {
                return Dictionary(elements: try value.map { ($0, try $1.map { try $0.decode() }) })
            }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.Error) throws -> T?)? = nil) throws -> [String: T] {
        let json: JSON = try decode()
        guard case let .dictionary(value) = json else {
            throw wrapError(JSON.Error.typeMismatch(whileDecoding: [String: T].self, from: json))
        }
        do {
            if let recoverer = recoverer {
                return Dictionary(elements: try value.reduce([]) { (elements, pair) in
                    let (key, json) = pair
                    var newElements = elements
                    if let json = json {
                        do {
                            newElements.append((key, try json.decode()))
                        } catch let error as JSON.Error {
                            if let recoveredValue = try recoverer(json, error) {
                                newElements.append((key, recoveredValue))
                            }
                        }
                    } else if let recoveredValue = try recoverer(nil, .contansNilElement) {
                        newElements.append((key, recoveredValue))
                    }
                    return newElements
                })
            } else {
                return Dictionary(elements: try value.map { key, json in
                    guard let json = json else {
                        throw JSON.Error.contansNilElement
                    }
                    return (key, try json.decode())
                })
            }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    
    // MARK: Decoding Optionals
    
    public func decode<T: JSONDecodable>() throws -> T? {
        let json: JSON? = try decode()
        do {
            return try json.map { try $0.decode() }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.Error) throws -> T?)? = nil) throws -> [T?]? {
        let json: JSON? = try decode()
        do {
            return try json.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.Error) throws -> T?)? = nil) throws -> [T]? {
        let json: JSON? = try decode()
        do {
            return try json.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.Error) throws -> T?)? = nil) throws -> [String: T?]? {
        let json: JSON? = try decode()
        do {
            return try json.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.Error) throws -> T?)? = nil) throws -> [String: T]? {
        let json: JSON? = try decode()
        do {
            return try json.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.Error {
            throw wrapError(error)
        }
    }
}

extension JSON {
    public struct KeyedValue {
        private let container: JSONDecoder
        private let key: String
    }
}

extension JSONDecoder {
    public subscript (key: String) -> JSON.KeyedValue {
        return JSON.KeyedValue(container: self, key: key)
    }
}


// MARK: - Conforming to JSONDecoder

extension JSON: JSONDecoder {
    public func decode() -> JSON? {
        return self
    }
    
    public func wrapError(_ error: JSON.Error) -> JSON.Error {
        return error
    }
}

extension JSON.KeyedValue: JSONDecoder {
    public func decode() throws -> JSON? {
        return try container.decode()[key] ?? nil
    }
    
    public func wrapError(_ error: JSON.Error) -> JSON.Error {
        return JSON.Error.keyError(key, container.wrapError(error))
    }
}


// MARK: - Encoding & Decoding Conformance For Basic Types

extension JSON: JSONDecodable, JSONEncodable {
    public init(json: JSON) {
        self = json
    }
    
    public var json: JSON {
        return self
    }
}

extension Bool: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        switch json {
        case let .bool(v):                 self = v
        case let .number(.int(v)):    self = Bool(v)
        case let .number(.float(v)):  self = Bool(v)
        case let .number(.double(v)): self = Bool(v)
        
        default: throw JSON.Error.typeMismatch(whileDecoding: Bool.self, from: json)
        }
    }
    
    public var json: JSON {
        return .bool(self)
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
    public init(json: JSON) throws {
        switch json {
        case let .number(.int(v)):    self = v
        case let .number(.float(v)):  self = Int(v)
        case let .number(.double(v)): self = Int(v)
        
        case let .string(v):
            if let v: Int = v.toNumber() {
                self = v
            } else {
                throw JSON.Error.typeMismatch(whileDecoding: Int.self, from: json)
            }

        default:
            throw JSON.Error.typeMismatch(whileDecoding: Int.self, from: json)
        }
    }
    
    public var json: JSON {
        return .number(.int(self))
    }
}

extension Float: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        switch json {
        case let .number(.int(v)):    self = Float(v)
        case let .number(.float(v)):  self = v
        case let .number(.double(v)): self = Float(v)
        
        case let .string(v):
            if let v: Float = v.toNumber() {
                self = v
            } else {
                throw JSON.Error.typeMismatch(whileDecoding: Float.self, from: json)
            }
            
        default:
            throw JSON.Error.typeMismatch(whileDecoding: Float.self, from: json)
        }
    }
    
    public var json: JSON {
        return .number(.float(self))
    }
}

extension Double: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        switch json {
        case let .number(.int(v)):    self = Double(v)
        case let .number(.float(v)):  self = Double(v)
        case let .number(.double(v)): self = v
        
        case let .string(v):
            if let v: Double = v.toNumber() {
                self = v
            } else {
                throw JSON.Error.typeMismatch(whileDecoding: Double.self, from: json)
            }
        
        default:
            throw JSON.Error.typeMismatch(whileDecoding: Double.self, from: json)
        }
    }
    
    public var json: JSON {
        return .number(.double(self))
    }
}

extension String: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        switch json {
        case let .string(v):
            self = v
        default:
            throw JSON.Error.typeMismatch(whileDecoding: String.self, from: json)
        }
    }
    
    public var json: JSON {
        return .string(self)
    }
}


// MARK: - CustomStringConvertible

extension JSON.Number: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .int(v): return v.description
        case let .float(v): return v.description
        case let .double(v): return v.description
        }
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .bool(v): return v.description
        case let .number(v): return v.description
        case let .string(v): return v
        case let .array(v): return "[" + v.map{$0?.description ?? "nil"}.joined(separator: ", ") + "]"
        case let .dictionary(v): return "[" + v.map{"\($0.0): " + ($0.1?.description ?? "nil")}.joined(separator: ", ") + "]"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case let .bool(v): return v.description
        case let .number(v): return v.description
        case let .string(v): return v.debugDescription
        case let .array(v): return "[" + v.map{$0.debugDescription}.joined(separator: ", ") + "]"
        case let .dictionary(v): return "[" + v.map{"\($0.0.debugDescription): \($0.1.debugDescription)"}.joined(separator: ", ") + "]"
        }
    }
}


// MARK: - Helpers

extension Dictionary {
    private init(elements: [Element]) {
        var dict = [Key: Value]()
        for e in elements {
            dict[e.key] = e.value
        }
        self = dict
    }
}
