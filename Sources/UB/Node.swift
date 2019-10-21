import Foundation
import SwiftProtobuf
import CryptoKit

// @todo figure out architecture to support new forwarding algorithm.

/// An ultralight beam node, handles the interaction with transports and services.
public class Node {
    /// The known transports for the node.
    public private(set) var transports = [String: Transport]()

    /// The known peers for a node.
    public private(set) var peers = [Addr: Peer]()

    /// The nodes delegate.
    public weak var delegate: NodeDelegate?

    /// The nodes private key.
    private let key: Curve25519.Signing.PrivateKey

    /// Initializes a node.
    ///
    /// - Parameters:
    ///     - key: The private key for the node.
    public init(key: Curve25519.Signing.PrivateKey) {
        self.key = key
    }

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
        transport.listen(identity: UBID(key.publicKey.rawRepresentation))
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
        if message.recipient.count == 0, message.service.count == 0 {
            return
        }

        guard let data = try? message.toProto().serializedData() else {
            return
        }

        if message.recipient.count != 0 {
            if let peer = peers[message.recipient] {
                // @todo ensure we actually had > 0 transports to send to.
                return peer.transports.forEach { id, addr in
                    guard let transport = transports[id] else { return }
                    transport.send(message: data, to: addr)
                }
            }
        }

        // @todo: there is probably some better way of doing this
        transports.forEach { id, transport in
            let transportPeers = Array(peers.filter({ $1.transports[id] != nil }).values)

            if message.service.count != 0 {
                let filtered = transportPeers.filter { $0.services.contains { $0 == message.service } }
                if filtered.count > 0 {
                    let sends = flood(message, data: data, transport: transport, peers: filtered)
                    if sends > 0 {
                        return
                    }
                }
            }

            _ = flood(message, data: data, transport: transport, peers: transportPeers)
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

    public func transport(_ transport: Transport, didConnectToPeer id: Addr, withAddr addr: Addr) {
        if peers[id] == nil {
            peers[id] = Peer(id: id, services: [UBID]())
        }

        guard let peer = peers[id] else { return }

        peer.transports[String(describing: transport)] = addr
    }

    public func transport(_ transport: Transport, didDisconnectFromPeer id: Addr) {
        guard let peer = peers[id] else { return }
        peer.transports.removeValue(forKey: String(describing: transport))
    }
}
