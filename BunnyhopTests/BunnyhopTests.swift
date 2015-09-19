//
//  BunnyhopTests.swift
//  BunnyhopTests
//
//  Created by Pavel Bocharov on 17/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import UIKit
import XCTest

import Bunnyhop


class BunnyhopTests: XCTestCase {

    struct Bunny: JSONDecodable, JSONEncodable {
        var name: String
        var legCount: Int
        
        init(name: String, legCount: Int) {
            self.name = name
            self.legCount = legCount
        }
        
        init(JSONValue: JSON) throws {
            self.init(name:     try JSONValue["name"].decode(),
                      legCount: try JSONValue["leg_count"].decode())
        }
        
        var JSONValue: JSON {
            return ["name": name, "leg_count": legCount]
        }
    }
    
    func testBackAndForth() {
        let realBunny = Bunny(name: "bugz", legCount: 4)
        let frozenBunny = JSON(realBunny)
        let thawedBunny: Bunny = try! frozenBunny.decode()
        
        XCTAssertEqual(realBunny.name, thawedBunny.name, "names should be equal")
        XCTAssertEqual(realBunny.legCount, thawedBunny.legCount, "legCounts should be equal")
    }
}
