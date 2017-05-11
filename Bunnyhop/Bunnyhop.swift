//
//  Bunnyhop.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 16/01/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

public enum JSON {
    case boolValue(Bool)
    case numberValue(Number)
    case stringValue(String)
    case arrayValue([JSON?])
    case dictionaryValue([String: JSON?])
}

extension JSON {
    public enum Number {
        case intValue(Int)
        case floatValue(Float)
        case doubleValue(Double)
    }
}


// MARK: - Equatable

extension JSON.Number: Equatable {

    private static var decimalComparissonPrecision: Double {
        return 10e-6 // 0.000_001
    }

    private static func areEqualWithPrecision(_ lhs: Double, _ rhs: Double) -> Bool {
        return abs(lhs - rhs) < decimalComparissonPrecision
    }

    private static func areEqualWithPrecision(_ lhs: Float, _ rhs: Float) -> Bool {
        return abs(lhs - rhs) < Float(decimalComparissonPrecision)
    }

    public static func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
        switch (lhs, rhs) {
        case let (.intValue(l),    .intValue(r)):    return l == r
        case let (.intValue(l),    .floatValue(r)):  return areEqualWithPrecision(Float(l), r)
        case let (.intValue(l),    .doubleValue(r)): return areEqualWithPrecision(Double(l), r)

        case let (.floatValue(l),  .intValue(r)):    return areEqualWithPrecision(l, Float(r))
        case let (.floatValue(l),  .floatValue(r)):  return areEqualWithPrecision(l, r)
        case let (.floatValue(l),  .doubleValue(r)): return areEqualWithPrecision(Double(l), r)

        case let (.doubleValue(l), .intValue(r)):    return areEqualWithPrecision(l, Double(r))
        case let (.doubleValue(l), .floatValue(r)):  return areEqualWithPrecision(l, Double(r))
        case let (.doubleValue(l), .doubleValue(r)): return areEqualWithPrecision(l, r)
        }
    }
}

extension JSON: Equatable {

    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case let (.boolValue(l), .boolValue(r)):     return l == r
        case let (.numberValue(l), .numberValue(r)): return l == r
        case let (.stringValue(l), .stringValue(r)): return l == r

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


// MARK: - Encoding

public protocol JSONEncodable {
    var jsonValue: JSON { get }
}

extension JSON {
    public init<T: JSONEncodable>(_ value: T) {
        self = value.jsonValue
    }
    
    public init<T: JSONEncodable>(_ value: [T]) {
        self = .arrayValue(value.map { .some($0.jsonValue) })
    }

    public init<T: JSONEncodable>(_ value: [T?]) {
        self = .arrayValue(value.map { $0.map{ $0.jsonValue } })
    }
    
    public init(_ value: [JSONEncodable?]) {
        self = .arrayValue(value.map { $0.map{ $0.jsonValue } })
    }
    
    public init<T: JSONEncodable>(_ value: [String: T]) {
        self = .dictionaryValue(Dictionary(elements: value.map { ($0, .some($1.jsonValue)) }))
    }
    
    public init<T: JSONEncodable>(_ value: [String: T?]) {
        self = .dictionaryValue(Dictionary(elements: value.map { ($0, $1.map { $0.jsonValue }) }))
    }
    
    public init(_ value: [String: JSONEncodable?]) {
        self = .dictionaryValue(Dictionary(elements: value.map { ($0, $1.map { $0.jsonValue }) }))
    }
}

extension JSON: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public init(arrayLiteral elements: JSONEncodable?...) {
        self = .arrayValue(elements.map { $0.map { $0.jsonValue } })
    }

    public init(dictionaryLiteral elements: (String, JSONEncodable?)...) {
        self = .dictionaryValue(Dictionary(elements: elements.map { ($0, $1.map { $0.jsonValue }) } ))
    }
}


// MARK: - Decoding

public protocol JSONDecodable {
    init(jsonValue: JSON) throws
}

public protocol JSONDecoder {
    func decode() throws -> JSON?
    func wrapError(_ error: JSON.DecodingError) -> JSON.DecodingError
}

extension JSON {
    public enum DecodingError: Error {
        case typeMismatch(whileDecoding: Any.Type, from: JSON) // Expecting different type of JSON value
        case missingValue            // Trying to decode Optional<JSON>.None to some non-optional JSONDecodable type
        case containsNilElement       // Trying to decode [JSON?] or [String: JSON?] which contains nil into [JSONDecodable] or [String: JSONDecodable]
        indirect case keyError(String, DecodingError) // Error when decoding value for specific key in .DictionaryValue
    }
}

