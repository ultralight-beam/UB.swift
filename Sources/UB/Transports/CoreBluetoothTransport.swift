import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receieve message over Bluetooth
public class CoreBluetoothTransport: NSObject, Transport {
    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    static let ubServiceUUID = CBUUID(string: "AAAA")
    static let receiveCharacteristicUUID = CBUUID(string: "0002")

    // make this nicer, we need this cause we need a reference to the peripheral?
    var perp: CBPeripheral?

    public fileprivate(set) var peers = [Peer]()

    private var peripherals = [Addr: (CBPeripheral, CBCharacteristic)]()

    /// Initializes a CoreBluetoothTransport with a new CBCentralManager and CBPeripheralManager.
    public convenience override init() {
        self.init(
            centralManager: CBCentralManager(delegate: nil, queue: nil),
            peripheralManager: CBPeripheralManager(delegate: nil, queue: nil)
        )
    }

    /// Initializes a CoreBluetoothTransport.
    ///
    /// - Parameters:
    ///     - centralManager: The CoreBluetooth Central Manager to use.
    ///     - peripheralManager: The CoreBluetooth Peripheral Manager to use.
    public init(centralManager: CBCentralManager, peripheralManager: CBPeripheralManager) {
        self.centralManager = centralManager
        self.peripheralManager = peripheralManager
        super.init()
        self.centralManager.delegate = self
        self.peripheralManager.delegate = self
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
            let service = CBMutableService(type: CoreBluetoothTransport.ubServiceUUID, primary: true)

            let characteristic = CBMutableCharacteristic(
                type: CoreBluetoothTransport.receiveCharacteristicUUID,
                properties: .writeWithoutResponse, value: nil,
                permissions: .writeable
            )

            service.characteristics = [characteristic]
            peripheral.add(service)

            peripheral.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [CoreBluetoothTransport.ubServiceUUID],
                CBAdvertisementDataLocalNameKey: nil,
            ])
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Got a message! Ding!")
        for request in requests {
            if let value = request.value {
                print(value)
            }
        }
    }
}

extension CoreBluetoothTransport: CBCentralManagerDelegate {
    /// Lets us know if Bluetooth is in correct state to start.
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CoreBluetoothTransport.ubServiceUUID])
        }

        // @todo handling for other states
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
        centralManager.connect(peripheral)
    }

    // When connected to a devices, ask for the Services
    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CoreBluetoothTransport.ubServiceUUID])
    }

    public func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
        let peer = Addr(peripheral.identifier.bytes)

        peripherals.removeValue(forKey: peer)
        peers.removeAll(where: { $0.id == peer })
    }
}

extension CoreBluetoothTransport: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == CoreBluetoothTransport.ubServiceUUID }) {
            peripheral.discoverCharacteristics([CoreBluetoothTransport.receiveCharacteristicUUID], for: service)
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error _: Error?
    ) {
        let id = Addr(peripheral.identifier.bytes)
        if peripherals[id] != nil {
            return
        }

        let characteristics = service.characteristics
        if let char = characteristics?.first(where: { $0.uuid == CoreBluetoothTransport.receiveCharacteristicUUID }) {
            peripherals[id] = (peripheral, char)
            peers.append(Peer(id: id, services: [UBID]())) // @TODO SERVICES
        }
    }
}
