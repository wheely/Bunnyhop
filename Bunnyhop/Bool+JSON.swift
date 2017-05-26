extension Bool: JSONEncodable {
    public var json: JSON {
        return .boolValue(self)
    }
}

extension Bool: JSONDecodable {
    
    public init?(json: JSON) {
        if case let .boolValue(bool) = json {
            self = bool
        } else {
            return nil
        }
    }
}
