//
//  Float+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Float: JSONEncodable {
    public var json: JSON {
        return .numberValue(.floatValue(self))
    }
}

extension Float: JSONDecodable {
    
    public init?(json: JSON) {
        switch json {
        case let .numberValue(.intValue(v)):    self = Float(v)
        case let .numberValue(.floatValue(v)):  self = v
        case let .numberValue(.doubleValue(v)): self = Float(v)

        case let .stringValue(v):
            if let v = Float(v) {
                self = v
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
