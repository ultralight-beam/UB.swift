import Foundation

// @todo remove
/// Message represents the message sent between nodes.
public struct Message: Equatable {
    /// The message topic.
    public let topic: UBID

    /// The sender of the message.
    public let from: Addr

    /// The raw message data.
    public let message: Data

    /// Initializes a message with the passed data.
    ///
    /// - Parameters:
    ///     - topic: The message topic.
    ///     - from: The previous sender of the message.
    ///     - message: The raw message data.
    public init(topic: UBID, from: Addr, message: Data) {
        self.topic = topic
        self.from = from
        self.message = message
    }

    /// Initializes a Message with a packet and a from addr.
    ///
    /// - Parameters
    ///     - protobuf: The protocol buffer.
    ///     - from: The from address.
    init(protobuf: Packet, from: Addr) {
        topic = UBID(protobuf.topic)
        self.from = from
        message = protobuf.body
    }

    func toProto() -> Packet {
        return Packet.with {
            $0.topic = Data(topic)
            $0.body = message
        }
    }
}

// @todo encoding and decoding
