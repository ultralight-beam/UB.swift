import Foundation

extension UUID {
    public var bytes: Data {
        return withUnsafePointer(to: self) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: self))
        }
    }
}
