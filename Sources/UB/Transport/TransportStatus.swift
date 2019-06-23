import Foundation

/// Indicates the operating status of a transport.
public enum TransportStatus {

    /// The transport has not started listening for messages.
    case off

    /// The transport is listening for messages.
    case listening
}
