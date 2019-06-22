import Foundation
import UB

class Transport: UB.Transport {

    func send(message: Message) { }

    func listen(_ handler: Handler) { }
}
