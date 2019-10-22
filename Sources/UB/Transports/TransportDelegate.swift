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

    /// This method is called when a transport connects to a specific peer.
    ///
    /// - Parameters:
    ///     - transport: The transport that connected to a peer.
    ///     - peer: The peer identifier.
    ///     - addr: The peer address.
    func transport(_ transport: Transport, didConnectToPeer peer: Addr, withAddr addr: Addr)

    /// This method is called when a transport disconnects from a specific peer.
    ///
    /// - Parameters:
    ///     - transport: The transport that disconnected from a peer.
    ///     - peer: The peer identifier.
    func transport(_ transport: Transport, didDisconnectFromPeer peer: Addr)
}
