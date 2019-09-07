import Foundation
import UB

class Transport: UB.Transport {
    
    weak var delegate: TransportDelegate?
    
    private(set) var sent: [(Message, Addr)] = []

    var peers: [Peer] = []

    func send(message: Message, to: Addr) {
        sent.append((message, to))
    }

    func listen() {}
}
