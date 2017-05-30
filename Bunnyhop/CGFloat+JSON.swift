import UIKit


extension CGFloat: JSONEncodable {
    public var json: JSON {
        return .numberValue(.doubleValue(Double(self)))
    }
}

extension CGFloat: JSONDecodable {

    public init?(json: JSON) {
        if let double: Double = json.decode() {
            self.init(double)
        } else {
            return nil
        }
    }
}
