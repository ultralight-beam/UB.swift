import Foundation

/// NodeDelegate is used to handle the receiving of messages.
public protocol NodeDelegate {
    
    /// Called when a node receives a message.
    ///
    /// - Parameters:
    ///     - node: The node that received the message.
    ///     - message: The received message.
    func node(_ node: Node, didReceiveMessage message: Message) // @todo return something?
}