extension JSON.DecodingError: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .typeMismatch(type, jsonValue):
            return "Can't initialize \(type) with \(jsonValue.debugDescription)"
        case .missingValue:
            return "Missing value"
        case .containsNilElement:
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
            case .containsNilElement: return "{ContainsNilElement}"
            case let .keyError(key, error): return "{KeyError(key: \"\(key)\", error: \(error.debugDescription))}"
        }
    }
}

extension JSONDecoder {
    public func decode() throws -> JSON {
        guard let jsonValue: JSON = try decode() else {
            throw wrapError(.missingValue)
        }
        return jsonValue
    }
    

    // MARK: Decoding Non-Optionals
    
    public func decode<T: JSONDecodable>() throws -> T {
        let jsonValue: JSON = try decode()
        do {
            return try T(jsonValue: jsonValue)
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.DecodingError) throws -> T?)? = nil) throws -> [T?] {
        let jsonValue: JSON = try decode()
        guard case let .arrayValue(arrayValue) = jsonValue else {
            throw wrapError(JSON.DecodingError.typeMismatch(whileDecoding: [T?].self, from: jsonValue))
        }
        do {
            if let recoverer = recoverer {
                return try arrayValue.map {
                    if let jsonValue = $0 {
                        do {
                            return try jsonValue.decode()
                        } catch let error as JSON.DecodingError {
                            return try recoverer(jsonValue, error)
                        }
                    } else {
                        return nil
                    }
                }
            } else {
                return try arrayValue.map { try $0.map { try $0.decode() } }
            }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.DecodingError) throws -> T?)? = nil) throws -> [T] {
        let jsonValue: JSON = try decode()
        guard case let .arrayValue(arrayValue) = jsonValue else {
            throw wrapError(JSON.DecodingError.typeMismatch(whileDecoding: [T].self, from: jsonValue))
        }
        do {
            if let recoverer = recoverer {
                return try arrayValue.reduce([]) { (elements, jsonValue) in
                    var elements = elements
                    if let jsonValue = jsonValue {
                        do {
                            elements.append(try jsonValue.decode())
                        } catch let error as JSON.DecodingError {
                            if let recoveredValue = try recoverer(jsonValue, error) {
                                elements.append(recoveredValue)
                            }
                        }
                    } else if let recoveredValue = try recoverer(nil, .containsNilElement) {
                        elements.append(recoveredValue)
                    }
                    return elements
                }
            } else {
                return try arrayValue.map {
                    guard let jsonValue = $0 else {
                        throw JSON.DecodingError.containsNilElement
                    }
                    return try jsonValue.decode()
                }
            }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.DecodingError) throws -> T?)? = nil) throws -> [String: T?] {
        let jsonValue: JSON = try decode()
        guard case let .dictionaryValue(dictionaryValue) = jsonValue else {
            throw wrapError(JSON.DecodingError.typeMismatch(whileDecoding: [String: T?].self, from: jsonValue))
        }
        do {
            if let recoverer = recoverer {
                return Dictionary(elements: try dictionaryValue.map { ($0, try $1.flatMap {
                    do {
                        return try $0.decode()
                    } catch let error as JSON.DecodingError {
                        return try recoverer($0, error)
                    }
                }) })
            } else {
                return Dictionary(elements: try dictionaryValue.map { ($0, try $1.map { try $0.decode() }) })
            }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.DecodingError) throws -> T?)? = nil) throws -> [String: T] {
        let jsonValue: JSON = try decode()
        guard case let .dictionaryValue(dictionaryValue) = jsonValue else {
            throw wrapError(JSON.DecodingError.typeMismatch(whileDecoding: [String: T].self, from: jsonValue))
        }
        do {
            if let recoverer = recoverer {
                return Dictionary(elements: try dictionaryValue.reduce([]) { (elements, pair) in
                    var elements = elements
                    let (key, jsonValue) = pair
                    if let jsonValue = jsonValue{
                        do {
                            elements.append((key, try jsonValue.decode()))
                        } catch let error as JSON.DecodingError {
                            if let recoveredValue = try recoverer(jsonValue, error) {
                                elements.append((key, recoveredValue))
                            }
                        }
                    } else if let recoveredValue = try recoverer(nil, .containsNilElement) {
                        elements.append((key, recoveredValue))
                    }
                    return elements
                })
            } else {
                return Dictionary(elements: try dictionaryValue.map { key, jsonValue in
                    guard let jsonValue = jsonValue else {
                        throw JSON.DecodingError.containsNilElement
                    }
                    return (key, try jsonValue.decode())
                })
            }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    
    // MARK: Decoding Optionals
    
    public func decode<T: JSONDecodable>() throws -> T? {
        let jsonValue: JSON? = try decode()
        do {
            return try jsonValue.map { try $0.decode() }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.DecodingError) throws -> T?)? = nil) throws -> [T?]? {
        let jsonValue: JSON? = try decode()
        do {
            return try jsonValue.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.DecodingError) throws -> T?)? = nil) throws -> [T]? {
        let jsonValue: JSON? = try decode()
        do {
            return try jsonValue.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON, JSON.DecodingError) throws -> T?)? = nil) throws -> [String: T?]? {
        let jsonValue: JSON? = try decode()
        do {
            return try jsonValue.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
    
    public func decode<T: JSONDecodable>(elementRecoverer recoverer: ((JSON?, JSON.DecodingError) throws -> T?)? = nil) throws -> [String: T]? {
        let jsonValue: JSON? = try decode()
        do {
            return try jsonValue.map { try $0.decode(elementRecoverer: recoverer) }
        } catch let error as JSON.DecodingError {
            throw wrapError(error)
        }
    }
}

extension JSON {
    public struct KeyedValue {
        fileprivate let container: JSONDecoder
        fileprivate let key: String
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
    
    public func wrapError(_ error: JSON.DecodingError) -> JSON.DecodingError {
        return error
    }
}

extension JSON.KeyedValue: JSONDecoder {
    public func decode() throws -> JSON? {
        return try container.decode()[key] ?? nil
    }
    
    public func wrapError(_ error: JSON.DecodingError) -> JSON.DecodingError {
        return JSON.DecodingError.keyError(key, container.wrapError(error))
    }
}


// MARK: - Encoding & Decoding Conformance For Basic Types

extension JSON: JSONDecodable, JSONEncodable {
    public init(jsonValue: JSON) {
        self = jsonValue
    }
    
    public var jsonValue: JSON {
        return self
    }
}

extension Bool: JSONDecodable, JSONEncodable {
    public init(jsonValue: JSON) throws {
        if case let .boolValue(bool) = jsonValue {
            self = bool
        } else {
            throw JSON.DecodingError.typeMismatch(whileDecoding: Bool.self, from: jsonValue)
        }
    }
    
    public var jsonValue: JSON {
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
    public init(jsonValue: JSON) throws {
        switch jsonValue {
        case let .numberValue(.intValue(v)):    self = v
        case let .numberValue(.floatValue(v)):  self = Int(v)
        case let .numberValue(.doubleValue(v)): self = Int(v)
        
        case let .stringValue(v):
            if let v: Int = v.toNumber() {
                self = v
            } else {
                throw JSON.DecodingError.typeMismatch(whileDecoding: Int.self, from: jsonValue)
            }

        default:
            throw JSON.DecodingError.typeMismatch(whileDecoding: Int.self, from: jsonValue)
        }
    }
    
    public var jsonValue: JSON {
        return .numberValue(.intValue(self))
    }
}

extension Float: JSONDecodable, JSONEncodable {
    public init(jsonValue: JSON) throws {
        switch jsonValue {
        case let .numberValue(.intValue(v)):    self = Float(v)
        case let .numberValue(.floatValue(v)):  self = v
        case let .numberValue(.doubleValue(v)): self = Float(v)
        
        case let .stringValue(v):
            if let v: Float = v.toNumber() {
                self = v
            } else {
                throw JSON.DecodingError.typeMismatch(whileDecoding: Float.self, from: jsonValue)
            }
            
        default:
            throw JSON.DecodingError.typeMismatch(whileDecoding: Float.self, from: jsonValue)
        }
    }
    
    public var jsonValue: JSON {
        return .numberValue(.floatValue(self))
    }
}

extension Double: JSONDecodable, JSONEncodable {
    public init(jsonValue: JSON) throws {
        switch jsonValue {
        case let .numberValue(.intValue(v)):    self = Double(v)
        case let .numberValue(.floatValue(v)):  self = Double(v)
        case let .numberValue(.doubleValue(v)): self = v
        
        case let .stringValue(v):
            if let v: Double = v.toNumber() {
                self = v
            } else {
                throw JSON.DecodingError.typeMismatch(whileDecoding: Double.self, from: jsonValue)
            }
        
        default:
            throw JSON.DecodingError.typeMismatch(whileDecoding: Double.self, from: jsonValue)
        }
    }
    
    public var jsonValue: JSON {
        return .numberValue(.doubleValue(self))
    }
}

extension String: JSONDecodable, JSONEncodable {
    public init(jsonValue: JSON) throws {
        switch jsonValue {
        case let .stringValue(v):
            self = v
        default:
            throw JSON.DecodingError.typeMismatch(whileDecoding: String.self, from: jsonValue)
        }
    }
    
    public var jsonValue: JSON {
        return .stringValue(self)
    }
}


// MARK: - CustomStringConvertible

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


// MARK: - Helpers

extension Dictionary {

    init(elements: [Element]) {
        var dictionary: [Key: Value] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = dictionary
    }
}
