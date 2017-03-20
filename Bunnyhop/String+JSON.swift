//
//  String+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension String: JSONEncodable {
    public var jsonValue: JSON {
        return .stringValue(self)
    }
}

extension String: JSONDecodable {

    public init?(jsonValue: JSON) {
        switch jsonValue {
        case let .stringValue(v):
            self = v
        default:
            return nil
        }
    }
}
