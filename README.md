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
```
