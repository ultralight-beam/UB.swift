import Foundation
import UB

class Transport: UB.Transport {

    private(set) var sent: [(Message, Addr)] = []

    private(set) var peers: [Peer] = []

    func add(peer: Peer) {
        peers.append(peer)
    }

    func send(message: Message, to: Addr) {
        sent.append((message, to))
    }

    func listen(_ handler: Handler) { }
}
