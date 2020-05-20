import Foundation

/// An interface used to handle events on the Node.
public protocol NodeDelegate: AnyObject {
    /// This method is called when a node receives a data.
    ///
    /// - Parameters:
    ///     - node: The node that received the data.
    ///     - data: The received data.
    func node(_ node: Node, didReceiveData data: Data) // @todo return something?
}
