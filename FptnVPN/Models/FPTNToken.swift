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
