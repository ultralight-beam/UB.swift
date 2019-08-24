//
// Created by Greg Markou on 2019-08-24.
//

import Foundation

class Flood {

    private(set) public var syncState: [SyncState]
    private var transport: Transport

    public init (transport: Transport) {
        self.transport = transport
    }

    public func receive(msg: Message) {
        switch msg.type {
        case MessageType.msg:
            receiveMsg(msg: msg)
        case MessageType.ack:
            receiveAck(msg: msg)
        }
    }

    public func receiveMsg(msg: Message) {
        guard let index = syncState.firstIndex(where: { $0.msg == msg }) else {
            syncState.append(SyncState(
                msg: msg,
                count: 0,
                lastSeen: NSDate().timeIntervalSince1970
            ))
            return
        }
        syncState[index].count += 1
        syncState[index].lastSeen = NSDate().timeIntervalSince1970
    }

    public func receiveAck(msg: Message) {
        guard let index = syncState.firstIndex(where: {$0.msg == msg}) else {
            throw("Error, acking a message that doesnt exist in cache")
        }
        syncState.remove(at: index)
    }

    public func send(msg: Message) {
        switch msg.type {
        case MessageType.msg:
            sendMsg(msg: msg)
        case MessageType.ack:
            sendAck(msg: msg)
        }
    }

    private func sendMsg(msg: Message) {
        guard let index = syncState.firstIndex(where: { $0.msg == msg }) else {
            syncState.append(SyncState(
                    msg: msg,
                    count: 0,
                    lastSeen: NSDate().timeIntervalSince1970
            ))
            return
        }
        syncState[index].count += 1
        syncState[index].lastSeen = NSDate().timeIntervalSince1970

        transport.peers().forEach { peer in
            transport.send(message: msg)
        }
    }

    private func sendAck(msg: Message) {
        guard let index = syncState.firstIndex(where: {$0.msg == msg}) else {
            throw("Error, acking a message that doesnt exist in cache")
        }
        syncState.remove(at: index)

        transport.send(message: msg) /// this means that the ack message needs to be crafted beforehand
    }

    private func cacheContains(msg: Message) -> Bool {
        return syncState.contains { $0.msg == msg }
    }
}

struct SyncState {
    public let msg: Message
    public var count: Int
    public var lastSeen: Double
}
