extension Dictionary {

    init(elements: [Element]) {
        var dictionary: [Key: Value] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = dictionary
    }
}
