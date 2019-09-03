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

    func testSendToSinglePeer() {
        let transport = Transport()
        let node = UB.Node()

        node.add(transport: transport)

        let id = Addr(repeating: 1, count: 3)
        let peer = Peer(id: id, services: [])
        transport.add(peer: peer)

        let message = Message(
            proto: UBID(repeating: 1, count: 1),
            recipient: id,
            from: Addr(repeating: 2, count: 3),
            origin: Addr(repeating: 2, count: 3),
            message: Data(repeating: 0, count: 3)
        )

        node.send(message)

        let sent = transport.sent.first!

        if sent.0 != message {
            XCTFail("sent message did not match")
        }

        if sent.1 != id {
            XCTFail("send target did not match")
        }
    }
}
