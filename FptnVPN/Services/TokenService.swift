import Foundation

class TokenService {
    static let shared = TokenService()
    
    private let tokenKey = "fptnTokenData"
    private let serversKey = "vpnServers"
    private let usernameKey = "vpnUsername"
    private let passwordKey = "vpnPassword"
    private let serviceNameKey = "serviceName"
    
    func saveTokenData(_ tokenData: FPTNToken) {
        // Save all data into UserDefaults
        if let encodedToken = try? JSONEncoder().encode(tokenData) {
            UserDefaults.standard.set(encodedToken, forKey: tokenKey)
        }
        
        if let encodedServers = try? JSONEncoder().encode(tokenData.servers) {
            UserDefaults.standard.set(encodedServers, forKey: serversKey)
        }
        
        UserDefaults.standard.set(tokenData.username, forKey: usernameKey)
        UserDefaults.standard.set(tokenData.password, forKey: passwordKey)
        UserDefaults.standard.set(tokenData.service_name, forKey: serviceNameKey)
    }
    
    func getTokenData() -> FPTNToken? {
        guard let tokenData = UserDefaults.standard.data(forKey: tokenKey),
              let token = try? JSONDecoder().decode(FPTNToken.self, from: tokenData) else {
            return nil
        }
        return token
    }
    
    func getServers() -> [VPNServer] {
        guard let serversData = UserDefaults.standard.data(forKey: serversKey),
              let servers = try? JSONDecoder().decode([VPNServer].self, from: serversData) else {
            return []
        }
        return servers
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.data(forKey: tokenKey) != nil
    }
    
    func clearTokenData() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: serversKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
        UserDefaults.standard.removeObject(forKey: serviceNameKey)
    }
}
