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
        if case let .stringValue(string) = json {
            self = string
        } else {
            return nil
        }
    }
}
