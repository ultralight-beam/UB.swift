import Foundation

public protocol Service {

    var type: UBID { get }

    func handle(_ message: Message)

}
