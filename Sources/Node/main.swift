import IOBluetooth
import UB

let node = UB.Node()
let transport = Transport()

node.add(transport: transport)

RunLoop.current.run()
