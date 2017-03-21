//
//  Dictionary+InitializationFromArray.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

extension Dictionary {

    init(elements: [Element]) {
        var dictionary: [Key: Value] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = dictionary
    }
}
