import UB
import IOBluetooth

// @todo add IOBluetooth stuff

class Transport: UB.Transport {
    
    let inquery: IOBluetoothDeviceInquiry
    
    init() {
        inquery = IOBluetoothDeviceInquiry(delegate: nil)
        inquery.delegate = self
    }

    func send(message: Message) {
        
    }

    func listen(_ handler: Handler) {
        inquery.start()
    }
}

extension Transport: IOBluetoothDeviceInquiryDelegate {
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
