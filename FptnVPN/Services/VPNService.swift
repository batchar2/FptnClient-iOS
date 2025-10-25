/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

import Foundation
import Combine
import NetworkExtension

class VPNService: ObservableObject {
    @Published var connection = VPNConnection()
    private var timer: Timer?
    private var speedTimer: Timer?
    private var websocketClient: WebsocketClientBridge?
    private var packetTunnelProvider: NETunnelProviderManager?
    
    private let tokenService = TokenService.shared
    
    func connect() {
        // Select a server depending on the mode
        let server: VPNServer
        switch connection.connectionMode {
        case .auto:
            let servers = tokenService.getServers()
            server = servers.first ?? servers[0]
        case .manual(let selectedServer):
            server = selectedServer
        }
        
        connection.selectedServer = server
        
        // Get connection data
        guard let tokenData = tokenService.getTokenData() else {
            print("No token data available")
            return
        }
        
        // Perform login and get access token
        loginToServer(server: server, username: tokenData.username, password: tokenData.password) { [weak self] result in
            switch result {
            case .success(let accessToken):
                // Get DNS information
                self?.getDNSInfo(server: server, accessToken: accessToken) { dnsResult in
                    switch dnsResult {
                    case .success(let (dnsIPv4, dnsIPv6)):
                        // Configure and start VPN tunnel
                        self?.configureAndStartVPN(server: server, dnsIPv4: dnsIPv4, dnsIPv6: dnsIPv6) { vpnResult in
                            switch vpnResult {
                            case .success:
                                // Start WebSocket connection
                                self?.startWebSocketConnection(
                                    server: server,
                                    accessToken: accessToken,
                                    dnsIPv4: dnsIPv4,
                                    dnsIPv6: dnsIPv6
                                )
                            case .failure(let error):
                                print("VPN configuration error: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("DNS error: \(error)")
                    }
                }
            case .failure(let error):
                print("Login error: \(error)")
            }
        }
    }
    
    private func loginToServer(server: VPNServer, username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let httpsClient = HttpsClientSwift(
            host: server.host,
            port: server.port,
            sni: server.host,
            md5Fingerprint: server.md5_fingerprint
        )
        
        let requestBody = """
        {
            "username": "\(username)",
            "password": "\(password)"
        }
        """
        
        let response = httpsClient.post(path: "/api/v1/login", body: requestBody, timeout: 10)
        
        guard (response["code"] as? Int32) == 200 else {
            let errorMessage = response["error"] as? String ?? "Unknown error"
            completion(.failure(NSError(domain: "VPNService", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }
        
        guard let body = response["body"] as? String,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String else {
            completion(.failure(NSError(domain: "VPNService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access token not found"])))
            return
        }
        
        print("Login successful: \(accessToken)")
        completion(.success(accessToken))
    }
    
    
    private func getDNSInfo(server: VPNServer, accessToken: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        let httpsClient = HttpsClientSwift(
            host: server.host,
            port: server.port,
            sni: server.host,
            md5Fingerprint: server.md5_fingerprint
        )
        
        let response = httpsClient.get(path: "/api/v1/dns", timeout: 10)
        guard (response["code"] as? Int32) == 200 else {
            let errorMessage = response["error"] as? String ?? "Unknown error"
            completion(.failure(NSError(domain: "VPNService", code: 4, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }
        guard let body = response["body"] as? String,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dnsIPv4 = json["dns"] as? String else {
            completion(.failure(NSError(domain: "VPNService", code: 3, userInfo: [NSLocalizedDescriptionKey: "DNS info not found"])))
            return
        }
        
        let dnsIPv6 = json["dns_ipv6"] as? String ?? "fd00::1"
        print("DNS IPv4: \(dnsIPv4)  IPv6: \(dnsIPv6)")
        completion(.success((dnsIPv4, dnsIPv6)))
    }
    
    private func configureAndStartVPN(server: VPNServer, dnsIPv4: String, dnsIPv6: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self else { return }
            
            let config = NETunnelProviderProtocol()
            config.serverAddress = server.host
#if os(iOS)
            config.providerBundleIdentifier = "org.fptn.FptnVPN.FptnVPNTunnel"
#else
            config.providerBundleIdentifier = "org.fptn.FptnVPN.mac.extension"
#endif
            
            let manager = NETunnelProviderManager()
            manager.protocolConfiguration = config
            manager.localizedDescription = "FPTN"
            manager.saveToPreferences(completionHandler: { (error) -> Void in
                if let error = error {
                    print("Save preferences error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                print("VPN configuration saved successfully")
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                } 
            })
        }
    }
    
//    private func configureAndStartVPN(server: VPNServer, dnsIPv4: String, dnsIPv6: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
//            guard let self = self else { return }
//            
//            print("Start configuring VPN")
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            let tunnelManager = managers?.first ?? NETunnelProviderManager()
//            
//            let protocolConfig = NETunnelProviderProtocol()
//            protocolConfig.providerBundleIdentifier = "org.fptn.FptnVPN.FptnVPNTunnel"
//            
//            protocolConfig.serverAddress = server.host
//            
//            // Provider configuration должен содержать только простые типы
//            protocolConfig.providerConfiguration = [
//                "server": server.host,
//                "port": server.port,
//                "dnsIPv4": dnsIPv4,
//                "dnsIPv6": dnsIPv6,
//                "sni": server.host,
//                "md5Fingerprint": server.md5_fingerprint
//            ] as [String: Any]
//            
//            tunnelManager.protocolConfiguration = protocolConfig
//            tunnelManager.localizedDescription = "Fptn VPN"
//            tunnelManager.isEnabled = true
//            
//            guard let config = tunnelManager.protocolConfiguration as? NETunnelProviderProtocol else {
//                completion(.failure(NSError(domain: "VPNService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Invalid protocol configuration"])))
//                return
//            }
//            
//            tunnelManager.saveToPreferences { error in
//                if let error = error {
//                    print("Save preferences error: \(error)")
//                    completion(.failure(error))
//                    return
//                }
//                
//                print("VPN configuration saved successfully")
//                
//                tunnelManager.loadFromPreferences { error in
//                    if let error = error {
//                        print("Load preferences error: \(error)")
//                        completion(.failure(error))
//                        return
//                    }
//                    
//                    self.packetTunnelProvider = tunnelManager
//                    
//                    do {
//                        try tunnelManager.connection.startVPNTunnel()
//                        print("VPN tunnel started successfully")
//                        completion(.success(()))
//                    } catch {
//                        print("Failed to start VPN tunnel: \(error)")
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//    }
    
    
    
//    private func configureAndStartVPN(server: VPNServer, dnsIPv4: String, dnsIPv6: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
//            guard let self = self else { return }
//            
//            print("Start configuring VPN")
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            let tunnelManager = managers?.first ?? NETunnelProviderManager()
//            
//            // Configure protocol
//            let protocolConfig = NETunnelProviderProtocol()
//            protocolConfig.providerBundleIdentifier = "com.fptn.FptnVPN.FptnVPNTunnel"
//            protocolConfig.serverAddress = server.host
//            protocolConfig.providerConfiguration = [
//                "server": server.host,
//                "port": server.port,
//                "dnsIPv4": dnsIPv4,
//                "dnsIPv6": dnsIPv6,
//                "sni": server.host,
//                "md5Fingerprint": server.md5_fingerprint
//            ]
//            
//            tunnelManager.protocolConfiguration = protocolConfig
//            tunnelManager.localizedDescription = "Fptn VPN"
//            tunnelManager.isEnabled = true
//            
//            // Save configuration
//            tunnelManager.saveToPreferences { error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                // Load configuration again to ensure it's proper
//                tunnelManager.loadFromPreferences { error in
//                    if let error = error {
//                        completion(.failure(error))
//                        return
//                    }
//                    
//                    self.packetTunnelProvider = tunnelManager
//                    
//                    // Start VPN connection
//                    do {
//                        try tunnelManager.connection.startVPNTunnel()
//                        completion(.success(()))
//                    } catch {
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//    }
    
    private func startWebSocketConnection(server: VPNServer, accessToken: String, dnsIPv4: String, dnsIPv6: String) {
        websocketClient = WebsocketClientBridge(
            serverIP: server.host,
            serverPort: server.port,
            tunInterfaceIPv4: "10.8.0.2",
            sni: server.host,
            accessToken: accessToken,
            md5Fingerprint: server.md5_fingerprint,
            packetCallback: { [weak self] packetData in
                self?.handleIncomingPacket(packetData)
            },
            connectedCallback: { [weak self] in
                self?.onWebSocketConnected()
            }
        )
        
        if websocketClient?.start() == true {
            DispatchQueue.main.async {
                self.connection.isConnected = true
                self.startTimer()
                self.startRealSpeedMonitoring()
            }
        }
    }
    
    private func handleIncomingPacket(_ packetData: Data) {
        // Send packet to VPN tunnel
        guard let tunnelConnection = packetTunnelProvider?.connection as? NETunnelProviderSession else {
            return
        }
        
        do {
            try tunnelConnection.sendProviderMessage(packetData) { response in
                // Handle response if needed
            }
        } catch {
            print("Failed to send packet to tunnel: \(error)")
        }
    }
    
    private func onWebSocketConnected() {
        print("WebSocket connection established")
    }
    
    func disconnect() {
        // Stop WebSocket
        websocketClient?.stop()
        websocketClient = nil
        
        // Stop VPN tunnel
        packetTunnelProvider?.connection.stopVPNTunnel()
        packetTunnelProvider = nil
        
        // Update UI state
        DispatchQueue.main.async {
            self.connection.isConnected = false
            self.stopTimer()
            self.stopSpeedMonitoring()
        }
    }
    
    func sendPacket(_ packetData: Data) -> Bool {
        return websocketClient?.sendPacket(packetData) ?? false
    }
    
    private func startRealSpeedMonitoring() {
        speedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, self.connection.isConnected else { return }
            
            // Get actual speed from WebSocket client if available
            // For now, use placeholder
            self.connection.downloadSpeed = Double.random(in: 5...15)
            self.connection.uploadSpeed = Double.random(in: 2...8)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.connection.connectionTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        connection.connectionTime = 0
    }
    
    private func stopSpeedMonitoring() {
        speedTimer?.invalidate()
        speedTimer = nil
        connection.downloadSpeed = 0
        connection.uploadSpeed = 0
    }
    
    func formatConnectionTime() -> String {
        let hours = Int(connection.connectionTime) / 3600
        let minutes = (Int(connection.connectionTime) % 3600) / 60
        let seconds = Int(connection.connectionTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func formatSpeed(_ speed: Double) -> String {
        if speed < 1000 {
            return String(format: "%.1f Kbps", speed)
        } else {
            return String(format: "%.1f Mbps", speed / 1000)
        }
    }
}
