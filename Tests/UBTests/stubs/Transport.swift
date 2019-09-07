import Foundation
import UB

class Transport: UB.Transport {
    private(set) var sent: [(Data, Addr)] = []

    var peers: [Peer] = []

    func send(message: Data, to: Addr) {
        sent.append((message, to))
    }

    func listen(_: @escaping Handler) {}
}
