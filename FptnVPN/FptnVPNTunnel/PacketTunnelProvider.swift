///*=============================================================================
//Copyright (c) 2024-2025 Stas Skokov
//
//Distributed under the MIT License (https://opensource.org/licenses/MIT)
//=============================================================================*/
//
//import NetworkExtension
//import os
//
//class PacketTunnelProvider: NEPacketTunnelProvider {
//    private var websocketClient: WebsocketClientBridge?
//    private let logger = Logger(subsystem: "org.fptn.FptnVPN", category: "PacketTunnel")
//    
//    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
//        logger.info("Starting VPN tunnel")
//        
//        guard let protocolConfig = self.protocolConfiguration as? NETunnelProviderProtocol,
//              let providerConfig = protocolConfig.providerConfiguration else {
//            completionHandler(NSError(domain: "PacketTunnel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid configuration"]))
//            return
//        }
//        
//        guard let server = providerConfig["server"] as? String,
//              let port = providerConfig["port"] as? Int,
//              let dnsIPv4 = providerConfig["dnsIPv4"] as? String,
//              let dnsIPv6 = providerConfig["dnsIPv6"] as? String,
//              let sni = providerConfig["sni"] as? String,
//              let md5Fingerprint = providerConfig["md5Fingerprint"] as? String else {
//            completionHandler(NSError(domain: "PacketTunnel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing configuration parameters"]))
//            return
//        }
//        
//        // Configure tunnel settings
//        let tunnelNetworkSettings = createTunnelNetworkSettings(dnsIPv4: dnsIPv4, dnsIPv6: dnsIPv6)
//        self.setTunnelNetworkSettings(tunnelNetworkSettings) { error in
//            if let error = error {
//                completionHandler(error)
//                return
//            }
//            
//            // Start WebSocket connection
//            self.startWebSocketConnection(
//                server: server,
//                port: port,
//                sni: sni,
//                md5Fingerprint: md5Fingerprint,
//                completionHandler: completionHandler
//            )
//        }
//    }
//    
//    private func createTunnelNetworkSettings(dnsIPv4: String, dnsIPv6: String) -> NEPacketTunnelNetworkSettings {
//        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
//        
//        // IPv4 settings
//        let ipv4Settings = NEIPv4Settings(addresses: ["10.8.0.2"], subnetMasks: ["255.255.255.0"])
//        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
//        settings.ipv4Settings = ipv4Settings
//        
//        // IPv6 settings
//        let ipv6Settings = NEIPv6Settings(addresses: ["fd00::2"], networkPrefixLengths: [64])
//        ipv6Settings.includedRoutes = [NEIPv6Route.default()]
//        settings.ipv6Settings = ipv6Settings
//        
//        // DNS settings
//        settings.dnsSettings = NEDNSSettings(servers: [dnsIPv4, dnsIPv6])
//        
//        return settings
//    }
//    
//    private func startWebSocketConnection(server: String, port: Int, sni: String, md5Fingerprint: String, completionHandler: @escaping (Error?) -> Void) {
//        // In tunnel environment, we need to handle packets differently
//        // This is a simplified implementation
//        
//        websocketClient = WebsocketClientBridge(
//            serverIP: server,
//            serverPort: port,
//            tunInterfaceIPv4: "10.8.0.2",
//            sni: sni,
//            accessToken: "tunnel-token", // Will be provided by main app
//            md5Fingerprint: md5Fingerprint,
//            packetCallback: { [weak self] packetData in
//                self?.handleIncomingPacket(packetData)
//            },
//            connectedCallback: { [weak self] in
//                self?.logger.info("WebSocket connected in tunnel")
//                completionHandler(nil)
//            }
//        )
//        
//        if websocketClient?.start() != true {
//            completionHandler(NSError(domain: "PacketTunnel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to start WebSocket"]))
//        }
//    }
//    
//    private func handleIncomingPacket(_ packetData: Data) {
//        // Write packet to tunnel
//        self.packetFlow.writePackets([packetData], withProtocols: [AF_INET as NSNumber])
//    }
//    
//    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
//        logger.info("Stopping VPN tunnel")
//        websocketClient?.stop()
//        websocketClient = nil
//        completionHandler()
//    }
//    
//    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
//        // Handle messages from main app
//        if let message = String(data: messageData, encoding: .utf8) {
//            logger.info("Received app message: \(message)")
//            
//            if message == "get_status" {
//                let status = "connected"
//                completionHandler?(status.data(using: .utf8))
//            }
//        }
//    }
//    
//    override func sleep(completionHandler: @escaping () -> Void) {
//        completionHandler()
//    }
//    
//    override func wake() {
//    }
//}
