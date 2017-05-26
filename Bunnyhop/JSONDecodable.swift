public protocol JSONDecodable {
    init?(json: JSON)
}


// MARK: - JSON Conformance

extension JSON: JSONDecodable {
    public init?(json: JSON) {
        self = json
    }
}


// MARK: - JSON Decoding

extension JSON {

    public func decode<T: JSONDecodable>() -> T? {
        return T(json: self)
    }

    public func decode<W: RawRepresentable>() -> W? where W.RawValue: JSONDecodable {
        return W.RawValue(json: self).flatMap { W(rawValue: $0) }
    }

    public func decode<T: JSONDecodable>() -> [T?]? {
        return self.arrayValue?.map { $0.flatMap { T(json: $0) } }
    }

    public func decode<T: JSONDecodable>() -> [T]? {
        return self.decode()?.filter { $0 != nil }.map { $0! }
    }

    public func decode<V: JSONDecodable>() -> [String: V?]? {
        if let dictionaryValue = dictionaryValue {
            return Dictionary(elements: dictionaryValue.map { ($0, $1.flatMap(V.init(json:))) })
        } else {
            return nil
        }
    }

    public func decode<V: JSONDecodable>() -> [String: V]? {
        if let dictionaryValue = dictionaryValue {
            return Dictionary(elements:
                dictionaryValue.flatMap { (key, value) in
                    value
                        .flatMap(V.init(json:))
                        .map { (key, $0) }
                }
            )
        } else {
            return nil
        }
    }
}
