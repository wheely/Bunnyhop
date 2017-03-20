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
        switch json {
        case let .boolValue(v): self = v

        // TODO: Research whether Number-to-Bool conversions are actually needed.
        case let .numberValue(.intValue(v)):
            if let v = Bool(v) {
                self = v
            } else {
                return nil
            }
        case let .numberValue(.floatValue(v)):
            if let v = Bool(v) {
                self = v
            } else {
                return nil
            }
        case let .numberValue(.doubleValue(v)):
            if let v = Bool(v) {
                self = v
            } else {
                return nil
            }

        default: return nil
        }
    }
}


// MARK: - Bool from Number

private extension Bool {

    init?(_ int: Int) {
        switch int {
        case 0:
            self = false
        case 1:
            self = true
        default:
            return nil
        }
    }

    init?(_ float: Float) {
        switch float {
        case 0.0:
            self = false
        case 1.0:
            self = true
        default:
            return nil
        }
    }

    init?(_ double: Double) {
        switch double {
        case 0.0:
            self = false
        case 1.0:
            self = true
        default:
            return nil
        }
    }
}
