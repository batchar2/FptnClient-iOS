import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var connection: NWConnection?
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "10.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"],
                                               subnetMasks: ["255.255.255.0"])
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        
        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                completionHandler(error)
                return
            }
            
            // Подключение к твоему серверу
            //let serverHost = NWEndpoint.Host("vpn.example.com")
//            let serverPort = NWEndpoint.Port("443")!
//            self.connection = NWConnection(host: serverHost, port: serverPort, using: .tcp)
//            
//            self.connection?.stateUpdateHandler = { state in
//                switch state {
//                case .ready:
//                    self.readPackets()
//                    completionHandler(nil)
//                case .failed(let err):
//                    completionHandler(err)
//                default:
//                    break
//                }
//            }
//            self.connection?.start(queue: .global())
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        connection?.cancel()
        completionHandler()
    }
    
    private func readPackets() {
        packetFlow.readPackets { packets, _ in
            for packet in packets {
                self.connection?.send(content: packet, completion: .contentProcessed { _ in })
            }
            self.readPackets()
        }
    }
}
