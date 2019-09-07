import Foundation

/// Transports are used to send messages between nodes using different methods, e.g. wifi direct or bluetooth.
public protocol Transport {
    /// The transports delegate.
    var delegate: TransportDelegate? { get set }
    
    ///  The peers a specific transport can send messages to.
    var peers: [Peer] { get }

    /// Send implements a function to send messages between nodes using the transport.
    ///
    /// - Parameters:
    ///     - message: The message to send.
    ///     - to: The node to which to send the message.
    func send(message: Message, to: Addr)

    /// Listen implements a function to receive messages being sent to a node.
    func listen()
}
