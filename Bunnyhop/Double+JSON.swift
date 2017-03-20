//
//  Double+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Double: JSONEncodable {
    public var json: JSON {
        return .numberValue(.doubleValue(self))
    }
}

extension Double: JSONDecodable {

    public init?(json: JSON) {
        switch json {
        case let .numberValue(.intValue(v)):    self = Double(v)
        case let .numberValue(.floatValue(v)):  self = Double(v)
        case let .numberValue(.doubleValue(v)): self = v

        case let .stringValue(v):
            if let v = Double(v) {
                self = v
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
