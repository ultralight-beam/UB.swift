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

extension Message {

    /// Initializes a Message from a protocol buffer `msg` and a passed `from`.
    ///
    /// - Parameters
    ///     - protobuf: The protocol buffer.
    ///     - from: The protocol buffer.
    init(protobuf: msg, from: Addr) {
        proto = UBID(protobuf.protocol)
        recipient = Addr(protobuf.recipient)
        self.from = from
        origin = Addr(protobuf.origin)
        message = protobuf.body
    }

    func toProto() -> msg {
        return msg.with {
            $0.protocol = Data(bytes: self.proto)
            $0.recipient = Data(bytes: self.recipient)
            $0.origin = Data(bytes: self.origin)
            $0.body = Data(bytes: self.message)
        }
    }
}

// @todo encoding and decoding
