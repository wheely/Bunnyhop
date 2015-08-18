# Bunnyhop
JSON library for Swift that extensively uses type inference.

## Hello World

```swift
struct Bunny {
    let name: String
    let age: Int
}

extension Bunny: JSONDecodable, JSONEncodable {
    init?(JSONValue: JSON) {
        self.init(name: JSONValue["name"]?.decode() ?? "Anonymous Bunny",
                  age: JSONValue["age"]?.decode() ?? 0)
    }
    
    var JSONValue: JSON {
        return ["name": name, "age": age]
    }
}

let spikeJSON = ["name": "Spike", "age": 1] as JSON
let spike: Bunny? = spikeJSON.decode() // {name "Spike", age 1}
spikeJSON == JSON(spike!) // true
```
