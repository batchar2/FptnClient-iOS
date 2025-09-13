import Foundation

class ServerSelectionService {
    static let shared = ServerSelectionService()
    
    private let tokenService = TokenService.shared
    
    func getBestServer() -> VPNServer? {
        let servers = tokenService.getServers()
        // Simple logic for selecting the "best" server — the first in the list
        // In a real application, this could be an algorithm that checks ping, etc.
        return servers.first
    }
    
    func getAllServers() -> [VPNServer] {
        return tokenService.getServers()
    }
}
