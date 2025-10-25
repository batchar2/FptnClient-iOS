//
//  AppProxyProvider.swift
//  FptnVPNTunnel
//
//  Created by Stas Skokov on 13/9/2025.
//

import NetworkExtension

class AppProxyProvider: NEAppProxyProvider {

    override func startProxy(options: [String : Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        print("+ startProxy +")
        // Add code here to start the process of connecting the tunnel.
    }
    
    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        print("+ stopProxy +")
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        print("+ handleAppMessage +")
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping() -> Void) {
        // Add code here to get ready to sleep.
        print("+ sleep +")
        completionHandler()
    }
    
    override func wake() {
        print("+ wake +")
        // Add code here to wake up.
    }
    
    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        print("+ handleNewFlow +")
        // Add code here to handle the incoming flow.
        return false
    }
}
