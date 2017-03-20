//
//  BunnyhopTests.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

import XCTest
import Bunnyhop


class IdentityTests: XCTestCase {

    func testDecodingIdentity() {
        let bunny = Bunny(name: "bugz", legCount: 4)
        let recoveredBunny: Bunny = JSON(bunny).decode()!

        XCTAssertEqual(bunny.name, recoveredBunny.name, "Names should be equal")
        XCTAssertEqual(bunny.numberOfLegs, recoveredBunny.numberOfLegs, "Number of legs should be equal")
    }

    func testSerializationIdentity() {
        let jsonDictionary: [String: JSON?] = [
            "null": nil,
            "string": "wat",
            "integer": 69,
            "decimal": 6.9,
            "bool_true": true,
            "bool_false": false,
            "nested_array": [
                nil,
                "wat",
                69,
                6.9,
                true,
                false,
            ],
            "nested_dictionary": [
                "null": nil,
                "string": "wat",
                "integer": 69,
                "decimal": 6.9,
                "bool_true": true,
                "bool_false": false
            ]
        ]

        let json = JSON(jsonDictionary)
        let jsonObject = json.jsonObject()
        let data = try! JSONSerialization.data(withJSONObject: jsonObject, options: [])

        let recoveredJSONObject = try! JSONSerialization.jsonObject(with: data, options: [])
        let recoveredJSON = JSON(jsonObject: recoveredJSONObject)!

        XCTAssertEqual(json, recoveredJSON)
    }
}
