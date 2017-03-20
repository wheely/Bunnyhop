//
//  Decoding.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

public protocol JSONDecodable {
    init?(jsonValue: JSON)
}


// MARK: - JSON+JSONDecodable

extension JSON: JSONDecodable {
    public init?(jsonValue: JSON) {
        self = jsonValue
    }
}


// MARK: - JSON decoding

extension JSON {

    public func decode<T: JSONDecodable>() -> T? {
        return T(jsonValue: self)
    }

    public func decode<W: RawRepresentable>() -> W? where W.RawValue: JSONDecodable {
        return W.RawValue(jsonValue: self).flatMap { W(rawValue: $0) }
    }

    public func decode<T: JSONDecodable>() -> [T?]? {
        return self.arrayValue?.map { $0.flatMap { T(jsonValue: $0) } }
    }

    public func decode<T: JSONDecodable>() -> [T]? {
        return self.decode()?.filter { $0 != nil }.map { $0! }
    }

    public func decode<V: JSONDecodable>() -> [String: V?]? {
        if let dictionaryValue = dictionaryValue {
            return Dictionary(elements: dictionaryValue.map { ($0, $1.flatMap { V(jsonValue: $0) }) })
        } else {
            return nil
        }
    }

    public func decode<V: JSONDecodable>() -> [String: V]? {
        if let dictionaryValue = dictionaryValue {
            return Dictionary(elements:
                dictionaryValue
                    .map { ($0, $1.flatMap { V(jsonValue: $0) }) }
                    .filter { $1 != nil }
                    .map { ($0, $1!) }
            )
        } else {
            return nil
        }
    }
}
