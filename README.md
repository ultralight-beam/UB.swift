# UB.swift

[![Build Status](https://travis-ci.com/ultralight-beam/UB.swift.svg?branch=master)](https://travis-ci.com/ultralight-beam/UB.swift) 
[![License](https://img.shields.io/github/license/ultralight-beam/UB.swift.svg)](LICENSE)
[![Maintainability](https://api.codeclimate.com/v1/badges/25933a4b71183e31a899/maintainability)](https://codeclimate.com/github/ultralight-beam/UB.swift/maintainability)
[![Pod](https://img.shields.io/cocoapods/v/UB)](https://cocoapods.org/pods/UB)

UB.swift is the swift implementation of the Ultralight Beam protocol, its primary focus is to provide an SDK for **iOS** and **OSX** devices.

## Requirements

- **iOS9** or later
- **OSX10.13** or later
- **Swift 5.0** or later

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
  .package(url: "https://github.com/ultralight-beam/UB.swift.git", from("0.1.0")),
],
targets: [
  .target(
    name: "Target",
    dependencies: ["UB"]
  ),
]
```

### [Cocoapods](https://cocoapods.org/pods/UB)

```ruby
pod 'UB'
```

<!--
## Developing
@todo
-->

## License

UB.swift is licensed under the [Apache License](LICENSE)
