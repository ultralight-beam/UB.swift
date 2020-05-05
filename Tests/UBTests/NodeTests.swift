@testable import UB
import XCTest

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

    func testUnsubscribeWorks() {
        let node = UB.Node()

        let topic = UBID(repeating: 1, count: 10)
        node.subscribe(topic)

        XCTAssertTrue(node.topics.contains(topic))

        node.unsubscribe(topic)
        XCTAssertFalse(node.topics.contains(topic))
    }
}
