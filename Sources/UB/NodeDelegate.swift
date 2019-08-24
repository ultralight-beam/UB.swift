import Foundation

/// NodeDelegate is used to handle the receiving of messages.
public protocol NodeDelegate {
    
    func node(_ node: Node, didReceiveMessage message: Message) // @todo return something?
    
}
