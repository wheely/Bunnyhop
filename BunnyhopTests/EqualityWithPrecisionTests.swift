import XCTest
@testable import Bunnyhop


class EqualityWithPrecisionTests: XCTestCase {

    func testEquality() {
        let precision = 1e-3

        let double1 = 0.123
        let double2 = 0.1234

        XCTAssert(JSON.Number.areEqualWithPrecision(double1, double2, precision: precision))
    }

    func testInequality() {
        let precision = 1e-4

        let double1 = 0.123
        let double2 = 0.1234

        XCTAssertFalse(JSON.Number.areEqualWithPrecision(double1, double2, precision: precision))
    }
}
