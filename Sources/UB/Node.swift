import Foundation

// @todo figure out architecture to support new forwarding algorithm.

/// An ultralight beam node, handles the interaction with transports and services.
public class Node {

    /// The known transports for the node.
    private(set) public var transports = [String: Transport]()
    
    /// The nodes delegate.
    public var delegate: NodeDelegate?
    
    public init() { }

    /// Adds a new transport to the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The new *Transport* to add.
    public func add(transport: Transport) {
        let id = String(describing: transport)

        if transports[id] != nil {
            return // @TODO: Maybe errors?
        }

        transport.listen { msg in
            
            // @todo delegate should return something where we handle retransmission.
            
            delegate?.node(self, didReceiveMessage: msg)
        }

        transports[id] = transport
    }

    /// Removes a transport from the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The identifier of the *Transport* to remove.
    public func remove(transport: String) {
        guard transports[transport] != nil else {
            return
        }

        transports.removeValue(forKey: transport)
    }
    
    /// Sends a message through the current transports.
    ///
    /// - Parameters:
    ///     - message: The message to send.
    public func send(_ message: Message) {
        // @todo this is naive
        transports.forEach { (_, transport) in
            transport.send(message: message)
        }
    }
    
    // @todo create a message send loop with retransmissions and shit
}
