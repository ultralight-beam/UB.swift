import Foundation
import UB
import SwiftProtobuf

let UBBT = CoreBluetoothTransport()

let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
    print(UBBT.peers.count)
    if UBBT.peers.count == 1 {
        UBBT.send(message: Data(repeating: 8, count: 4), to: UBBT.peers[0].id)
    }
}

RunLoop.current.run()
