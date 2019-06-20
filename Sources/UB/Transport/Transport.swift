import Foundation

public typealias Handler = (Message) -> Void

public protocol Transport {

    func send(message: Message);
    func watch(_ handler: Handler);

}
