import Foundation
import UB

class Transport: UB.Transport {

    var status: TransportStatus {
        get {
            return .off
        }
    }

    func send(message: Message) { }

    func listen(_ handler: Handler) { }
}
