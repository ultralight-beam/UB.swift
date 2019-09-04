import Foundation

// @todo clean this up properly, currently very rough for testing purposes.

/// Represents a peer for a specific transport.
public class Peer {
    /// The peers `id`.
    public let id: Addr

    /// The services a peer knows.
    public let services: [UBID]

    /// The init function for a peer.
    ///
    /// - Parameters
    ///     - id: The peers `id`
    ///     - services: The services a peer can knows.
    init(id: Addr, services: [UBID]) {
        self.id = id
        self.services = services
    }
}
