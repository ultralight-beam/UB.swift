import Foundation
import UB

let UBBT = CoreBluetoothTransport()
//var msgs: [Message] = []
//
//for i in UInt8(0)...6 {
//    let message = Message(
//        proto: UBID(repeating: 1, count: 1),
//        recipient: Addr(repeating: 4, count: 4),
//        from: Addr(repeating: 2, count: 3),
//        origin: Addr(repeating: 2, count: 3),
//        message: Data(repeating: i, count: 3)
//    )
//    UBBT.send(message: message, to: message.recipient)
//    sleep()
//}

//let iphoneUUID = UUID(uuidString: "71150DB7-F394-44C6-B161-FD116855E05D")


let iphoneUUID = "0BCD7956-7E10-4562-B5AF-D25F5D8D86AF".utf8

let message = Message(
    proto: UBID(repeating: 1, count: 1),
    recipient: Addr(repeating: 4, count: 4),
    from: Addr(repeating: 2, count: 3),
    origin: Addr(repeating: 2, count: 3),
    message: Data(repeating: 7, count: 3)
)
//
//let data = withUnsafePointer(to: iphoneUUID!.uuid) {
//    Data(bytes: $0, count: MemoryLayout.size(ofValue: iphoneUUID!.uuid))
//}


if #available(OSX 10.12, *) {
    let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) {_ in
        UBBT.send(message: message, to: Addr(iphoneUUID))
    }
} else {
    // Fallback on earlier versions
}


RunLoop.current.run()
