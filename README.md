# UB.swift

[![Build Status](https://travis-ci.com/ultralight-beam/UB.swift.svg?branch=master)](https://travis-ci.com/ultralight-beam/UB.swift) 
[![License](https://img.shields.io/github/license/ultralight-beam/UB.swift.svg)](LICENSE)
[![Maintainability](https://api.codeclimate.com/v1/badges/25933a4b71183e31a899/maintainability)](https://codeclimate.com/github/ultralight-beam/UB.swift/maintainability)

Swift implementation of the Ultralight Beam Protocol.

## Usage

```swift
import UB

let node = UB.Node()
let transport = BluetoothTransport()
        
node.delegate = self
node.add(transport: transport)
```
