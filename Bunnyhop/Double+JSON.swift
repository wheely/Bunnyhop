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
            if let v = v.scanDouble() {
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

    func scanDouble() -> Double? {
        var v: Double = 0
        if Scanner(string: self).scanDouble(&v) {
            return v
        }
        return nil
    }
}
