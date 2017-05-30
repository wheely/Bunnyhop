extension Double: JSONEncodable {
    public var json: JSON {
        return .numberValue(.doubleValue(self))
    }
}

extension Double: JSONDecodable {

    public init?(json: JSON) {
        switch json {
        case let .numberValue(.intValue(int)):       self = Double(int)
        case let .numberValue(.floatValue(float)):   self = Double(float)
        case let .numberValue(.doubleValue(double)): self = double

        case let .stringValue(string):
            if let double = Double(string) {
                self = double
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
