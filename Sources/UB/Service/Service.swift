import Foundation

public protocol Service {

    var type: UBID { get }

    /// Handle implements service specific handling for messages.
    ///
    /// - Parameters
    ///     - message: The message to handle.
    func handle(_ message: Message)

}
