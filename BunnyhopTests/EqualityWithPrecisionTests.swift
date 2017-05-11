//
//  EqualityWithPrecisionTests.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 11/05/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

import XCTest
@testable import Bunnyhop


class EqualityWithPrecisionTests: XCTestCase {

    func testEqualityWithinPrecision() {
        let precision = 1e-3

        let double1 = 0.123
        let double2 = 0.123

        XCTAssert(JSON.Number.areEqualWithPrecision(double1, double2, precision: precision))
    }

    func testInequalityWithinPrecision() {
        let precision = 1e-3

        let double1 = 0.123
        let double2 = 0.124

        XCTAssertFalse(JSON.Number.areEqualWithPrecision(double1, double2, precision: precision))
    }

    func testEqualityExceedingPrecision() {
        let precision = 1e-6

        let double1 = 0.123456
        let double2 = 0.123456_7

        XCTAssert(JSON.Number.areEqualWithPrecision(double1, double2, precision: precision))
    }

    func testInequalityExceedingPrecision() {
        let precision = 1e-6

        let double1 = 0.123456_78
        let double2 = 0.123457_89

        XCTAssertFalse(JSON.Number.areEqualWithPrecision(double1, double2, precision: precision))
    }
}
