import CoreBluetooth
import Foundation

/// CoreBluetoothTransport is used to send and receive message over Bluetooth
public class CoreBluetoothTransport: NSObject, Transport {
    /// The transports delegate.
    public weak var delegate: TransportDelegate?

    ///  The peers a specific transport can send messages to.
    public fileprivate(set) var peers = [Peer]()

    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    private static let ubServiceUUID = CBUUID(string: "BEA3B031-76FB-4889-B3C7-000000000000")
    private static let receiveCharacteristicUUID = CBUUID(string: "BEA3B031-76FB-4889-B3C7-000000000001")

    private static let characteristic = CBMutableCharacteristic(
        type: CoreBluetoothTransport.receiveCharacteristicUUID,
        properties: [.read, .writeWithoutResponse, .notify],
        value: nil,
        permissions: [.writeable, .readable]
    )

    // make this nicer, we need this cause we need a reference to the peripheral?
    private var perp: CBPeripheral?
    private var centrals = [Addr: CBCentral]()
    private var peripherals = [Addr: (peripheral: CBPeripheral, characteristic: CBCharacteristic)]()

    private var streams = [Addr: StreamClient]()

    private var psm: CBL2CAPPSM?

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
    ///     - to: The recipient address of the message.
    public func send(message: Data, to: Addr) {
        guard let stream = streams[to] else {
            return
        }

        stream.write(message)
    }

    /// Listen implements a function to receive messages being sent to a node.
    public func listen() {
        // @todo mark as listening, only turn on peripheral characteristic at this point, etc.
    }

    fileprivate func remove(peer: Addr) {
        streams.removeValue(forKey: peer)
        peers.removeAll(where: { $0.id == peer })
    }

    fileprivate func add(central: CBCentral) {
        let id = Addr(central.identifier.bytes)

        if centrals[id] != nil {
            return
        }

        centrals[id] = central
        peers.append(Peer(id: id, services: [UBID]()))
    }

    fileprivate func add(channel: CBL2CAPChannel) {
        guard let input = channel.inputStream, let output = channel.outputStream else {
            // @todo error?
            return
        }

        let client = StreamClient(input: input, output: output)
        client.delegate = self
        streams[Addr(channel?.peer.identifier.bytes)] = client
    }
}

/// :nodoc:
extension CoreBluetoothTransport: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: CoreBluetoothTransport.ubServiceUUID, primary: true)

            service.characteristics = [CoreBluetoothTransport.characteristic]
            peripheral.add(service)

            peripheral.publishL2CAPChannel(withEncryption: false)
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [service.uuid],
            CBAdvertisementDataLocalNameKey: nil,
        ])
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

    public func peripheralManager(_: CBPeripheralManager, central: CBCentral, didSubscribeTo _: CBCharacteristic) {
        add(central: central)
        update(value: psm?.bytes)
    }

    public func peripheralManager(_: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom _: CBCharacteristic) {
        // @todo check that this is the characteristic
        let id = Addr(central.identifier.bytes)
        centrals.removeValue(forKey: id)
        peers.removeAll(where: { $0.id == id })
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        psm = PSM

        guard centrals.count > 0 else {
            return
        }

        update(value: psm?.bytes)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        // @todo
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        if error != nil {
            // @todo handle
        }

        guard let channel = channel else {
            return
        }

        add(channel: channel)
    }

    private func update(value: Data) {
        peripheralManager.updateValue(
            value,
            for: CoreBluetoothTransport.characteristic,
            onSubscribedCentrals: centrals.values
        )
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
        error: Error?
    ) {

        if error != nil {
            // @todo
        }

        if let char = characteristics?.first(where: { $0.uuid == CoreBluetoothTransport.receiveCharacteristicUUID }) {
            peripheral.setNotifyValue(true, for: char)
        }

//        let id = Addr(peripheral.identifier.bytes)
//        if peripherals[id] != nil {
//            return
//        }
//
//        let characteristics = service.characteristics
//        if let char = characteristics?.first(where: { $0.uuid == CoreBluetoothTransport.receiveCharacteristicUUID }) {
//            peripherals[id] = (peripheral, char)
//            peripherals[id]?.peripheral.setNotifyValue(true, for: char)
//            // @todo we may need to do some handshake to obtain services from a peer.
//            peers.append(Peer(id: id, services: [UBID]()))
//        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.contains(where: { $0.uuid == CoreBluetoothTransport.ubServiceUUID }) {
            remove(peer: Addr(peripheral.identifier.bytes))
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if error != nil {
            // @todo
        }

        guard let value = characteristic.value else { return }

        let psm = value.withUnsafeBytes {
            $0.load(as: UInt16.self)
        }

        peripheral.openL2CAPChannel(psm)
    }

    public func peripheral(
        _: CBPeripheral,
        didUpdateNotificationStateFor _: CBCharacteristic,
        error _: Error?
    ) {
        // @todo figure out exactly what we will want to do here.
    }

    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        if error != nil {
            // @todo handle
        }

        guard let channel = channel else {
            return
        }

        add(channel: channel)
    }
}

/// :nodoc:
extension CoreBluetoothTransport: StreamClientDelegate {

    public func client(_ client: StreamClient, didReceiveData data: Data) {
        guard let peer = streams.first(where: { $0.value == client })?.key else {
            return // @todo log?
        }

        delegate?.transport(self, didReceiveData: data, from: peer)
    }

}