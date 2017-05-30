import XCTest
import Bunnyhop


class CollectionDecodingTests: XCTestCase {

    func testArrayDecoding() {
        guard let jsonArray = jsonFromFile(named: "Array")!.arrayValue else {
            XCTFail("Failed to decode JSON array"); return
        }

        let validJSONArray: [JSON?] = [
            nil,
            "wat",
            69,
            6.9,
            true,
            false,
            [
                nil,
                "wat",
                69,
                6.9,
                true,
                false,
            ],
            [
                "null": nil,
                "string": "wat",
                "integer": 69,
                "decimal": 6.9,
                "bool_true": true,
                "bool_false": false
            ]
        ]

        XCTAssertEqual(JSON(jsonArray), JSON(validJSONArray))
    }

    func testDictionaryDecoding() {
        guard let jsonDictionary = jsonFromFile(named: "Dictionary")!.dictionaryValue else {
            XCTFail("Failed to decode JSON dictionary"); return
        }

        let validJSONDictionary: [String: JSON?] = [
            "null": nil,
            "string": "wat",
            "integer": 69,
            "decimal": 6.9,
            "bool_true": true,
            "bool_false": false,
            "nested_array": [
                nil,
                "wat",
                69,
                6.9,
                true,
                false,
            ],
            "nested_dictionary": [
                "null": nil,
                "string": "wat",
                "integer": 69,
                "decimal": 6.9,
                "bool_true": true,
                "bool_false": false
            ]
        ]

        XCTAssertEqual(JSON(jsonDictionary), JSON(validJSONDictionary))
    }
}
