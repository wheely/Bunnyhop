extension String: JSONEncodable {
    public var json: JSON {
        return .stringValue(self)
    }
}

extension String: JSONDecodable {

    public init?(json: JSON) {
        if case let .stringValue(string) = json {
            self = string
        } else {
            return nil
        }
    }
}
