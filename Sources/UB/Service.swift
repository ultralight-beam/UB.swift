import Foundation

/// Services are responsible for handling messages received from an Ultralight Beam node.
public protocol Service: NodeDelegate {
    /// The unique service identifier.
    var identifier: UBID { get }
}
