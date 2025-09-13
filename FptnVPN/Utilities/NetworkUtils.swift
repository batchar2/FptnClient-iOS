/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

import Foundation

class NetworkUtils {
    static func parseJSONResponse(_ response: [String: Any]) -> [String: Any]? {
        guard let body = response["body"] as? String,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    static func extractAccessToken(from json: [String: Any]) -> String? {
        return json["access_token"] as? String
    }
    
    static func extractDNSInfo(from json: [String: Any]) -> (ipv4: String, ipv6: String)? {
        guard let dnsIPv4 = json["dns"] as? String else {
            return nil
        }
        let dnsIPv6 = json["dns_ipv6"] as? String ?? "fd00::1"
        return (dnsIPv4, dnsIPv6)
    }
    
    static func validateServerResponse(_ response: [String: Any]) -> Bool {
        return response["code"] as? Int == 200 && response["body"] != nil
    }
}
