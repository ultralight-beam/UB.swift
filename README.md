# UB.swift

[![Build Status](https://travis-ci.com/ultralight-beam/UB.swift.svg?branch=master)](https://travis-ci.com/ultralight-beam/UB.swift) 
[![License](https://img.shields.io/github/license/ultralight-beam/UB.swift.svg)](LICENSE)
[![Maintainability](https://api.codeclimate.com/v1/badges/25933a4b71183e31a899/maintainability)](https://codeclimate.com/github/ultralight-beam/UB.swift/maintainability)
[![Pod](https://img.shields.io/cocoapods/v/UB)](https://cocoapods.org/pods/UB)

UB.swift is the swift implementation of the Ultralight Beam protocol, its primary focus is to provide an SDK for **iOS** and **OSX** devices.

## Requirements

- **iOS 9** or later
- **OSX 10.13** or later
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

## Usage

Using the UB within your own project is kept simple. Initialize a `Node`, and assign [`delegate`](https://swift.ultralightbeam.io/Protocols/NodeDelegate.html) which will then be notified of received messages. Various `transport`s can be added to a `Node` enabling sending and receiving messages through them.

```swift
import UB

let node = Node()
node.delegate = self

node.add(transport: CoreBluetoothTransport())

node.send(...)
```

<!--
## Developing
@todo
-->

## License

UB.swift is licensed under the [Apache License](LICENSE)
