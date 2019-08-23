//import CoreBluetooth
//
//class Delegates:
//    NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == CBManagerState.poweredOn {
//            central.scanForPeripherals(withServices: nil, options: nil)
//        } else {
//            print("Bluetooth not available.a")
//        }
//    }
//}
//
//let a = Delegates();
//let manager = CBCentralManager(delegate: a, queue: nil)
//
//
//if manager.state == CBManagerState.poweredOn {
//    manager.scanForPeripherals(withServices: nil, options: nil)
//} else {
//    print("Bluetooth not available.b")
//}

import IOBluetooth

class BluetoothDevices {
    
    let bluetoothDeviceInquiryDelegate = BluetoothDeviceInquiryDelegate()
    let inquery = IOBluetoothDeviceInquiry(delegate: bluetoothDeviceInquiryDelegate);
    
    func pairedDevices() {
        print("Bluetooth devices:")
        guard let devices = IOBluetoothDevice.pairedDevices() else {
            print("No devices")
            return
        }
        for item in devices {
            if let device = item as? IOBluetoothDevice {
                print("Name: \(device.name)")
                print("Paired?: \(device.isPaired())")
                print("Connected?: \(device.isConnected())")
            }
        }
    }
    func scanForDevices() -> IOReturn {
         return inquery.start()
    }
    
    func getDevices() -> [Any] {
         return inquery.foundDevices();
    }
}

var bt = BluetoothDevices()
//bt.pairedDevices()

print("SCAN \(bt.scanForDevices())")

print("devs \(bt.getDevices())")

RunLoop.current.run()
