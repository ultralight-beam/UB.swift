import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receive message over Bluetooth
public class CoreBluetoothTransport: NSObject {

    /// :nodoc:
    public weak var delegate: TransportDelegate?

    /// :nodoc:
    public fileprivate(set) var peers = [Addr: Addr]()

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

    private var identityCharacteristic = CBMutableCharacteristic(
        type: CBUUID(string: "BEA3B031-76FB-4889-B3C7-000000000001"),
        properties: [.read, .writeWithoutResponse, .notify],
        value: nil,
        permissions: [.writeable, .readable]
    )

    private static let receiveCharacteristic = CBMutableCharacteristic(
        type: CBUUID(string: "BEA3B031-76FB-4889-B3C7-000000000002"),
        properties: [.read, .writeWithoutResponse, .notify],
        value: nil,
        permissions: [.writeable, .readable]
    )

    private enum State {
        case off, listening
    }

    private var state = State.off

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
        peers.removeValue(forKey: peer)
    }

    private func add(central: CBCentral) {
        let id = Addr(central.identifier.bytes)

        if centrals[id] != nil {
            return
        }

        centrals[id] = central

        // @todo figure out identity for centrals
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

    public func listen(identity: UBID) {
        state = .listening

        identityCharacteristic.value = Data(identity)

        if peripheralManager.state == .poweredOn {
            startAdvertising()
        }

        if centralManager.state == .poweredOn {
            startScanning()
        }
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn && state == .listening {
            startAdvertising()
        }
    }

    public func peripheralManager(_: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard let data = request.value else {
                // @todo
                continue
            }

            let id = Addr(request.central.identifier.bytes)

            if request.characteristic.uuid == identityCharacteristic.uuid {
                let addr = Addr(data)
                peers[id] = addr
                delegate?.transport(self, didConnectToPeer: addr, withAddr: id)
                continue
            }

            guard let peer = peers[id] else { continue }
            delegate?.transport(self, didReceiveData: data, from: peer)
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
        peers.removeValue(forKey: id)
    }

    fileprivate func startAdvertising() {
        let service = CBMutableService(type: CoreBluetoothTransport.ubServiceUUID, primary: true)

        service.characteristics = [
            identityCharacteristic,
            CoreBluetoothTransport.receiveCharacteristic,
        ]

        peripheralManager.add(service)

        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [CoreBluetoothTransport.ubServiceUUID],
        ])
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && state == .listening {
            startScanning()
        }
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

    fileprivate func startScanning() {
        centralManager.scanForPeripherals(withServices: [CoreBluetoothTransport.ubServiceUUID])
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == CoreBluetoothTransport.ubServiceUUID }) {
            peripheral.discoverCharacteristics(
                [identityCharacteristic.uuid, CoreBluetoothTransport.receiveCharacteristic.uuid],
                for: service
            )
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

        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == identityCharacteristic.uuid {
                if let data = characteristic.value {
                    let addr = Addr(data)
                    peers[id] = addr
                    delegate?.transport(self, didConnectToPeer: addr, withAddr: id)
                }
            }

            if characteristic.uuid == CoreBluetoothTransport.receiveCharacteristic.uuid {
                peripherals[id] = (peripheral, characteristic)
            }
        }

        if peers[id] != nil, let characteristic = peripherals[id]?.characteristic {
            peripherals[id]?.peripheral.setNotifyValue(true, for: characteristic)
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
        guard let value = characteristic.value, let peer = peers[Addr(peripheral.identifier.bytes)] else { return }
        delegate?.transport(self, didReceiveData: value, from: peer)
    }

    public func peripheral(
        _: CBPeripheral,
        didUpdateNotificationStateFor _: CBCharacteristic,
        error _: Error?
    ) {
        // @todo figure out exactly what we will want to do here.
    }
}
