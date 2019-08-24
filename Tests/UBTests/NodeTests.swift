import XCTest
@testable import UB

final class NodeTests: XCTestCase {

    func testAddTransport() {
        let transport = Transport()
        let node = UB.Node()

        node.add(transport: transport)

        let data = node.transports.first!
        XCTAssert(data.key == String(describing: transport))
        XCTAssert((data.value as? Transport) === transport)
    }

    func testRemoveTransport() {
        let transport = Transport()
        let node = UB.Node()

        node.add(transport: transport)

        let data = node.transports.first!
        XCTAssert(data.key == String(describing: transport))

        node.remove(transport: String(describing: transport))

        XCTAssert(node.transports.values.isEmpty)
    }
}
