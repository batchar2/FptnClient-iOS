/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

import Foundation

struct FPTNToken: Codable {
    let version: Int
    let service_name: String
    let username: String
    let password: String
    let servers: [VPNServer]
}

//struct VPNServer: Codable, Identifiable {
//    var id: String { name }
//    let name: String
//    let host: String
//    let md5_fingerprint: String
//    let port: Int
//}
