import Foundation

/// The StreamClient implements generic stream handling for Ultralight Beam transports.
public class StreamClient: NSObject {
    // @TODO: We need to figure out how the dependants figure out which address or peer data came from.

    /// The delegate for the StreamClient.
    weak var delegate: StreamClientDelegate?

    private let input: InputStream
    private let output: OutputStream

    /// Initializes a StreamClient with the input and output streams.
    ///
    /// - Parameters:
    ///     - input: The input stream.
    ///     - output: The output stream.
    public init(input: InputStream, output: OutputStream) {
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
    public func stream(_: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            read()
        default:
            return
        }
    }

    fileprivate func read() {
        let length = read(4).withUnsafeBytes {
            $0.load(as: UInt32.self)
        }

        delegate?.client(self, didReceiveData: read(Int(length.bigEndian)))
    }

    private func read(_ length: Int) -> Data {
        if length == 0 {
            return Data()
        }

        var buffer = [UInt8](repeating: 0, count: length)
        input.read(&buffer, maxLength: length)
        return Data(buffer)
    }
}
