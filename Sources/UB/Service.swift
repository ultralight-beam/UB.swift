import Foundation

public protocol Service: NodeDelegate {
    /// The unique service identifier.
    var identifier: UBID { get }
}
