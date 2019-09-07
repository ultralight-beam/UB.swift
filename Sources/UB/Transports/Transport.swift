import Foundation

/// The Handler function is used to handle messages received by the transport.
public typealias Handler = (Message) -> Void

/// Transports are used to send messages between nodes using different methods, e.g. wifi direct or bluetooth.
public protocol Transport {
    ///  The peers a specific transport can send messages to.
    var peers: [Peer] { get }

    /// Send implements a function to send messages between nodes using the transport.
    ///
    /// - Parameters:
    ///     - message: The message to send.
    ///     - to: The node to which to send the message.
    func send(message: Data, to: Addr)

    /// Listen implements a function to receive messages being sent to a node.
    ///
    /// - Parameters:
    ///     - handler: The message handler to handle received messages.
    func listen(_ handler: @escaping Handler)
}
