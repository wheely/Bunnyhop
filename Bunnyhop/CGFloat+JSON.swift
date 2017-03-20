//
//  Bunnyhop+UIKit.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 19/02/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

import UIKit


extension CGFloat: JSONEncodable {
    
    public var json: JSON {
        return .numberValue(.doubleValue(Double(self)))
    }
}

extension CGFloat: JSONDecodable {

    public init?(json: JSON) {
        if let value: Double = json.decode() {
            self.init(value)
        } else {
            return nil
        }
    }
}
