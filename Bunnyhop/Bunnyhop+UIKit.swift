//
//  Bunnyhop+UIKit.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 19/02/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

import UIKit


extension CGFloat: JSONDecodable, JSONEncodable {
    public init?(JSONValue: JSON) {
        if let value: Double = JSONValue.decode() {
            self.init(value)
        } else {
            return nil
        }
    }

    public var JSONValue: JSON {
        return .numberValue(.doubleValue(Double(self)))
    }
}
