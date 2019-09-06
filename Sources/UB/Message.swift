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

    /// Initializes a message with the passed data.
    ///
    /// - Parameters:
    ///     - proto: The message protocol.
    ///     - recipient: The recipient of the message.
    ///     - from: The previous sender of the message.
    ///     - origin: The origin of the message, or the original sender.
    ///               Differs from the `sender` as that changes on every hop.
    ///     - message: The raw message data.
    public init(proto: UBID, recipient: Addr, from: Addr, origin: Addr, message: Data) {
        self.proto = proto
        self.recipient = recipient
        self.from = from
        self.origin = origin
        self.message = message
    }
}

// @todo encoding and decoding
