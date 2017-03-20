//
//  Bunny.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

import Bunnyhop


struct Bunny {

    var name: String
    var numberOfLegs: Int

    init(name: String, legCount: Int) {
        self.name = name
        self.numberOfLegs = legCount
    }
}


// MARK: - JSON

private enum JSONKey {
    static let name = "name"
    static let numberOfLegs = "number_of_legs"
}

extension Bunny: JSONDecodable {

    var jsonValue: JSON {
        return [
            JSONKey.name: name,
            JSONKey.numberOfLegs: numberOfLegs
        ]
    }
}

extension Bunny: JSONEncodable {

    init?(jsonValue: JSON) {
        if let name: String = jsonValue[JSONKey.name]?.decode(),
            let legCount: Int = jsonValue[JSONKey.numberOfLegs]?.decode() {
            self.init(name: name, legCount: legCount)
        } else {
            return nil
        }
    }
}
