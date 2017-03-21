//
//  Bool+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Bool: JSONEncodable {
    public var json: JSON {
        return .boolValue(self)
    }
}

extension Bool: JSONDecodable {
    
    public init?(json: JSON) {
        if case let .boolValue(bool) = json {
            self = bool
        } else {
            return nil
        }
    }
}
