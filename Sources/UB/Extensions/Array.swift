import Foundation

extension Array where Element == Addr {
    func closest(to: Addr) -> Addr? {
        return self.min { a, b in
            a.distance(to: to) < b.distance(to: to)
        }
    }
}
