//
//  JSON.Number.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension JSON {

    public enum Number {
        case intValue(Int)
        case floatValue(Float)
        case doubleValue(Double)
    }
}


// MARK: - Equatable

extension JSON.Number: Equatable {

    private static var decimalComparissonPrecision: Double {
        return 10e-6 // 0.000_001
    }

    private static func areEqualWithPrecision(_ lhs: Double, _ rhs: Double) -> Bool {
        return abs(lhs - rhs) < decimalComparissonPrecision
    }

    private static func areEqualWithPrecision(_ lhs: Float, _ rhs: Float) -> Bool {
        return abs(lhs - rhs) < Float(decimalComparissonPrecision)
    }

    public static func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
        switch (lhs, rhs) {
        case let (.intValue(l),    .intValue(r)):    return l == r
        case let (.intValue(l),    .floatValue(r)):  return areEqualWithPrecision(Float(l), r)
        case let (.intValue(l),    .doubleValue(r)): return areEqualWithPrecision(Double(l), r)

        case let (.floatValue(l),  .intValue(r)):    return areEqualWithPrecision(l, Float(r))
        case let (.floatValue(l),  .floatValue(r)):  return areEqualWithPrecision(l, r)
        case let (.floatValue(l),  .doubleValue(r)): return areEqualWithPrecision(Double(l), r)

        case let (.doubleValue(l), .intValue(r)):    return areEqualWithPrecision(l, Double(r))
        case let (.doubleValue(l), .floatValue(r)):  return areEqualWithPrecision(l, Double(r))
        case let (.doubleValue(l), .doubleValue(r)): return areEqualWithPrecision(l, r)
        }
    }
}


// MARK: - Printing

extension JSON.Number: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .intValue(int): return int.description
        case let .floatValue(float): return float.description
        case let .doubleValue(double): return double.description
        }
    }
}
