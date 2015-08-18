//
//  Bunnyhop+Foundation.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 18/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import Foundation


extension CGFloat: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        if let value: Double = JSONValue.decode() {
            self.init(value)
        } else {
            return nil
        }
    }
    
    public var JSONValue: JSON {
        return .NumberValue(.DoubleValue(Double(self)))
    }
}