extension JSON {

    public enum Number {
        case intValue(Int)
        case floatValue(Float)
        case doubleValue(Double)
    }
}


// MARK: - Equatable

extension JSON.Number: Equatable {

    static func areEqualWithPrecision<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T, precision: T = 1e-6) -> Bool {
        return abs(lhs - rhs) < precision
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
