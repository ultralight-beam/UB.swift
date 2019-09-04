import Foundation

// @todo figure out architecture to support new forwarding algorithm.

/// An ultralight beam node, handles the interaction with transports and services.
public class Node {
    /// The known transports for the node.
    public private(set) var transports = [String: Transport]()

    /// The nodes delegate.
    public weak var delegate: NodeDelegate?

    public init() {}

    /// Adds a new transport to the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The new *Transport* to add.
    public func add(transport: Transport) {
        let id = String(describing: transport)

        if transports[id] != nil {
            return // @TODO: Maybe errors?
        }

        transport.listen { msg in

            // @todo message should probably be created here

            // @todo delegate should return something where we handle retransmission.

            delegate?.node(self, didReceiveMessage: msg)

            // @todo if node delegate doesn't return anything success, send out the message?
        }

        transports[id] = transport
    }

    /// Removes a transport from the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The identifier of the *Transport* to remove.
    public func remove(transport: String) {
        guard transports[transport] != nil else {
            return
        }

        transports.removeValue(forKey: transport)
    }

    /// Sends a message through the current transports.
    ///
    /// - Parameters:
    ///     - message: The message to send.
    public func send(_ message: Message) {
        if message.recipient.count == 0, message.proto.count == 0 {
            return
        }

        transports.forEach { _, transport in
            let peers = transport.peers

            // @todo ensure that messages are delivered?
            // what this does is try to send a message to an exact target or broadcast it to all peers
            if message.recipient.count != 0 {
                if peers.contains(where: { $0.id == message.recipient }) {
                    return transport.send(message: message, to: message.recipient)
                }
            }

            // what this does is send a message to anyone that implements a specific service	            /
            if message.proto.count != 0 {
                let filtered = peers.filter { $0.services.contains { $0 == message.proto } }
                if filtered.count > 0 {
                    return send(message, transport: transport, peers: filtered)
                }
            }

            send(message, transport: transport, peers: peers)
        }
    }

    private func send(_ message: Message, transport: Transport, peers: [Peer]) {
        peers.forEach {
            if $0.id == message.from || $0.id == message.origin {
                return
            }

            transport.send(message: message, to: $0.id)
        }
    }

    // @todo create a message send loop with retransmissions and shit
}
