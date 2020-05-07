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

    func testChildIsAddedWhenSubscribing() {
        let node = UB.Node()
        let transport = Transport()

        let addr = Addr(repeating: 2, count: 3)
        let topic = UBID(repeating: 3, count: 3)

        let packet = Packet.new(topic: Data(topic), type: .subscribe, body: Data(count: 0))

        let data = try! packet.serializedData()
        node.transport(transport, didReceiveData: data, from: addr)
        XCTAssertTrue(node.children[topic]!.contains(addr))
    }

    func testChildIsRemovedOnUnsubscribe() {
        let node = UB.Node()
        let transport = Transport()

        let addr = Addr(repeating: 2, count: 3)
        let topic = UBID(repeating: 3, count: 3)

        let subscribe = Packet.new(topic: Data(topic), type: .subscribe, body: Data(count: 0))

        let subscription = try! subscribe.serializedData()
        node.transport(transport, didReceiveData: subscription, from: addr)
        XCTAssertTrue(node.children[topic]!.contains(addr))

        let unsubscribe = Packet.new(topic: Data(topic), type: .unsubscribe, body: Data(count: 0))

        let data = try! unsubscribe.serializedData()
        node.transport(transport, didReceiveData: data, from: addr)
        XCTAssertFalse(node.children[topic]!.contains(addr))
    }

    func testMessageIsSentToChildren() {
        let node = UB.Node()
        let transport = Transport()
        node.add(transport: transport)

        let addr = Addr(repeating: 2, count: 3)
        let topic = UBID(repeating: 3, count: 3)

        transport.peers.append(addr)

        let subscribe = Packet.new(topic: Data(topic), type: .subscribe, body: Data(count: 0))

        let subscription = try! subscribe.serializedData()
        node.transport(transport, didReceiveData: subscription, from: addr)

        node.send(topic: topic, data: Data(repeating: 3, count: 1))

        guard let sent = transport.sent.first else {
            return XCTFail("no messages sent")
        }

        XCTAssert(sent.1 == addr)
    }
}
