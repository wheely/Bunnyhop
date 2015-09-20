# Bunnyhop
JSON library for Swift that extensively uses type inference and no extra syntax.

## Hello World

```swift
struct Bunny {
    let name: String?
    let age: Int
}

extension Bunny: JSONDecodable, JSONEncodable {
    init(JSONValue: JSON) throws {
        self.init(name: try JSONValue["name"].decode(),
                  age:  try JSONValue["age"].decode())
    }
    
    var JSONValue: JSON {
        return ["name": name, "age": age]
    }
}


// Encoding
let spikeJSON: JSON = ["name": "Spike", "age": 1]
let spike: Bunny = try! spikeJSON.decode() // {name "Spike", age 1}


// Decoding
spikeJSON == JSON(spike) // true


// Serialization
String(data: spikeJSON.encode(), encoding: NSUTF8StringEncoding)


// Deserialization
try JSON(data: spikeJSON.encode())


// Error Handling
let badSpikeJSON: JSON = ["name": "Spike", "age": nil]
do {
    try badSpikeJSON.decode() as Bunny
} catch let e as JSON.Error {
    print(e) // Prints 'age: Missing value'
}


// More Error Handling
let veryBadSpikeJSON: JSON = ["name": "Spike", "age": JSON([5])]
do {
    try veryBadSpikeJSON.decode() as Bunny // Throws an error
} catch let e as JSON.Error {
    print(e) // Prints 'age: Can't initialize Int with [Optional(5)]'
}


// Element Recovery
let goodAndBadBunniesJSON: JSON = [
    JSON(["name": "Spike", "age": 1]),  // Good
    nil,                                // Bad
    JSON(["name": "Lily", "age": nil]), // Bad
    JSON(["name": "Coco", "age": 2]),   // Good
    ]
do {
    let bunnies: [Bunny] = try goodAndBadBunniesJSON.decode() // Throws an error
} catch let e as JSON.Error {
    print(e) // Prints first error 'Contains nil element'
}

// Try to recover good bunnies
let recoveredGoodBunnies: [Bunny] =
    try goodAndBadBunniesJSON.decode { (_, error: JSON.Error) -> Bunny? in
        print(error) // Prints 'Contains nil element' and 'age: Missing value'
        return nil // Skip bad bunnies
    }
print(recoveredGoodBunnies) // [Bunny(name: Optional("Spike"), age: 1),
                            //  Bunny(name: Optional("Coco"), age: 2)]

// Try to recover Lily too
let recoveredBunnies: [Bunny] =
    try goodAndBadBunniesJSON.decode { (JSONValue: JSON?, error: JSON.Error) -> Bunny? in
        switch (JSONValue, error) {
        case let (.Some(JSONValue), .KeyError("age", .MissingValue)):
            return Bunny(name: try JSONValue["name"].decode(), age: 0) // Rescue Lily!
        default:
            return nil // Skip bad bunnies
        }
    }
print(recoveredBunnies) // [Bunny(name: Optional("Spike"), age: 1),
                        //  Bunny(name: Optional("Lily"), age: 0),
                        //  Bunny(name: Optional("Coco"), age: 2)]
```
