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

    public static func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
        switch (lhs, rhs) {
        case let (.intValue(l),    .intValue(r))    where l == r:         return true
        case let (.intValue(l),    .floatValue(r))  where Float(l) == r:  return true
        case let (.intValue(l),    .doubleValue(r)) where Double(l) == r: return true

        case let (.floatValue(l),  .intValue(r))    where l == Float(r):  return true
        case let (.floatValue(l),  .floatValue(r))  where l == r:         return true
        case let (.floatValue(l),  .doubleValue(r)) where Double(l) == r: return true

        case let (.doubleValue(l), .intValue(r))    where l == Double(r): return true
        case let (.doubleValue(l), .floatValue(r))  where l == Double(r): return true
        case let (.doubleValue(l), .doubleValue(r)) where l == r:         return true
            
        default: return false
        }
    }
}


// MARK: - Printing

extension JSON.Number: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .intValue(v): return v.description
        case let .floatValue(v): return v.description
        case let .doubleValue(v): return v.description
        }
    }
}
