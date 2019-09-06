import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receieve message over Bluetooth
public class CoreBluetoothTransport: NSObject {
    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    static let ubServiceUUID = CBUUID(string: "AAAA")
    static let receiveCharacteristicUUID = CBUUID(string: "0002")

    // make this nicer, we need this cause we need a reference to the peripheral?
    var perp: CBPeripheral?

    public private(set) var peripherals = [Addr: (CBPeripheral, CBCharacteristic)]()

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
        return [] // centralManager.retrieveConnectedPeripherals(withServices: [testServiceID, testServiceID2])
    }

    /// Send implements a function to send messages between nodes using Bluetooth
    ///
    /// - Parameters:
    ///     - message: The message to send.
    public func send(message: Message, to: Addr) {
        if let peripheral = peripherals[to] {
            peripheral.0.writeValue(message.message, for: peripheral.1, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("Error: peripheral with uuid \(to) not found")
            // @todo error
        }
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

            let serialService = CBMutableService(type: CoreBluetoothTransport.ubServiceUUID, primary: true)

            let writeCharacteristics = CBMutableCharacteristic(type: WR_UUID,
                                                               properties: WR_PROPERTIES, value: nil,
                                                               permissions: WR_PERMISSIONS)
            serialService.characteristics = [writeCharacteristics]
            peripheral.add(serialService)

            peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [CoreBluetoothTransport.ubServiceUUID],
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
            centralManager.scanForPeripherals(withServices: [CoreBluetoothTransport.ubServiceUUID])
        }
    }

    // Try to connect to discovered devices
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData _: [String: Any],
        rssi _: NSNumber
    ) {
        perp = peripheral
        peripheral.delegate = self
        decodePeripheralState(peripheralState: peripheral.state, peripheral: peripheral)
        centralManager.connect(peripheral)
    }

    // When connected to a devices, ask for the Services
    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        perp = peripheral
        peripheral.discoverServices([CoreBluetoothTransport.ubServiceUUID])
    }

    public func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
        peripherals.removeValue(forKey: Addr(peripheral.identifier.bytes))
    }

    func decodePeripheralState(peripheralState: CBPeripheralState, peripheral: CBPeripheral) {
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
            print("UUID: \(peripheral.identifier)")
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
    }
}

extension CoreBluetoothTransport: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == CoreBluetoothTransport.ubServiceUUID }) else {
            return
        }

        peripheral.discoverCharacteristics([CoreBluetoothTransport.receiveCharacteristicUUID], for: service)
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error _: Error?
    ) {
        if let characteristic = service.characteristics?.first(where: { $0.uuid == CoreBluetoothTransport.receiveCharacteristicUUID }) {
            peripherals[Addr(peripheral.identifier.bytes)] = (peripheral, characteristic)
        }
    }
}
