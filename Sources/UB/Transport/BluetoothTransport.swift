import Foundation
import CoreBluetooth

/// Implements methods for sending and receiving messages via bluetooth.
public class BluetoothTransport: NSObject, Transport {

    fileprivate var central: CBCentralManager!

    public var status = TransportStatus.off

    public override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    public func send(message: Message) {

    }

    public func listen(_ handler: Handler) {

    }
}

extension BluetoothTransport: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
//        switch central.state {
//        case .unknown:
//            <#code#>
//        case .resetting:
//            <#code#>
//        case .unsupported:
//            <#code#>
//        case .unauthorized:
//            <#code#>
//        case .poweredOff:
//            <#code#>
//        case .poweredOn:
//            <#code#>
//        }
    }

}
