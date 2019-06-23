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

    func testAddService() {
        let service = Service()
        let node = UB.Node()

        node.add(service: service)

        let data = node.services.first!
        XCTAssert(data.key == service.type)
        XCTAssert((data.value as? Service) === service)
    }

    func testRemoveService() {
        let service = Service()
        let node = UB.Node()

        node.add(service: service)

        let data = node.services.first!
        XCTAssert(data.key == service.type)

        node.remove(service: service.type)

        XCTAssert(node.services.values.isEmpty)
    }
}
