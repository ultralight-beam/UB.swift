import Foundation
import CoreBluetooth


/// CoreBluetoothTransport is used to send and receieve message over Bluetooth
public class CoreBluetoothTransport: NSObject, Transport {
    
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?

    private var testServiceID = CBUUID(string: "0xAAAA")
    private var testServiceID2 = CBUUID(string: "0xBBBB")
    
    private var perp: CBPeripheral? // make this an array for multiple devices

    
    public override convenience init(){
        self.init(cbManager: CBCentralManager(delegate: nil, queue: nil),
                  periphManager: CBPeripheralManager(delegate: nil, queue: nil))
        centralManager?.delegate = self
        peripheralManager?.delegate = self
    }
    
    public init(cbManager: CBCentralManager, periphManager: CBPeripheralManager) {
        super.init()
        centralManager = cbManager
        peripheralManager = periphManager

    }
    
    
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
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        <#code#>
    }
}


extension CoreBluetoothTransport: CBCentralManagerDelegate {
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
            
            centralManager?.scanForPeripherals(withServices: nil)
            
        }
    }
    
    public func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if let x = peripheral.name {

            //peripheral.discoverServices(nil)
            //            perp = peripheral;
            if x == "Blank"{
                perp = peripheral
                perp?.delegate = self

                print(x)
                decodePeripheralState(peripheralState: peripheral.state)
                centralManager?.connect(perp!)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // STEP 8: look for services of interest on peripheral
        print("gunna start discoverSerivces")
        perp?.discoverServices(nil)
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("servicessssss ")
        for service in peripheral.services! {
            
                print("Service: \(service)")
                
                // STEP 9: look for characteristics of interest
                // within services of interest
                //peripheral.discoverCharacteristics(nil, for: service)
            
        }
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
    
}


extension CoreBluetoothTransport {
    public func startScanning() {
    
    }
}
