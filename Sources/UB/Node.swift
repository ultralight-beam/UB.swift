import Foundation
import SwiftProtobuf

// @todo figure out architecture to support new forwarding algorithm.

/// An ultralight beam node, handles the interaction with transports and services.
public class Node {
    /// The known transports for the node.
    public private(set) var transports = [String: Transport]()

    /// The nodes delegate.
    public weak var delegate: NodeDelegate?

    /// Initializes a node.
    public init() {}

    /// Adds a new transport to the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The transport to be added.
    public func add(transport: Transport) {
        let id = String(describing: transport)

        if transports[id] != nil {
            return // @TODO: Maybe errors?
        }

        transports[id] = transport
        transports[id]?.delegate = self
        transport.listen()
    }

    /// Removes a transport from the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The identifier of the transport to remove.
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

        guard let data = try? message.toProto().serializedData() else {
            return
        }

        transports.forEach { _, transport in
            let peers = transport.peers

            // @todo ensure that messages are delivered?
            // what this does is try to send a message to an exact target or broadcast it to all peers
            if message.recipient.count != 0 {
                if peers.contains(where: { $0.id == message.recipient }) {
                    return transport.send(message: data, to: message.recipient)
                }
            }

            // what this does is send a message to anyone that implements a specific service
            if message.proto.count != 0 {
                let filtered = peers.filter { $0.services.contains { $0 == message.proto } }
                if filtered.count > 0 {

                    let sends = flood(message, data: data, transport: transport, peers: filtered)
                    if sends > 0 {
                        return
                    }
                }
            }
            _ = flood(message, data: data, transport: transport, peers: peers)
        }
    }

    private func flood(_ message: Message, data: Data, transport: Transport, peers: [Peer]) -> Int {
        var sends = 0
        peers.forEach {
            if $0.id == message.from || $0.id == message.origin {
                return
            }

            sends += 1
            transport.send(message: data, to: $0.id)
        }

        return sends
    }

    // @todo create a message send loop with retransmissions and shit
}

/// :nodoc:
extension Node: TransportDelegate {

    public func transport(_: Transport, didReceiveData data: Data, from: Addr) {
        // @todo message should probably be created here

        // @todo delegate should return something where we handle retransmission.

        // @todo if node delegate doesn't return anything success, send out the message?

        guard let packet = try? Packet(serializedData: data) else {
            // @todo
            return
        }

        delegate?.node(self, didReceiveMessage: Message(protobuf: packet, from: from))
    }
}
