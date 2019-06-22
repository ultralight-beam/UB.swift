import Foundation

/// The Handler function is used to handle messages received by the transport.
public typealias Handler = (Message) -> Void

public protocol Transport {

    func send(message: Message);
    func listen(_ handler: Handler);

}
