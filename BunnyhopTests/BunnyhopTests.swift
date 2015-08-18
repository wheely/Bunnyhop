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
        
        init?(JSONValue: JSON) {
            if let name: String = JSONValue["name"]?.decode(),
                legCount: Int = JSONValue["leg_count"]?.decode() {
                    self.init(name: name, legCount: legCount)
                    return
            }
            return nil
        }
        
        var JSONValue: JSON {
            get {
                return JSON(["name": JSON(self.name), "leg_count": JSON(self.legCount)])
            }
        }
    }
    
    func testBackAndForth() {
        let realBunny = Bunny(name: "bugz", legCount: 4)
        let frozenBunny = realBunny.JSONValue
        let thawedBunny: Bunny = frozenBunny.decode()!
        
        XCTAssertEqual(realBunny.name, thawedBunny.name, "names should be equal")
        XCTAssertEqual(realBunny.legCount, thawedBunny.legCount, "legCounts should be equal")
    }
}
