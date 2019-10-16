import Foundation

// @todo clean this up properly, currently very rough for testing purposes.

// @todo set transport addresses, allowing a node to select which transports to send on.

/// Represents the nodes a transport can communicate with.
public class Peer {
    /// The peers identifier.
    public let id: Addr

    /// The services a peer knows.
    public let services: [UBID]

    /// A list of peer addresses for a given transport.
    public var transports = [String: Addr]()

    /// Initializes a peer with a specified id and list of known services.
    ///
    /// - Parameters:
    ///     - id: The peer id.
    ///     - services: The services a peer can knows.
    init(id: Addr, services: [UBID]) {
        self.id = id
        self.services = services
    }
}
