import Foundation

/// A node address represented as a byte array.
public typealias Addr = [UInt8] // @todo use yeeth multiaddr

/// Ultralight Beam specific IDs represented as byte arrays.
public typealias UBID = [UInt8] // @todo might be data?

extension Addr {
    func distance(to: Addr) -> Int {
        let value = self ^ to
        return Int(value.reversed().reduce(0) { $0 << 8 + UInt64($1) })
    }

    static func ^ (left: Addr, right: UBID) -> [UInt8] {
        var temp = left

        for i in 0 ..< left.count {
            temp[i] ^= right[i % right.count]
        }

        return temp
    }

    static func < (left: Addr, right: Addr) -> Bool {
        for i in 0 ... left.count {
            if left[i] > right[i] {
                return false
            }
        }

        return true
    }

    static func > (left: Addr, right: Addr) -> Bool {
        for i in 0 ... left.count {
            if left[i] < right[i] {
                return false
            }
        }

        return true
    }
}
