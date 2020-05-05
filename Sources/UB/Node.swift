import Foundation
import SwiftProtobuf

// @todo figure out architecture to support new forwarding algorithm.

/// An ultralight beam node, handles the interaction with transports and services.
public class Node {
    /// The known transports for the node.
    public private(set) var transports = [String: Transport]()

    /// The nodes delegate.
    public weak var delegate: NodeDelegate?

    /// The current subscribed to topic.
    public private(set) var topics = [UBID]()

    /// The parent for a specific topic for the given peer.
    public private(set) var parents = [UBID: Addr]()

    /// The children for a specific topic for the given peer.
    public private(set) var children = [UBID: [Addr]]()

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

    /// Sends data through the current transports.
    ///
    /// - Parameters:
    ///     - topic: The topic to send the data to.
    ///     - data: The data to send.
    public func send(to: UBID, data _: Data) {
        if to.count == 0 {
            return
        }

        // @todo send the message
    }

    /// Subscribes a to a specific topic.
    ///
    /// - Parameter
    ///     - topic: The topic to subscribe to.
    public func subscribe(_ topic: UBID) {
        if topics.contains(topic) {
            return
        }

        topics.append(topic)
        subscribeTo(topic)
    }

    /// Unsubscribe from a specific topic.
    ///
    /// - Parameter
    ///     - topic: The topic to unsubscribe from.
    public func unsubscribe(_ topic: UBID) {
        topics.removeAll(where: { $0 == topic })

        if children[topic] != nil, children[topic]!.count > 0 {
            return
        }

        unsubscribeFrom(topic)
    }

    func subscribeTo(_: UBID) {
        // @todo find parent and send subscription message
    }

    func unsubscribeFrom(_: UBID) {
        // @todo unsubscribe from parent
    }
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

        switch packet.type {
        case .subscribe:
            return didReceiveSubscribe(from: from, topic: UBID(packet.topic))
        case .unsubscribe:
            return didReceiveUnsubscribe(from: from, topic: UBID(packet.topic))
        default:
            break
        }

        let message = Message(protobuf: packet, from: from)

        forward(topic: message.topic, message: data, except: from)

        if !topics.contains(message.topic) {
            return
        }

        delegate?.node(self, didReceiveMessage: message)
    }

    public func transport(_: Transport, peerDidDisconnect _: Addr) {
        // @todo check if child is peer or parent
        //     if it is a child, remove it from children, if children is now empty unsubscribe
        //     if it is a parent, find a new parent to subscribe to the topic to recreate the broadcast tree.
    }

    func forward(topic: UBID, message: Data, except: Addr) {
        var forwarding = [Addr]()
        if let parent = parents[topic] {
            forwarding.append(parent)
        }

        if let child = children[topic] {
            forwarding.append(contentsOf: child)
        }

        let peers = Set(forwarding.filter { $0 != except })
        transports.forEach { _, transport in
            peers.intersection(Set(transport.peers)).forEach {
                transport.send(message: message, to: $0)
            }
        }
    }

    func didReceiveSubscribe(from: Addr, topic: UBID) {
        if children[topic] == nil {
            children[topic] = [Addr]()
        } else if children[topic]!.contains(from) {
            return
        }

        if !topics.contains(topic) {
            subscribeTo(topic)
        }

        children[topic]!.append(from)
    }

    func didReceiveUnsubscribe(from: Addr, topic: UBID) {
        guard children[topic] != nil else {
            return
        }

        children[topic]!.removeAll(where: { $0 == from })

        if children[topic]!.count > 0 {
            return
        }

        unsubscribeFrom(topic)
    }
}
