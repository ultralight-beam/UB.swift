import Foundation

/// TransportDelegate is used to handle the receiving of messages.
public protocol TransportDelegate: AnyObject {
    /// Called when a transport receives a new message.
    ///
    /// - Parameters:
    ///     - transport: The transport that received a message.
    ///     - message: The received message.
    func transport(_ transport: Transport, didReceiveMessage message: Message)
}
