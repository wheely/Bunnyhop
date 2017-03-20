//
//  String+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension String: JSONEncodable {
    public var json: JSON {
        return .stringValue(self)
    }
}

extension String: JSONDecodable {

    public init?(json: JSON) {
        switch json {
        case let .stringValue(v):
            self = v
        default:
            return nil
        }
    }
}
