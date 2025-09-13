import Foundation
import Combine

class VPNService: ObservableObject {
    @Published var connection = VPNConnection()
    private var timer: Timer?
    
    private let tokenService = TokenService.shared
    
    func connect() {
        // Select a server depending on the mode
        let server: VPNServer
        switch connection.connectionMode {
        case .auto:
            // Automatic selection of the best server (simple logic here)
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
        
        // Here will be the call to native code for VPN connection
        // Example using HttpsClientSwift (placeholder)
        /*
        let client = HttpsClientSwift(
            host: server.host,
            port: Int32(server.port),
            sni: server.host,
            md5Fingerprint: server.md5_fingerprint
        )
        
        // Perform connection
        let success = client.connect(
            username: tokenData.username,
            password: tokenData.password
        )
        */
        
        // Placeholder — assume successful connection
        let success = true
        
        if success {
            connection.isConnected = true
            startTimer()
            // Start speed monitoring
            startSpeedMonitoring()
        }
    }
    
    func disconnect() {
        // Here will be the call to native code for VPN disconnection
        connection.isConnected = false
        stopTimer()
        stopSpeedMonitoring()
    }
    
    
    /*
     func connect() {
         let manager = NEVPNManager.shared()
         
         manager.loadFromPreferences { error in
             if let error = error {
                 print("Error loading VPN preferences: \(error)")
                 return
             }
             
             let protocolConfig = NETunnelProviderProtocol()
             protocolConfig.providerBundleIdentifier = "com.stas.FptnVPN.FptnVPNTunnel"
             protocolConfig.serverAddress = "vpn.example.com" // фиктивный адрес для отображения
             protocolConfig.username = self.tokenService.getTokenData()?.username
             
             manager.protocolConfiguration = protocolConfig
             manager.localizedDescription = "Fptn VPN"
             manager.isEnabled = true
             
             manager.saveToPreferences { error in
                 if let error = error {
                     print("Error saving VPN preferences: \(error)")
                     return
                 }
                 do {
                     try manager.connection.startVPNTunnel()
                     DispatchQueue.main.async {
                         self.connection.isConnected = true
                     }
                 } catch {
                     print("Failed to start VPN Tunnel: \(error)")
                 }
             }
         }
     }
     
     func disconnect() {
         let manager = NEVPNManager.shared()
         manager.connection.stopVPNTunnel()
         DispatchQueue.main.async {
             self.connection.isConnected = false
         }
     }
     
     */
    
    
    
    
    
    
    
    
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
    
    private func startSpeedMonitoring() {
        // Here will be the implementation of speed monitoring
        // For now, use a placeholder with random values
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self, self.connection.isConnected else { return }
            self.connection.downloadSpeed = Double.random(in: 1...10)
            self.connection.uploadSpeed = Double.random(in: 1...5)
        }
    }
    
    private func stopSpeedMonitoring() {
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
            return String(format: "%.2f Kbps", speed)
        } else {
            return String(format: "%.2f Mbps", speed / 1000)
        }
    }
}
