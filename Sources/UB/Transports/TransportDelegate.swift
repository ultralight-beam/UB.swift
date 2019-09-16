import Foundation

/// TransportDelegate is used to handle the receiving data.
public protocol TransportDelegate: AnyObject {
    /// Called when a transport receives new data.
    ///
    /// - Parameters:
    ///     - transport: The transport that received a data.
    ///     - data: The received data.
    ///     - from: The peer from which the data was received.
    func transport(_ transport: Transport, didReceiveData data: Data, from: Addr)
}
