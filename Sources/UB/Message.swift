import Foundation

/// Message represents the message sent between nodes.
public struct Message: Equatable {

    /// The type
    public let type: MessageType

    /// The message protocol.
    public let proto: UBID
    
    /// The recipient of the message.
    public let to: Addr
    
    /// The sender of the message.
    public let from: Addr
    
    /// The raw message data.
    public let message: Data
}

/// Message types represents the type of message
public enum MessageType {

    /// msg == Generic Message
    /// ack == Acknowledgment of previous message
    case msg, ack
}

// @todo encoding and decoding
