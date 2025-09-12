import Foundation

//@_exported import WrapperHttpsClientBridge


class HttpsClientSwift {
    private let client: UnsafeMutableRawPointer?

    init(host: String, port: Int, sni: String, md5Fingerprint: String) {
        client = createHttpsClient(host, Int32(port), sni, md5Fingerprint)
    }

    func get(path: String, timeout: Int) -> [String: Any] {
        guard let client = client else { return ["error": "Invalid handle"] }
        
        let response = httpsClientGet(client, path, Int32(timeout))
        defer { freeHttpResponse(response) }

        var result: [String: Any] = [
            "code": response.code
        ]

        if let body = response.body {
            result["body"] = String(cString: body)
        }

        if let error = response.errmsg {
            result["error"] = String(cString: error)
        }

        return result
    }

    func post(path: String, body: String, timeout: Int) -> [String: Any] {
        guard let client = client else { return ["error": "Invalid handle"] }
        
        let response = httpsClientPost(client, path, body, Int32(timeout))
        defer { freeHttpResponse(response) }

        var result: [String: Any] = [
            "code": response.code
        ]

        if let body = response.body {
            result["body"] = String(cString: body)
        }

        if let error = response.errmsg {
            result["error"] = String(cString: error)
        }

        return result
    }

    deinit {
        if let client = client {
            destroyHttpsClient(client)
        }
    }
}
