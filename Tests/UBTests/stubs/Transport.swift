import Foundation
import UB

class Transport: Transport {
    weak var delegate: TransportDelegate?

    private(set) var sent: [(Data, Addr)] = []

    var peers: [Peer] = []

    func send(message: Data, to: Addr) {
        sent.append((message, to))
    }

    func listen(identity: UBID) {}
}
