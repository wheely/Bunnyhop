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
        if case let .arrayValue(array) = self {
            return array
        } else {
            return nil
        }
    }

    public subscript (index: Int) -> JSON? {
        if let array = arrayValue, array.indices.contains(index) {
            return array[index]
        } else {
            return nil
        }
    }

    public var dictionaryValue: [String: JSON?]? {
        if case let .dictionaryValue(dictionary) = self {
            return dictionary
        } else {
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


// MARK: - Printing

extension JSON: CustomStringConvertible {

    public var description: String {
        switch self {
        case let .boolValue(bool):
            return bool.description
        case let .numberValue(number):
            return number.description
        case let .stringValue(string):
            return string

        case let .arrayValue(array):
            return "[\(array.map { $0?.description ?? "nil" }.joined(separator: ", "))]"

        case let .dictionaryValue(dictionary):
            return "[\(dictionary.map { "\($0): " + ($1?.description ?? "nil") }.joined(separator: ", "))]"
        }
    }
}

extension JSON: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case let .boolValue(bool):
            return bool.description
        case let .numberValue(number):
            return number.description
        case let .stringValue(string):
            return string.debugDescription

        case let .arrayValue(array):
            return "["
                + array
                    .map { $0.debugDescription }
                    .joined(separator: ", ")
                + "]"

        case let .dictionaryValue(dictionary):
            return "["
                + dictionary
                    .map { "\($0.debugDescription): \($1.debugDescription)" }
                    .joined(separator: ", ")
                + "]"
        }
    }
}
