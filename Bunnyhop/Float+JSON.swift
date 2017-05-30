extension Float: JSONEncodable {
    public var json: JSON {
        return .numberValue(.floatValue(self))
    }
}

extension Float: JSONDecodable {
    
    public init?(json: JSON) {
        switch json {
        case let .numberValue(.intValue(int)):       self = Float(int)
        case let .numberValue(.floatValue(float)):   self = float
        case let .numberValue(.doubleValue(double)): self = Float(double)

        case let .stringValue(string):
            if let float = Float(string) {
                self = float
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
