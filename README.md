# Bunnyhop
JSON library for Swift that extensively uses type inference and no extra syntax.

## Hello World

```swift
struct Bunny {
    let name: String?
    let age: Int
}

extension Bunny: JSONDecodable, JSONEncodable {
    init(json: JSON) throws {
        self.init(name: try json["name"].decode(),
                  age:  try json["age"].decode())
    }

    var json: JSON {
        return ["name": name, "age": age].json
    }
}


//: Decoding
let spikeJSON: JSON = ["name": "Spike", "age": 1].json
let spike: Bunny = try! spikeJSON.decode() // {name "Spike", age 1}


//: Encoding
spikeJSON == spike.json // true


//: Serialization
String(data: spikeJSON.encode(), encoding: .utf8)


//: Deserialization
try JSON(data: spikeJSON.encode())


//: Error Handling
let badSpikeJSON: JSON = ["name": "Spike", "age": nil].json
do {
    try badSpikeJSON.decode() as Bunny // Throws an error
} catch let e as JSON.Error {
    print(e) // Prints 'age: Missing value'
}

let strangeSpikeJSON: JSON = ["name": ["Spike"].json, "age": 1].json
do {
    try strangeSpikeJSON.decode() as Bunny // Throws an error
} catch let e as JSON.Error {
    print(e) // Prints 'name: Can't initialize String with [Optional("Spike")]'
    
    // You may want to initialize `name` with `nil` in this case.
    // To achieve this use `try? json["name"].decode()` instead of `try json["name"].decode() in
    // `init(json: JSON)`.
}


//: Collection Recovery
let bunniesJSON: JSON = [
    ["name": "Spike", "age": 1].json,  // Good
    nil,                               // Bad
    ["name": "Lily", "age": nil].json, // Bad
    ["name": "Coco", "age": 2].json,   // Good
    ].json
do {
    try bunniesJSON.decode() as [Bunny] // Throws an error
} catch let e as JSON.Error {
    print(e) // Prints first error 'Contains nil element'
}

// Try to recover good bunnies
let recoveredGoodBunnies: [Bunny] =
    try bunniesJSON.decode { (_, error: JSON.Error) -> Bunny? in
        print(error) // Prints 'Contains nil element' and 'age: Missing value'
        return nil // Skip bad bunnies
    }
print(recoveredGoodBunnies) // [Bunny(name: Optional("Spike"), age: 1),
                            //  Bunny(name: Optional("Coco"), age: 2)]

// Try to recover Lily too
let recoveredBunnies: [Bunny] =
    try bunniesJSON.decode { (jsonValue: JSON?, error: JSON.Error) -> Bunny? in
        switch (jsonValue, error) {
        case let (.some(jsonValue), .keyError("age", .missingValue)):
            return Bunny(name: try jsonValue["name"].decode(), age: 0)
        default:
            return nil // Skip other bad bunnies
        }
    }
print(recoveredBunnies) // [Bunny(name: Optional("Spike"), age: 1),
                        //  Bunny(name: Optional("Lily"), age: 0),
                        //  Bunny(name: Optional("Coco"), age: 2)]
```
