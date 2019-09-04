import Foundation

// @todo clean this up properly, currently very rough for testing purposes.

public class Peer {
    public let id: Addr
    public let services: [UBID]

    init(id: Addr, services: [UBID]) {
        self.id = id
        self.services = services
    }
}
