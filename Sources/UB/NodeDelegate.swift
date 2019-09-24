import Foundation

/// An interface used to handle events on the Node.
public protocol NodeDelegate: AnyObject {
    /// This method is called when a node receives a message.
    ///
    /// - Parameters:
    ///     - node: The node that received the message.
    ///     - message: The received message.
    func node(_ node: Node, didReceiveMessage message: Message) // @todo return something?
}
