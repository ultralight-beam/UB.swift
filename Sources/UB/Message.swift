import Foundation

/// Message represents the message sent between nodes.
public struct Message: Equatable {

    /// The message protocol.
    public let proto: UBID

    /// The recipient of the message.
    public let recipient: Addr

    /// The sender of the message.
    public let from: Addr

    /// The origin of the message, or the original sender.
    /// Differs from the `sender` as that changes on every hop.
    public let origin: Addr

    /// The raw message data.
    public let message: Data
}

// @todo encoding and decoding
