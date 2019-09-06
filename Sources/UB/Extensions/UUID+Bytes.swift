import Foundation

extension UUID {

    public var bytes: Data {
        get {
            return withUnsafePointer(to: self) {
                Data(bytes: $0, count: MemoryLayout.size(ofValue: self))
            }
        }
    }

}