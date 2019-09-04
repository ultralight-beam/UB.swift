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
        transport.peers.append(peer)

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

    func testDoesNotSendWhenNoPeerOrServiceInMessage() {
        let transport = Transport()
        let node = UB.Node()

        node.add(transport: transport)

        let peer = Peer(id: Addr(repeating: 1, count: 3), services: [])
        transport.peers.append(peer)

        let message = Message(
            proto: UBID(repeating: 0, count: 0),
            recipient: Addr(repeating: 1, count: 0),
            from: Addr(repeating: 2, count: 3),
            origin: Addr(repeating: 2, count: 3),
            message: Data(repeating: 0, count: 3)
        )

        node.send(message)

        XCTAssertEqual(0, transport.sent.count)
    }

    func testSendsToAllPeersExceptOriginWhenExactMatchNotFound() {
        let transport = Transport()
        let node = UB.Node()

        node.add(transport: transport)

        transport.peers.append(Peer(id: Addr(repeating: 2, count: 3), services: []))
        transport.peers.append(Peer(id: Addr(repeating: 3, count: 3), services: []))
        transport.peers.append(Peer(id: Addr(repeating: 4, count: 3), services: []))
        transport.peers.append(Peer(id: Addr(repeating: 5, count: 3), services: []))

        let message = Message(
            proto: UBID(repeating: 1, count: 1),
            recipient: Addr(repeating: 1, count: 3),
            from: Addr(repeating: 4, count: 3),
            origin: Addr(repeating: 3, count: 3),
            message: Data(repeating: 0, count: 3)
        )

        node.send(message)

        XCTAssertEqual(2, transport.sent.count)
    }

    func testSendsToAllPeersWithSameServiceId() {
        let transport = Transport()
        let node = UB.Node()

        node.add(transport: transport)

        let id = UBID(repeating: 3, count: 2)

        transport.peers.append(Peer(id: Addr(repeating: 2, count: 3), services: [id]))
        transport.peers.append(Peer(id: Addr(repeating: 3, count: 3), services: [id]))
        transport.peers.append(Peer(id: Addr(repeating: 4, count: 3), services: [id]))
        transport.peers.append(Peer(id: Addr(repeating: 5, count: 3), services: []))

        let message = Message(
            proto: id,
            recipient: Addr(repeating: 1, count: 3),
            from: Addr(repeating: 4, count: 3),
            origin: Addr(repeating: 3, count: 3),
            message: Data(repeating: 0, count: 3)
        )

        node.send(message)

        XCTAssertEqual(2, transport.sent.count)
        XCTAssertEqual(transport.sent[0].1, transport.peers[0].id)
        XCTAssertEqual(transport.sent[1].1, transport.peers[1].id)
    }
}
