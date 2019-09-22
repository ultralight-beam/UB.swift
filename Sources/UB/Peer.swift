import Foundation

// @todo clean this up properly, currently very rough for testing purposes.

/// Represents the nodes a transport can communicate with.
public class Peer {
    /// The peers id.
    public let id: Addr

    /// The services a peer knows.
    public let services: [UBID]

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
