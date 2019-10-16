import Foundation

/// Transports are used to send messages between nodes using different methods, e.g. wifi direct or bluetooth.
public protocol Transport {
    /// The transports delegate.
    var delegate: TransportDelegate? { get set }

    /// Send implements a function to send messages between nodes using the transport.
    ///
    /// - Parameters:
    ///     - message: The message to send.
    ///     - to: The node to which to send the message.
    func send(message: Data, to: Addr)

    /// Listen implements a function to receive messages being sent to a node.
    ///
    /// - Parameters:
    ///     - identity: The identity of the node.
    func listen(identity: UBID)
}
