//
//  BunnyhopTests.swift
//  BunnyhopTests
//
//  Created by Pavel Bocharov on 17/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import XCTest
import Bunnyhop


class BunnyhopTests: XCTestCase {

    func testReadingFromFile() {
        let bunnyJSON = jsonFromFile(named: "Felix")!
        let bunny = Bunny(jsonValue: bunnyJSON)!

        XCTAssertEqual(bunny.name, "Felix", "The name is wrong")
        XCTAssertEqual(bunny.numberOfLegs, 10, "Number of legs is wrong")
    }

    func testIdentity() {
        let bunny = Bunny(name: "bugz", legCount: 4)
        let convertedBunny: Bunny = JSON(bunny).decode()!
        
        XCTAssertEqual(bunny.name, convertedBunny.name, "Names should be equal")
        XCTAssertEqual(bunny.numberOfLegs, convertedBunny.numberOfLegs, "Number of legs should be equal")
    }
}
