import Foundation

/// Discovery is used to find peers as well as advertise oneself.
protocol Discovery {

    // @todo options or some shit?

    /// Advertises oneself as a peer in the network.
    ///
    /// - Parameters
    ///     - transport: The transport to advertise on.
    func advertise(transport: Transport)

    /// Finds eligible peers in the network.
    ///
    /// - Parameters
    ///     - transport: The transport to find peers on.
    func find(transport: Transport)
}
