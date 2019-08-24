# UB.swift

[![Build Status](https://travis-ci.com/ultralight-beam/UB.swift.svg?branch=master)](https://travis-ci.com/ultralight-beam/UB.swift) [![License](https://img.shields.io/github/license/ultralight-beam/UB.swift.svg)](LICENSE)

Swift implementation of the Ultralight Beam Protocol.

## Usage

```swift
import UB

let node = UB.Node()
let transport = BluetoothTransport()
        
node.delegate = self
node.add(transport: transport)
```
