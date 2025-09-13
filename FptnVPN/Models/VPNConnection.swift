import Foundation

struct VPNConnection {
    var isConnected: Bool = false
    var selectedServer: VPNServer?
    var connectionTime: TimeInterval = 0
    var downloadSpeed: Double = 0
    var uploadSpeed: Double = 0
    var connectionMode: ConnectionMode = .auto
    
    enum ConnectionMode {
        case auto
        case manual(VPNServer)
    }
}
