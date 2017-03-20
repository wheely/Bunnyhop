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
    static let string = "string"                       // "1wat1"
    static let stringBool = "string_bool"              // "true"
    static let stringInteger = "string_integer"        // "69"
    static let stringDecimal = "string_decimal"        // "6.9"

    static let integer = "integer"                     // 69
    static let integerBoolTrue = "integer_bool_true"   // 1
    static let integerBoolFalse = "integer_bool_false" // 0

    static let decimal = "decimal"                     // 6.9
    static let decimalBoolTrue = "decimal_bool_true"   // 1.0
    static let decimalBoolFalse = "decimal_bool_false" // 0.0

    static let boolTrue = "bool_true"                  // true
    static let boolFalse = "bool_false"                // false
}

private var decimalComparissonPrecision: Double {
    return 10e-6 // 0.000_001
}

private func areEqualWithPrecision(_ lhs: Double, _ rhs: Double) -> Bool {
    return abs(lhs - rhs) < decimalComparissonPrecision
}

private func areEqualWithPrecision(_ lhs: Float, _ rhs: Float) -> Bool {
    return abs(lhs - rhs) < Float(decimalComparissonPrecision)
}

private func areEqualWithPrecision(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
    return abs(lhs - rhs) < CGFloat(decimalComparissonPrecision)
}

class BunnyhopTests: XCTestCase {

    let json = jsonFromFile(named: "Scalars")!

    func testBoolDecoding() {
        if let bool: Bool = json[Key.stringBool]!.decode() {
            XCTFail("Decoded invalid bool \(bool) for key \(Key.stringBool)")
        }

        if let bool: Bool = json[Key.integer]!.decode() {
            XCTFail("Decoded invalid bool \(bool) for key \(Key.integer)")
        }

        if let bool: Bool = json[Key.integerBoolTrue]!.decode() {
            XCTAssertEqual(bool, true)
        } else {
            XCTFail("Failed to decode bool for key \(Key.integerBoolTrue)")
        }

        if let bool: Bool = json[Key.integerBoolFalse]!.decode() {
            XCTAssertEqual(bool, false)
        } else {
            XCTFail("Failed to decode bool for key \(Key.integerBoolFalse)")
        }

        if let bool: Bool = json[Key.decimal]!.decode() {
            XCTFail("Decoded invalid bool \(bool) for key \(Key.decimal)")
        }

        if let bool: Bool = json[Key.decimalBoolTrue]!.decode() {
            XCTAssertEqual(bool, true)
        } else {
            XCTFail("Failed to decode bool for key \(Key.decimalBoolTrue)")
        }

        if let bool: Bool = json[Key.decimalBoolFalse]!.decode() {
            XCTAssertEqual(bool, false)
        } else {
            XCTFail("Failed to decode bool for key \(Key.decimalBoolFalse)")
        }

        if let bool: Bool = json[Key.boolTrue]!.decode() {
            XCTAssertEqual(bool, true)
        } else {
            XCTFail("Failed to decode bool for key \(Key.boolTrue)")
        }

        if let bool: Bool = json[Key.boolFalse]!.decode() {
            XCTAssertEqual(bool, false)
        } else {
            XCTFail("Failed to decode bool for key \(Key.boolFalse)")
        }
    }

    func testStringDecoding() {
        if let string: String = json[Key.string]!.decode() {
            XCTAssertEqual(string, "1wat1")
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

        if let integer: Int = json[Key.stringInteger]!.decode() {
            XCTAssertEqual(integer, 69)
        } else {
            XCTFail("Failed to decode integer for key \(Key.stringInteger)")
        }

        if let integer: Int = json[Key.stringDecimal]!.decode() {
            XCTAssertEqual(integer, 6)
        } else {
            XCTFail("Failed to decode integer for key \(Key.stringDecimal)")
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

        if let float: Float = json[Key.stringInteger]!.decode() {
            XCTAssertEqual(float, 69)
        } else {
            XCTFail("Failed to decode float for key \(Key.stringInteger)")
        }

        if let float: Float = json[Key.stringDecimal]!.decode() {
            XCTAssert(areEqualWithPrecision(float, 6.9))
        } else {
            XCTFail("Failed to decode float for key \(Key.stringDecimal)")
        }

        if let float: Float = json[Key.integer]!.decode() {
            XCTAssertEqual(float, 69)
        } else {
            XCTFail("Failed to decode float for key \(Key.integer)")
        }

        if let float: Float = json[Key.decimal]!.decode() {
            XCTAssert(areEqualWithPrecision(float, 6.9))
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

        if let double: Double = json[Key.stringInteger]!.decode() {
            XCTAssertEqual(double, 69)
        } else {
            XCTFail("Failed to decode double for key \(Key.stringInteger)")
        }

        if let double: Double = json[Key.decimal]!.decode() {
            XCTAssert(areEqualWithPrecision(double, 6.9))
        } else {
            XCTFail("Failed to decode double for key \(Key.decimal)")
        }

        if let double: Double = json[Key.integer]!.decode() {
            XCTAssertEqual(double, 69)
        } else {
            XCTFail("Failed to decode double for key \(Key.integer)")
        }

        if let double: Double = json[Key.decimal]!.decode() {
            XCTAssert(areEqualWithPrecision(double, 6.9))
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

    func testCGFloatDecoding() {
        if let cgFloat: CGFloat = json[Key.string]!.decode() {
            XCTFail("Decoded invalid cgFloat \(cgFloat) for key \(Key.string)")
        }

        if let cgFloat: CGFloat = json[Key.stringInteger]!.decode() {
            XCTAssertEqual(cgFloat, 69)
        } else {
            XCTFail("Failed to decode cgFloat for key \(Key.stringInteger)")
        }

        if let cgFloat: CGFloat = json[Key.decimal]!.decode() {
            XCTAssert(areEqualWithPrecision(cgFloat, 6.9))
        } else {
            XCTFail("Failed to decode cgFloat for key \(Key.decimal)")
        }

        if let cgFloat: CGFloat = json[Key.integer]!.decode() {
            XCTAssertEqual(cgFloat, 69)
        } else {
            XCTFail("Failed to decode cgFloat for key \(Key.integer)")
        }

        if let cgFloat: CGFloat = json[Key.decimal]!.decode() {
            XCTAssert(areEqualWithPrecision(cgFloat, 6.9))
        } else {
            XCTFail("Failed to decode cgFloat for key \(Key.decimal)")
        }

        if let cgFloat: CGFloat = json[Key.boolTrue]!.decode() {
            XCTAssertEqual(cgFloat, 1.0)
        } else {
            XCTFail("Failed to decode cgFloat for key \(Key.boolTrue)")
        }

        if let cgFloat: CGFloat = json[Key.boolFalse]!.decode() {
            XCTAssertEqual(cgFloat, 0)
        } else {
            XCTFail("Failed to decode cgFloat for key \(Key.boolFalse)")
        }
    }
}
