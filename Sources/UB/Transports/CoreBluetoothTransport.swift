import Foundation
import CoreBluetooth


/// CoreBluetoothTransport is used to send and receieve message over Bluetooth
public class CoreBluetoothTransport: NSObject {
    
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?

    private var testServiceID = CBUUID(string: "0xAAAA")
    private var testServiceID2 = CBUUID(string: "0xBBBB")
    
    private var perp: CBPeripheral? // make this an array for multiple devices
    private var peripherals: [CBPeripheral?] = [] // make this an array for multiple devices
    
    public override convenience init() {
        self.init(
            centralManager: CBCentralManager(delegate: nil, queue: nil),
            peripheralManager: CBPeripheralManager(delegate: nil, queue: nil)
        )
        centralManager?.delegate = self
        peripheralManager?.delegate = self
    }
    
    public init(centralManager: CBCentralManager, peripheralManager: CBPeripheralManager) {
        super.init()
        self.centralManager = centralManager
        self.peripheralManager = peripheralManager

    }
    
}

extension CoreBluetoothTransport: Transport {
    
    /// Send implements a function to send messages between nodes using Bluetooth
    ///
    /// - Parameters:
    ///     - message: The message to send.
    public func send(message: Message) {
        print("A")
    }
    
    /// Listen implements a function to receive messages being sent to a node.
    ///
    /// - Parameters:
    ///     - handler: The message handler to handle received messages.
    public func listen(_ handler: (Message) -> Void) {
        print("B")
    }
    
}

extension CoreBluetoothTransport: CBPeripheralManagerDelegate {
    
    // Start Advertisement
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn){
            
            let WR_UUID = CBUUID(string: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
            let WR_PROPERTIES: CBCharacteristicProperties = .write
            let WR_PERMISSIONS: CBAttributePermissions = .writeable
            
            let serialService = CBMutableService(type: testServiceID, primary: true)
            
            let writeCharacteristics = CBMutableCharacteristic(type: WR_UUID,
                                                               properties: WR_PROPERTIES, value: nil,
                                                               permissions: WR_PERMISSIONS)
            serialService.characteristics = [writeCharacteristics]
            peripheral.add(serialService)

            peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [testServiceID, testServiceID2],
                                                CBAdvertisementDataLocalNameKey: nil])
        }
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Got a message! Ding!")
        for request in requests {
            if let value = request.value {
                
                if let messageText = String(data: value, encoding: String.Encoding.utf8) as String!{
                    print("GOOOOTEEMMM   \(messageText)")

                } else {
                    print("failed to decode string of \(value.hexEncodedString())")
                }
                //appendMessageToChat(message: Message(text: messageText!, isSent: false))
            }
            peripheral.respond(to: request, withResult: .success)
        }
    }
}


extension CoreBluetoothTransport: CBCentralManagerDelegate {
    
    /// Lets us know if Bluetooth is in correct state to start.
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            centralManager?.scanForPeripherals(withServices: [testServiceID, testServiceID2])
            
        }
    }
    
    // Try to connect to discovered devices
    public func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
            perp = peripheral
            perp?.delegate = self
            peripherals.append(perp)
            print(peripherals.count)
            decodePeripheralState(peripheralState: peripheral.state)
            centralManager?.connect(perp!)
    }
    
    // When connected to a devices, ask for the Services
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // look for services of interest on peripheral
        perp?.discoverServices([testServiceID, testServiceID2])
    }
    
    
    
    // Handle Disconnections
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
        
    }
}

extension CoreBluetoothTransport: CBPeripheralDelegate{
    // ask for Characteristics for each Service of interest
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("servicessssss ")
        for service in peripheral.services! {
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // called with characteristics
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("Characteristic: \(characteristic)")
            //peripheral.readValue(for: characteristic)
//            if characteristic.uuid == testServiceID {
                print("Sending some good shit")
                let data = Data(bytes: [97,98,99,100])
                peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
//            }

        }
    }
    
//    // called when reading a value from peripheral characteristic data field.
//    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        let data = Data(bytes: characteristic.value!)
//        print("Characteristic Value: \(data.hexEncodedString())")
//    }

    
    
    
}


extension CoreBluetoothTransport {
    public func startScanning() {
    
    }
}

