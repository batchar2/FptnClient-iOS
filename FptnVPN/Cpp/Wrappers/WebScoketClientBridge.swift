/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

import Foundation

public class WebsocketClientBridge {
    public typealias PacketCallback = (Data) -> Void
    public typealias ConnectionCallback = () -> Void
    
    private let nativeBridge: NativeWebsocketClientBridge
    
    public init(serverIP: String,
                serverPort: Int,
                tunInterfaceIPv4: String,
                sni: String,
                accessToken: String,
                md5Fingerprint: String,
                packetCallback: @escaping PacketCallback,
                connectedCallback: @escaping ConnectionCallback) {
        
        self.nativeBridge = NativeWebsocketClientBridge(
            serverIP: serverIP,
            serverPort: serverPort,
            tunInterfaceIPv4: tunInterfaceIPv4,
            sni: sni,
            accessToken: accessToken,
            md5Fingerprint: md5Fingerprint,
            packetCallback: packetCallback,
            connectedCallback: connectedCallback
        )
    }
    
    public func start() -> Bool {
        return nativeBridge.start()
    }
    
    public func stop() -> Bool {
        return nativeBridge.stop()
    }
    
    public func sendPacket(_ data: Data) -> Bool {
        return nativeBridge.sendPacket(data)
    }
    
    public var isStarted: Bool {
        return nativeBridge.isStarted()
    }
}

// Internal Objective-C class that matches your .mm file interface
@objc private class NativeWebsocketClientBridge: NSObject {
    private var handle: WebsocketClientBridgePtr?
    
    @objc init(serverIP: String,
               serverPort: Int,
               tunInterfaceIPv4: String,
               sni: String,
               accessToken: String,
               md5Fingerprint: String,
               packetCallback: @escaping (Data) -> Void,
               connectedCallback: @escaping () -> Void) {
        
        super.init()
        
        let cServerIP = serverIP.cString(using: .utf8)
        let cTunIPv4 = tunInterfaceIPv4.cString(using: .utf8)
        let cSni = sni.cString(using: .utf8)
        let cAccessToken = accessToken.cString(using: .utf8)
        let cMd5Fingerprint = md5Fingerprint.cString(using: .utf8)
        
        // Convert Swift closures to Objective-C compatible blocks
        let packetBlock: @convention(block) (NSData) -> Void = { data in
            packetCallback(data as Data)
        }
        
        let connectedBlock: @convention(block) () -> Void = {
            connectedCallback()
        }
        
        self.handle = websocket_client_bridge_create(
            cServerIP,
            Int32(serverPort),
            cTunIPv4,
            cSni,
            cAccessToken,
            cMd5Fingerprint,
            { (data, length, context) in
                // This will be handled by the C++ wrapper
            },
            { (context) in
                // This will be handled by the C++ wrapper
            },
            Unmanaged.passUnretained(self).toOpaque()
        )
    }
    
    @objc func start() -> Bool {
        guard let handle = handle else { return false }
        return websocket_client_bridge_start(handle)
    }
    
    @objc func stop() -> Bool {
        guard let handle = handle else { return false }
        return websocket_client_bridge_stop(handle)
    }
    
    @objc func sendPacket(_ packetData: Data) -> Bool {
        guard let handle = handle else { return false }
        return packetData.withUnsafeBytes { rawBufferPointer in
            guard let bytes = rawBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return false
            }
            return websocket_client_bridge_send_packet(handle, bytes, UInt32(packetData.count))
        }
    }
    
    @objc func isStarted() -> Bool {
        guard let handle = handle else { return false }
        return websocket_client_bridge_is_started(handle)
    }
    
    deinit {
        if let handle = handle {
            websocket_client_bridge_destroy(handle)
        }
    }
}
