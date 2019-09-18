import CoreBluetooth

// This class exists because we need a strong reference to the CBL2CAPChannel

class L2CAPStreamClient: StreamClient {

    let channel: CBL2CAPChannel

    init(channel: CBL2CAPChannel) {
        self.channel = channel
        super.init(input: channel.inputStream, output: channel.outputStream)
    }
}
