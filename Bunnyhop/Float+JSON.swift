//
//  Float+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Float: JSONEncodable {
    public var jsonValue: JSON {
        return .numberValue(.floatValue(self))
    }
}

extension Float: JSONDecodable {
    
    public init?(jsonValue: JSON) {
        switch jsonValue {
        case let .numberValue(.intValue(v)):    self = Float(v)
        case let .numberValue(.floatValue(v)):  self = v
        case let .numberValue(.doubleValue(v)): self = Float(v)

        case let .stringValue(v):
            if let v = v.scanFloat() {
                self = v
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}


// MARK: - Helpers

private extension String {

    func scanFloat() -> Float? {
        var v: Float = 0
        if Scanner(string: self).scanFloat(&v) {
            return v
        }
        return nil
    }
}
