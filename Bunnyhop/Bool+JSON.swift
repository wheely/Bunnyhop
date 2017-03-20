//
//  Bool+JSON.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Bool: JSONEncodable {
    public var jsonValue: JSON {
        return .boolValue(self)
    }
}

extension Bool: JSONDecodable {
    
    public init?(jsonValue: JSON) {
        switch jsonValue {
        case let .boolValue(v):                 self = v

        // TODO: Research whether Number-to-Bool conversions are actually needed.
        case let .numberValue(.intValue(v)):    self = Bool(v)
        case let .numberValue(.floatValue(v)):  self = Bool(v)
        case let .numberValue(.doubleValue(v)): self = Bool(v)
            
        default: return nil
        }
    }
}


// MARK: - Bool from Number

private extension Bool {

    init(_ int: Int) {
        self = int != 0
    }

    init(_ float: Float) {
        self = float != 0.0
    }

    init(_ double: Double) {
        self = double != 0.0
    }
}
