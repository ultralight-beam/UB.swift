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
    public func send(topic: UBID, data: Data) {
        if topic.count == 0 {
            return
        }

        let packet = Packet.new(topic: Data(topic), type: .message, body: data)
        guard let data = try? packet.serializedData() else {
            // @todo error
            return
        }

        send(topic: topic, data: data)
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
        unsubscribeFrom(topic)
    }

    private func subscribeTo(_ topic: UBID) {
        if parents[topic] != nil {
            return
        }

        let packet = Packet.new(topic: Data(topic), type: .subscribe, body: Data(count: 0))
        guard let data = try? packet.serializedData() else {
            return // @todo error
        }

        var potential = [Addr: String]()
        transports.forEach { label, transport in
            guard let close = transport.peers.closest(to: Addr(topic)) else {
                return
            }

            potential[close] = label
        }

        var closest = (transport: "", addr: Addr(repeating: 0, count: 0), distance: Int.max)
        potential.forEach { peer, transport in
            let dist = peer.distance(to: Addr(topic))
            if dist < closest.distance {
                closest = (transport: transport, addr: peer, distance: dist)
            }
        }

        if closest.transport == "" {
            return // @todo this would imply we found none error
        }

        transports[closest.transport]?.send(message: data, to: closest.addr)
        parents[topic] = closest.addr
    }

    private func unsubscribeFrom(_ topic: UBID) {
        if children[topic] != nil, children[topic]!.count > 0 {
            return
        }

        let packet = Packet.new(topic: Data(topic), type: .unsubscribe, body: Data(count: 0))
        guard let data = try? packet.serializedData() else {
            // @todo error
            return
        }

        guard let parent = parents[topic] else { return }
        transports.forEach { _, transport in
            if transport.peers.contains(parent) {
                transport.send(message: data, to: parent)
            }
        }
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

        let topic = UBID(packet.topic)

        switch packet.type {
        case .subscribe:
            return didReceiveSubscribe(from: from, topic: topic)
        case .unsubscribe:
            return didReceiveUnsubscribe(from: from, topic: topic)
        default:
            break
        }

        send(topic: topic, message: packet.body, except: from)

        if !topics.contains(topic) {
            return
        }

        delegate?.node(self, didReceiveData: packet.body)
    }

    public func transport(_: Transport, peerDidDisconnect peer: Addr) {
        let childTopics = children.filter { $0.value.contains(peer) }
        childTopics.forEach { topic, _ in
            didReceiveUnsubscribe(from: peer, topic: topic)
        }

        let topics = parents.filter { $0.value == peer }
        topics.forEach { topic, _ in
            parents.removeValue(forKey: topic)
            subscribeTo(topic)
        }
    }

    /// Send a message to the parent and children excluding a specific address.
    ///
    /// - Parameters:
    ///     - topic: The topic to send to.
    ///     - message: The message to send.
    ///     - except: The address to exclude. (Optional)
    func send(topic: UBID, message: Data, except: Addr?) {
        var forwarding = [Addr]()
        if let parent = parents[topic] {
            forwarding.append(parent)
        }

        if let child = children[topic] {
            forwarding.append(contentsOf: child)
        }

        if except != nil {
            forwarding = forwarding.filter { $0 != except }
        }

        let peers = Set(forwarding)
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

        unsubscribeFrom(topic)
    }
}
