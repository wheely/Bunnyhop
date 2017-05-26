extension Int: JSONEncodable {
    public var json: JSON {
        return .numberValue(.intValue(self))
    }
}

extension Int: JSONDecodable {
    
    public init?(json: JSON) {
        switch json {
        case let .numberValue(.intValue(int)):       self = int
        case let .numberValue(.floatValue(float)):   self = Int(float)
        case let .numberValue(.doubleValue(doblle)): self = Int(doblle)

        case let .stringValue(string):
            // Casting to double first so we can recover integers from decimal strings.
            if let int = Double(string).map(Int.init) {
                self = int
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
