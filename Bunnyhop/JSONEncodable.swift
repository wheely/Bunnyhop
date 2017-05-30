public protocol JSONEncodable {
    var json: JSON { get }
}


// MARK: - JSON Conformance

extension JSON: JSONEncodable {
    public var json: JSON {
        return self
    }
}


// MARK: - JSON Initialization With JSONEncodable

extension JSON {
    
    public init<T: JSONEncodable>(_ value: T) {
        self = value.json
    }

    public init<T: Collection>(_ value: T) where T.Iterator.Element: JSONEncodable {
        self = .arrayValue(value.map { .some($0.json) })
    }

    public init<T: Collection, E: JSONEncodable>(_ value: T) where T.Iterator.Element == E? {
        self = .arrayValue(value.map { $0?.json })
    }

    public init<T: JSONEncodable>(_ elements: [String: T]) {
        self = .dictionaryValue(Dictionary(elements: elements.map { ($0, .some($1.json)) }))
    }

    public init<T: JSONEncodable>(_ elements: [String: T?]) {
        self = .dictionaryValue(Dictionary(elements: elements.map { ($0, $1?.json) }))
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONEncodable?...) {
        self = .arrayValue(elements.map { $0?.json })
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONEncodable?)...) {
        self = .dictionaryValue(Dictionary(elements: elements.map { ($0, $1?.json) }))
    }
}
