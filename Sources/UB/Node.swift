import Foundation

public class Node {

    private var transports: Dictionary<String, Transport> = Dictionary()
    private var services: Dictionary<UBID, Service> = Dictionary()

    func add(transport: Transport) {
        let id = String(describing: transport)

        if let _ = transports[id] {
            return
        }

        transport.listen { msg in
            guard let service = services[msg.proto] else {
                return
            }

            service.handle(msg)
        }

        transports[id] = transport
    }

    func remove(transport: String) {
        guard let _ = transports[transport] else {
            return
        }

        transports.removeValue(forKey: transport)
    }

    func add(service: Service) {
        if let _ = services[service.type] {
            return
        }

        services[service.type] = service
    }

    func remove(service: UBID) {
        guard let _ = services[service] else {
            return
        }

        services.removeValue(forKey: service)
    }
}
