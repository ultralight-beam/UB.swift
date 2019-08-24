//import IOBluetooth
//
//class Delegate: IOBluetoothDeviceInquiryDelegate {
//
//    func deviceInquiryStarted(_ sender: IOBluetoothDeviceInquiry!) {
//        print("started")
//
//    }
//
//    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry!, device: IOBluetoothDevice!) {
//        print(device.name)
//        print("found")
//
//    }
//    func deviceInquiryUpdatingDeviceNamesStarted(_ sender: IOBluetoothDeviceInquiry!, devicesRemaining: UInt32) {
//        print("updating")
//
//    }
//
//    func deviceInquiryDeviceNameUpdated(_ sender: IOBluetoothDeviceInquiry!, device: IOBluetoothDevice!, devicesRemaining: UInt32) {
//        print("updated")
//
//    }
//
//    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry!, error: IOReturn, aborted: Bool) {
//        print("complete")
//    }
//
//}
//
//let delegate = Delegate()
//let inquery = IOBluetoothDeviceInquiry(delegate: delegate)
//inquery?.searchType = kIOBluetoothDeviceSearchClassic.rawValue
//
//inquery?.start()
//
//RunLoop.current.run()

import IOBluetooth
import UB

let node = UB.Node()
let transport = Transport()

node.add(transport: transport)

RunLoop.current.run()
