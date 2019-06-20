import Foundation

public struct Message {
    let proto: UBID
    let to: Addr
    let from: Addr
    let message: Data
}

// @todo encoding and decoding
