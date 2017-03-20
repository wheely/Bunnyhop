//
//  ScalarDecodingTests.swift
//  Bunnyhop
//
//  Created by Pavel Bocharov on 17/08/15.
//  Copyright (c) 2015 Wheely. All rights reserved.
//

import XCTest
import Bunnyhop


private enum Key {
    static let string = "string"        // "wat"
    static let integer = "integer"      // 69
    static let decimal = "decimal"      // 6.9
    static let boolTrue = "bool_true"   // true
    static let boolFalse = "bool_false" // false
}

private let deicmalComparissonPrecision = 0.000001

class BunnyhopTests: XCTestCase {

    let json = jsonFromFile(named: "Scalars")!

    func testStringDecoding() {
        if let string: String = json[Key.string]!.decode() {
            XCTAssertEqual(string, "wat")
        } else {
            XCTFail("Failed to decode string for key \(Key.string)")
        }

        if let string: String = json[Key.integer]!.decode() {
            XCTFail("Decoded invalid string \(string) for key \(Key.integer)")
        }

        if let string: String = json[Key.decimal]!.decode() {
            XCTFail("Decoded invalid string \(string) for key \(Key.decimal)")
        }

        if let string: String = json[Key.boolTrue]!.decode() {
            XCTFail("Decoded invalid string \(string) for key \(Key.boolTrue)")
        }

        if let string: String = json[Key.boolFalse]!.decode() {
            XCTFail("Decoded invalid string \(string) for key \(Key.boolFalse)")
        }
    }

    func testIntegerDecoding() {
        if let integer: Int = json[Key.string]!.decode() {
            XCTFail("Decoded invalid integer \(integer) for key \(Key.string)")
        }

        if let integer: Int = json[Key.integer]!.decode() {
            XCTAssertEqual(integer, 69)
        } else {
            XCTFail("Failed to decode integer for key \(Key.integer)")
        }

        if let integer: Int = json[Key.decimal]!.decode() {
            XCTAssertEqual(integer, 6)
        } else {
            XCTFail("Failed to decode integer for key \(Key.decimal)")
        }

        if let integer: Int = json[Key.boolTrue]!.decode() {
            XCTAssertEqual(integer, 1)
        } else {
            XCTFail("Failed to decode integer for key \(Key.boolTrue)")
        }

        if let integer: Int = json[Key.boolFalse]!.decode() {
            XCTAssertEqual(integer, 0)
        } else {
            XCTFail("Failed to decode integer for key \(Key.boolFalse)")
        }
    }

    func testFloatDecoding() {
        if let float: Float = json[Key.string]!.decode() {
            XCTFail("Decoded invalid float \(float) for key \(Key.string)")
        }

        if let float: Float = json[Key.integer]!.decode() {
            XCTAssertEqual(float, 69)
        } else {
            XCTFail("Failed to decode float for key \(Key.integer)")
        }

        if let float: Float = json[Key.decimal]!.decode() {
            XCTAssert(abs(float - 6.9) < Float(deicmalComparissonPrecision))
        } else {
            XCTFail("Failed to decode float for key \(Key.decimal)")
        }

        if let float: Float = json[Key.boolTrue]!.decode() {
            XCTAssertEqual(float, 1.0)
        } else {
            XCTFail("Failed to decode float for key \(Key.boolTrue)")
        }

        if let float: Float = json[Key.boolFalse]!.decode() {
            XCTAssertEqual(float, 0)
        } else {
            XCTFail("Failed to decode float for key \(Key.boolFalse)")
        }
    }

    func testDoubleDecoding() {
        if let double: Double = json[Key.string]!.decode() {
            XCTFail("Decoded invalid double \(double) for key \(Key.string)")
        }

        if let double: Double = json[Key.integer]!.decode() {
            XCTAssertEqual(double, 69)
        } else {
            XCTFail("Failed to decode double for key \(Key.integer)")
        }

        if let double: Double = json[Key.decimal]!.decode() {
            XCTAssert(abs(double - 6.9) < deicmalComparissonPrecision)
        } else {
            XCTFail("Failed to decode double for key \(Key.decimal)")
        }

        if let double: Double = json[Key.boolTrue]!.decode() {
            XCTAssertEqual(double, 1.0)
        } else {
            XCTFail("Failed to decode double for key \(Key.boolTrue)")
        }

        if let double: Double = json[Key.boolFalse]!.decode() {
            XCTAssertEqual(double, 0)
        } else {
            XCTFail("Failed to decode double for key \(Key.boolFalse)")
        }
    }
}
