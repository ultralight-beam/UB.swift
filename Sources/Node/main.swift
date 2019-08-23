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

class Delegate: IOBluetoothDeviceInquiryDelegate {

    func deviceInquiryStarted(_ sender: IOBluetoothDeviceInquiry!) {
        print("started")

    }
    
    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry!, device: IOBluetoothDevice!) {
        print(device.name)
        print("found")

    }
    func deviceInquiryUpdatingDeviceNamesStarted(_ sender: IOBluetoothDeviceInquiry!, devicesRemaining: UInt32) {
        print("updating")

    }
 
    func deviceInquiryDeviceNameUpdated(_ sender: IOBluetoothDeviceInquiry!, device: IOBluetoothDevice!, devicesRemaining: UInt32) {
        print("updated")

    }
    
    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry!, error: IOReturn, aborted: Bool) {
        print("complete")
    }
    
}

let delegate = Delegate()
let inquery = IOBluetoothDeviceInquiry(delegate: delegate)

inquery?.start()

RunLoop.current.run()
