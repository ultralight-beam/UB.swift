import Foundation
import UB

class Service: UB.Service {

    var type: UBID {
        get {
            return [0, 1, 2]
        }
    }

    func handle(_ message: Message) {
    }
}
