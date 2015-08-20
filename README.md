# Bunnyhop
JSON library for Swift that extensively uses type inference and no extra syntax.

## Hello World

```swift
struct Bunny {
    let name: String?
    let age: Int
}

extension Bunny: JSONDecodable, JSONEncodable {
    init?(JSONValue: JSON) {
        if let age: Int = JSONValue["age"]?.decode() {
            self.init(name: JSONValue["name"]?.decode(), age: age)
        } else {
            return nil
        }
    }
    
    var JSONValue: JSON {
        if let name = name {
            return ["name": JSON(name), "age": JSON(age)]
        } else {
            return ["age": JSON(age)]
        }
    }
}

let spikeJSON: JSON = ["name": "Spike", "age": 1]
let spike: Bunny? = spikeJSON.decode() // {name "Spike", age 1}
spikeJSON == JSON(spike!) // true
```
