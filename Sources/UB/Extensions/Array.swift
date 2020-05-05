import Foundation

extension Array where Element == Addr {

    func closest(to: Addr) -> Addr? {

        var distance = 0;
        var addr: Addr?

        for peer in self {
            let dist = peer.distance(to: to)
            if distance > dist {
                distance = dist
                addr = peer
            }
        }

        return addr
    }
}
