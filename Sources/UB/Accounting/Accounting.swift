import Foundation

/// The accounting protocol handles bandwidth accounting for peers.
public protocol Accounting {
    /// Adds a sent message to the accounting for a specific peer.
    ///
    /// - Parameters:
    ///     - message: The message to account for.
    func account(sentMessage message: Message);

    /// Adds a received message to the accounting for a specific peer.
    ///
    /// - Parameters:
    ///     - message: The message to account for.
    func account(receivedMessage message: Message);

    /// Returns how many messages were sent for a given peer.
    ///
    /// - Parameters:
    ///     - sentMessagesForPeer: The peer id to check.
    ///
    /// - Returns: The amount of messages accounted for.
    func accounted(sentMessagesForPeer peer: Peer) -> UInt;

    /// Returns how many messages were received from a given peer.
    ///
    /// - Parameters:
    ///     - receivedMessagesForPeer: The peer id to check.
    ///
    /// - Returns: The amount of messages accounted for.
    func accounted(receivedMessagesForPeer peer: Peer) -> UInt;
}
