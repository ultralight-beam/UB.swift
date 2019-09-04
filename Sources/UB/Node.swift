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

            // @todo delegate should return something where we handle retransmission.

            delegate?.node(self, didReceiveMessage: msg)
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
        transports.forEach { _, transport in
            let peers = transport.peers

            // @todo this is ugly split into functions
            // @todo ensure that messages are delivered?
            if message.recipient.count == 0, message.proto.count == 0 {
                return
            }

            // what this does is try to send a message to an exact target or broadcast it to all peers
            if message.recipient.count != 0 {
                if peers.contains(where: { $0.id == message.recipient }) {
                    return transport.send(message: message, to: message.recipient)
                }
            }

            // what this does is send a message to anyone that implements a specific service	            /
            if message.proto.count != 0 {
                let filtered = peers.filter { $0.services.contains(where: { $0 == message.proto }) }
                if filtered.count > 0 {
                    return filtered.forEach {
                        if $0.id == message.from {
                            return
                        }

                        transport.send(message: message, to: $0.id)
                    }
            }

            peers.forEach {
                if $0.id == message.from || $0.id == message.origin {
                    return
                }

                transport.send(message: message, to: $0.id)
            }
        }
    }

    private func sendMessageToServiceProviders(message: Message, peers: [Peer], transport: Transport) {
        if message.proto.count == 0 {
            return
        }

        peers
            .filter { $0.services.contains(where: { $0 == message.proto }) }
            .forEach {
                if $0.id == message.from {
                    return
                }

                transport.send(message: message, to: $0.id)
            }
    }

    private func sendMessageRecipient(message: Message, peers: [Peer], transport: Transport) {
        if message.recipient.count == 0 {
            return
        }

        if peers.contains(where: { $0.id == message.recipient }) {
            transport.send(message: message, to: message.recipient)
        }
    }

    // @todo create a message send loop with retransmissions and shit
}
