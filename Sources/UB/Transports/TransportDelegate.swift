import Foundation

/// An interface used to handle events on the Transport.
public protocol TransportDelegate: AnyObject {
    /// This method is called when a transport receives new data.
    ///
    /// - Parameters:
    ///     - transport: The transport that received a data.
    ///     - data: The received data.
    ///     - from: The peer from which the data was received.
    func transport(_ transport: Transport, didReceiveData data: Data, from: Addr)
}
