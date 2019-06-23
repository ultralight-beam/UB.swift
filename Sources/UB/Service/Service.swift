import Foundation

/// Services are used to implement specific handling for messages.
/// Each service does one specific thing and handles all incoming messages for that service.
public protocol Service {

    /// The service identifier, these are used to route messages to specific services.
    var type: UBID { get }

    /// Handle implements service specific handling for messages.
    ///
    /// - Parameters
    ///     - message: The message to handle.
    func handle(_ message: Message)

}
