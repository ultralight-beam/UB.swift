import Foundation

extension Packet {
    static func new(topic: Data, type: TypeEnum, body: Data) -> Packet {
        return Packet.with {
            $0.topic = topic
            $0.type = type
            $0.body = body
        }
    }
}
