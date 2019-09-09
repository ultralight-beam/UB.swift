import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receieve message over Bluetooth
public class CoreBluetoothTransport: NSObject, Transport {
    /// The transports delegate.
    public weak var delegate: TransportDelegate?

    ///  The peers a specific transport can send messages to.
    public fileprivate(set) var peers = [Peer]()

    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager
    
    private static let centralQueue = DispatchQueue(label: "com.UB.centralQueue", attributes: .concurrent)
    private static let peripheralQueue = DispatchQueue(label: "com.UB.peripheralQueue", attributes: .concurrent)


    private static let ubServiceUUID = CBUUID(string: "AAAA")
    private static let receiveCharacteristicUUID = CBUUID(string: "0002")

    // make this nicer, we need this cause we need a reference to the peripheral?
    private var perp: CBPeripheral?
    private var peripherals = [Addr: (CBPeripheral, CBCharacteristic)]()

    /// Initializes a CoreBluetoothTransport with a new CBCentralManager and CBPeripheralManager.
    public convenience override init() {
        self.init(
            centralManager: CBCentralManager(delegate: nil, queue: CoreBluetoothTransport.centralQueue),
            peripheralManager: CBPeripheralManager(delegate: nil, queue: CoreBluetoothTransport.peripheralQueue)
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
    ///     - to: The recipient address of the message.
    public func send(message: Data, to: Addr) {
        if let peripheral = peripherals[to] {
            peripheral.0.writeValue(message, for: peripheral.1, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("Error: peripheral with uuid \(to) not found")
            // @todo error
        }
    }

    /// Listen implements a function to receive messages being sent to a node.
    public func listen() {
        // @todo mark as listening, only turn on peripheral characteristic at this point, etc.
    }

    fileprivate func remove(peer: Addr) {
        peripherals.removeValue(forKey: peer)
        peers.removeAll(where: { $0.id == peer })
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBPeripheralManagerDelegate {
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

    public func peripheralManager(_: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Got a message! Ding!")
        for request in requests {
            guard let data = request.value else {
                // @todo
                return
            }
            DispatchQueue.main.async { () -> Void in
                self.delegate?.transport(self, didReceiveData: data, from: Addr(request.central.identifier.bytes))
            }
        }
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CoreBluetoothTransport.ubServiceUUID])
        }

        // @todo handling for other states
    }

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

    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CoreBluetoothTransport.ubServiceUUID])
    }

    public func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
        remove(peer: Addr(peripheral.identifier.bytes))
    }
}

/// :nodoc:
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

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.contains(where: { $0.uuid == CoreBluetoothTransport.ubServiceUUID }) {
            remove(peer: Addr(peripheral.identifier.bytes))
        }
    }
}
