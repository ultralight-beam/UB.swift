import Foundation
import UB

class Transport: UB.Transport {
    private(set) var sent: [(Message, Addr)] = []

    var peers: [Peer] = []

    func send(message _: Message) {}

    func send(message: Message, to: Addr) {
        sent.append((message, to))
    }

    func listen(_: Handler) {}
}
