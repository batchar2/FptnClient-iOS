///*=============================================================================
//Copyright (c) 2024-2025 Stas Skokov
//
//Distributed under the MIT License (https://opensource.org/licenses/MIT)
//=============================================================================*/

import Foundation

struct VPNServer: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let host: String
    let md5_fingerprint: String
    let port: Int
    
    static func == (lhs: VPNServer, rhs: VPNServer) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
