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

// Error Handling
let badSpikeJSON: JSON = ["name": "Spike", "age": nil]
do {
    try badSpikeJSON.decode() as Bunny
} catch let e as JSON.Error {
    print(e) // age: Missing value
}

// More Error Handling
let veryBadSpikeJSON: JSON = ["name": "Spike", "age": JSON([5])]
do {
    try veryBadSpikeJSON.decode() as Bunny
} catch let e as JSON.Error {
    print(e) // age: Can't initialize Int with [Optional(5)]
}

// Element Recovery
let goodAndBadBunniesJSON: JSON = [
    JSON(["name": "Spike", "age": 1]),
    nil,
    JSON(["name": "Lily", "age": nil]),
    JSON(["name": "Coco", "age": 2]),
    ]
do {
    let bunnies: [Bunny] = try goodAndBadBunniesJSON.decode()
} catch let e as JSON.Error {
    print(e) // Contains nil element
}

let recoveredGoodBunnies: [Bunny] =
    try goodAndBadBunniesJSON.decode { (error: JSON.Error) -> Bunny? in
        print(error) // Prints 'Contains nil element' and 'age: Missing value'
        return nil // Skip bad bunnies
    }
print(recoveredGoodBunnies) // [Bunny(name: Optional("Spike"), age: 1), Bunny(name: Optional("Coco"), age: 2)]
```
