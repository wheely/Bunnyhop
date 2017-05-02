//
//  Helpers.swift
//  Bunnyhop
//
//  Created by Nikita Kukushkin on 20/03/2017.
//  Copyright © 2017 Wheely. All rights reserved.
//

import Bunnyhop


func jsonFromFile(named fileName: String) -> JSON? {
    let filePath = Bundle.bunnyhopTests.path(forResource: fileName, ofType: "json")!

    let data = try! NSData(contentsOfFile: filePath) as Data
    let jsonObject = try! JSONSerialization.jsonObject(with: data, options: [])

    return JSON(jsonObject: jsonObject)
}

/// Convenience extension for accessing BunnyhopTests bundle.
extension Bundle {

    private static let bundleIdentifier = "com.wheely.BunnyhopTests"

    public static var bunnyhopTests: Bundle {
        return Bundle(identifier: Bundle.bundleIdentifier)!
    }
}
