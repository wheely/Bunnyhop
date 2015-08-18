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

let kyleJSON = ["name": "Kyle", "age": 1] as JSON
let kyle: Bunny? = kyleJSON.decode() // {name "Kyle", age 1}
kyleJSON == JSON(kyle!) // true
```
