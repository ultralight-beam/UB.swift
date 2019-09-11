import Foundation

/// An interface used to handle events on the StreamClient.
protocol StreamClientDelegate: AnyObject {
    /// This method is called when a client receives new data.
    ///
    /// - Parameters:
    ///     - client: The client which received data.
    ///     - data: The data that was received.
    func client(_ client: StreamClient, didReceiveData data: Data)
}
