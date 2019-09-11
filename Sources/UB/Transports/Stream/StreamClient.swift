import Foundation

/// The StreamClient implements generic stream handling for Ultralight Beam transports.
public class StreamClient: NSObject {
    
    // @TODO: We need to figure out how the dependants figure out which address or peer data came from.
    
    private let input: InputStream
    private let output: OutputStream
    
    /// The delegate for the StreamClient.
    weak var delegate: StreamClientDelegate?
    
    /// Initializes a StreamClient with the peer address and the input and output streams.
    ///
    /// - Parameters:
    ///     - input: The input stream.
    ///     - output: The output stream.
    public init(peer: Addr, input: InputStream, output: OutputStream) {
        self.input = input
        self.output = output
        
        super.init()
        
        self.input.delegate = self
        self.output.delegate = self
    }
    
    /// Writes the contents of provided data to the receiver.
    ///
    /// - Parameters:
    ///     - data: Data to write
    public func write(_ data: Data) {
        let bytes = NSMutableData()
        
        var length = UInt32(data.count).bigEndian
        bytes.append(&length, length: 4)
        
        bytes.append(data)
        
        output.write([UInt8](bytes), maxLength: bytes.count)
    }
}

/// :nodoc:
extension StreamClient: StreamDelegate {
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
    }

    fileprivate func read() {
        
    }
}
