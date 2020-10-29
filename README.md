# Swizzle
This is a modified version of [Swift-Swizzle](https://github.com/MarioIannotta/SwizzleSwift/) to support class functions, string selectors, and provide detailed errors.

## Example 

```swift
do {
    try Swizzle(ObjObject.self) { object in
        #selector(getter: object.selector) <-> #selector(getter: object.newSelector)
    }
}
catch {
    debugPrint(error.localizedDescription)
}
```
When used in a class function use the operator `<~>` instead of `<->`
