import Foundation
import UB

let UBBT = CoreBluetoothTransport()

let message = Message(
    proto: UBID(repeating: 1, count: 1),
    recipient: Addr(repeating: 4, count: 4),
    from: Addr(repeating: 2, count: 3),
    origin: Addr(repeating: 2, count: 3),
    message: Data(repeating: 8, count: 3)
)

let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
    print(UBBT.peers.count)
    if UBBT.peers.count == 1 {
        UBBT.send(message: message, to: UBBT.peers[0].id)
    }
}

RunLoop.current.run()
