//
//  Int+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Int: JSONEncodable {
    public var json: JSON {
        return .numberValue(.intValue(self))
    }
}

extension Int: JSONDecodable {
    
    public init?(json: JSON) {
        switch json {
        case let .numberValue(.intValue(v)):    self = v
        case let .numberValue(.floatValue(v)):  self = Int(v)
        case let .numberValue(.doubleValue(v)): self = Int(v)

        case let .stringValue(v):
            if let v = v.scanInt() {
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
    func scanInt() -> Int? {
        var v: Int = 0
        if Scanner(string: self).scanInt(&v) {
            return v
        }
        return nil
    }
}
