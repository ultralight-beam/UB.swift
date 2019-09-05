import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receieve message over Bluetooth
public class CoreBluetoothTransport: NSObject {
    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    private var testServiceID = CBUUID(string: "0xAAAA")
    private var testServiceID2 = CBUUID(string: "0xBBBB")
    
    let receiveCharacteristic = CBMutableCharacteristic(
        type:  CBUUID(string: "0002"),
        properties: CBCharacteristicProperties.writeWithoutResponse,
        value: nil,
        permissions: CBAttributePermissions.writeable
    )

    var test: CBCharacteristic?
    
    private var perp: CBPeripheral? // make this an array for multiple devices
   // private var peripherals = [Addr:CBPeripheral?]() // make this an array for multiple devices
    
    
    
    private var outQueue = [(Message,Addr)]()
    

    public convenience override init() {
        self.init(
            centralManager: CBCentralManager(delegate: nil, queue: nil),
            peripheralManager: CBPeripheralManager(delegate: nil, queue: nil)
        )
    }

    public init(centralManager: CBCentralManager, peripheralManager: CBPeripheralManager) {
        self.centralManager = centralManager
        self.peripheralManager = peripheralManager
        super.init()
        self.centralManager.delegate = self
        self.peripheralManager.delegate = self
    }
}

extension CoreBluetoothTransport: Transport {
    public var peers: [Peer] {
        return []//centralManager.retrieveConnectedPeripherals(withServices: [testServiceID, testServiceID2])
    }

    /// Send implements a function to send messages between nodes using Bluetooth
    ///
    /// - Parameters:
    ///     - message: The message to send.
    public func send(message: Message, to: Addr) {
        // check bluetooth is running
        
        guard let uuid = String(bytes: to, encoding: .utf8) else {
            print("Error: not a valid Byte sequence")
            return
        }
        guard let toUUID = UUID(uuidString: uuid) else {
            print("Error: not a valid UUID sequence")
            return
        }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [toUUID])
        if peripherals.count == 0 {
            print("Error: peripheral with uuid \(to) not found")
            return
        }
        
        let peripheral = peripherals[0]
        print("NAME : \(peripheral)")
        
        peripheral.writeValue(message.message, for: test!, type: CBCharacteristicWriteType.withoutResponse)
    }

    /// Listen implements a function to receive messages being sent to a node.
    ///
    /// - Parameters:
    ///     - handler: The message handler to handle received messages.
    public func listen(_: (Message) -> Void) {
        print("B")
    }
}

extension CoreBluetoothTransport: CBPeripheralManagerDelegate {
    // Start Advertisement
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
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
                if let messageText = String(data: value, encoding: String.Encoding.utf8) as! String? {
                    print("GOOOOTEEMMM   \(messageText)")

                } else {
                    print("failed to decode string of \(value.hexEncodedString())")
                }
                // appendMessageToChat(message: Message(text: messageText!, isSent: false))
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
            centralManager.scanForPeripherals(withServices: [testServiceID, testServiceID2])
        }
    }

    // Try to connect to discovered devices
    public func centralManager(_: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData _: [String: Any],
                               rssi _: NSNumber) {
        perp = peripheral
        perp?.delegate = self
        decodePeripheralState(peripheralState: peripheral.state, peripheral: peripheral)
        centralManager.connect(perp!)
    }

    // When connected to a devices, ask for the Services
    public func centralManager(_: CBCentralManager, didConnect _: CBPeripheral) {
        // look for services of interest on peripheral
        perp?.discoverServices([testServiceID, testServiceID2])
    }

    // Handle Disconnections
    public func centralManager(_: CBCentralManager, didDisconnectPeripheral _: CBPeripheral, error _: Error?) {}

    func decodePeripheralState(peripheralState: CBPeripheralState, peripheral: CBPeripheral) {
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
            if #available(OSX 10.13, *) {
                print("UUID: \(peripheral.identifier)")
            } else {
                // Fallback on earlier versions
            }
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
    }
}

extension CoreBluetoothTransport: CBPeripheralDelegate {
    // ask for Characteristics for each Service of interest
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        print("servicessssss ")
        for service in peripheral.services! {
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // called with characteristics
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error _: Error?
    ) {
        
        for characteristic in service.characteristics! {
            if characteristic.uuid == CBUUID(string: "0002"){
                print("WE GOT THE RIGHT CHARACTERISTIC")
                test = characteristic
            }

            // peripheral.readValue(for: characteristic)
//            if characteristic.uuid == testServiceID {
            //let data = Data(bytes: [97, 98, 99, 100])
                print("Characteristic: \(characteristic)")

//                print("Sending some good shit")
//                let data = outQueue[0].0.message;
//                peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
//                outQueue.remove(at:0)
            
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
    public func startScanning() {}
}
