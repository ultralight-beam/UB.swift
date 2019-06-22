import Foundation

/// An ultralight beam node, handles the interaction with transports and services.
public class Node {

    /// The known transports for the node.
    private(set) public var transports: Dictionary<String, Transport> = Dictionary()

    /// The known services for a node.
    private(set) public var services: Dictionary<UBID, Service> = Dictionary()

    /// Adds a new transport to the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The new *Transport* to add.
    public func add(transport: Transport) {
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

    /// Removes a transport from the list of known transports.
    ///
    /// - Parameters:
    ///     - transport: The identifier of the *Transport* to remove.
    public func remove(transport: String) {
        guard let _ = transports[transport] else {
            return
        }

        transports.removeValue(forKey: transport)
    }

    /// Adds a new service to the list of known services.
    ///
    /// - Parameters:
    ///     - service: The new *Service* to add.
    public func add(service: Service) {
        if let _ = services[service.type] {
            return
        }

        services[service.type] = service
    }

    /// Removes a service from the list of known services.
    ///
    /// - Parameters:
    ///     - service: The *UBID* of the service to remove.
    public func remove(service: UBID) {
        guard let _ = services[service] else {
            return
        }

        services.removeValue(forKey: service)
    }
}
