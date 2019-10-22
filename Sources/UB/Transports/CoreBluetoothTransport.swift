import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receive message over Bluetooth
public class CoreBluetoothTransport: NSObject {
    /// :nodoc:
    public weak var delegate: TransportDelegate?

    /// :nodoc:
    public fileprivate(set) var peers = [Peer]()

    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    private static let centralQueue = DispatchQueue(
        label: "com.ultralight-beam.bluetooth.centralQueue",
        attributes: .concurrent
    )

    private static let peripheralQueue = DispatchQueue(
        label: "com.ultralight-beam.bluetooth.peripheralQueue",
        attributes: .concurrent
    )

    private static let ubServiceUUID = CBUUID(string: "BEA3B031-76FB-4889-B3C7-000000000000")

    private static let receiveCharacteristic = CBMutableCharacteristic(
        type: CBUUID(string: "BEA3B031-76FB-4889-B3C7-000000000001"),
        properties: [.read, .writeWithoutResponse, .notify],
        value: nil,
        permissions: [.writeable, .readable]
    )

    // make this nicer, we need this cause we need a reference to the peripheral?
    private var perp: CBPeripheral?
    private var centrals = [Addr: CBCentral]()
    private var peripherals = [Addr: (peripheral: CBPeripheral, characteristic: CBCharacteristic)]()

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
    ///     - centralManager: The CBCentralManager to use.
    ///     - peripheralManager: The CBPeripheralManager to use.
    public init(centralManager: CBCentralManager, peripheralManager: CBPeripheralManager) {
        self.centralManager = centralManager
        self.peripheralManager = peripheralManager
        super.init()
        self.centralManager.delegate = self
        self.peripheralManager.delegate = self
    }

    private func remove(peer: Addr) {
        peripherals.removeValue(forKey: peer)
        peers.removeAll(where: { $0.id == peer })
    }

    private func add(central: CBCentral) {
        let id = Addr(central.identifier.bytes)

        if centrals[id] != nil {
            return
        }

        centrals[id] = central

        if peers.filter({ $0.id == id }).count != 0 {
            return
        }

        peers.append(Peer(id: id, services: [UBID]()))
    }
}

/// :nodoc:
extension CoreBluetoothTransport: Transport {
    public func send(message: Data, to: Addr) {
        if let peer = peripherals[to] {
            return peer.peripheral.writeValue(
                message,
                for: peer.characteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
        }

        if let central = centrals[to] {
            peripheralManager.updateValue(
                message,
                for: CoreBluetoothTransport.receiveCharacteristic,
                onSubscribedCentrals: [central]
            )
        }
    }

    public func listen() {
        // @todo mark as listening, only turn on peripheral characteristic at this point, etc.
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: CoreBluetoothTransport.ubServiceUUID, primary: true)

            service.characteristics = [CoreBluetoothTransport.receiveCharacteristic]
            peripheral.add(service)

            peripheral.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [CoreBluetoothTransport.ubServiceUUID],
            ])
        }
    }

    public func peripheralManager(_: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard let data = request.value else {
                // @todo
                return
            }

            delegate?.transport(self, didReceiveData: data, from: Addr(request.central.identifier.bytes))
            add(central: request.central)
        }
    }

    public func peripheralManager(
        _: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo _: CBCharacteristic
    ) {
        add(central: central)
    }

    public func peripheralManager(
        _: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom _: CBCharacteristic
    ) {
        // @todo check that this is the characteristic
        let id = Addr(central.identifier.bytes)
        centrals.removeValue(forKey: id)
        peers.removeAll(where: { $0.id == id })
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
            peripheral.discoverCharacteristics([CoreBluetoothTransport.receiveCharacteristic.uuid], for: service)
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
        if let char = characteristics?.first(where: { $0.uuid == CoreBluetoothTransport.receiveCharacteristic.uuid }) {
            peripherals[id] = (peripheral, char)
            peripherals[id]?.peripheral.setNotifyValue(true, for: char)
            // @todo we may need to do some handshake to obtain services from a peer.

            if peers.filter({ $0.id == id }).count != 0 {
                return
            }

            peers.append(Peer(id: id, services: [UBID]()))
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.contains(where: { $0.uuid == CoreBluetoothTransport.receiveCharacteristic.uuid }) {
            remove(peer: Addr(peripheral.identifier.bytes))
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error _: Error?
    ) {
        guard let value = characteristic.value else { return }

        delegate?.transport(self, didReceiveData: value, from: Addr(peripheral.identifier.bytes))
    }

    public func peripheral(
        _: CBPeripheral,
        didUpdateNotificationStateFor _: CBCharacteristic,
        error _: Error?
    ) {
        // @todo figure out exactly what we will want to do here.
    }
}
