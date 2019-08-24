import Foundation

public struct Message {
    public let proto: UBID
    public let to: Addr
    public let from: Addr
    public let message: Data
}

// @todo encoding and decoding
