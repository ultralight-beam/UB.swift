import Foundation
import UB

class Transport: UB.Transport {

    var peers = [Addr]()

    func send(message: Message) { }

    func listen(_ handler: Handler) { }
}
