import Foundation

public typealias Handler = (Message) -> Void

public protocol Transport {

    func send(message: Message);
    func listen(_ handler: Handler);

}
