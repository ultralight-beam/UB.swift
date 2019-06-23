import Foundation

/// Implements methods for sending and receiving messages via bluetooth.
public class BluetoothTransport: Transport {

    public var status: TransportStatus {
        get { return .off }
    }

    public func send(message: Message) {

    }

    public func listen(_ handler: Handler) {

    }
}
