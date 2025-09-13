/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

#import <Foundation/Foundation.h>
#import <fptn_native_lib/WrapperWebsocketClientBridge.h>

@interface WebsocketClientBridge : NSObject

@property (nonatomic, assign) WebsocketClientBridgePtr handle;

- (instancetype)initWithServerIP:(NSString *)serverIP
                      serverPort:(int)serverPort
                tunInterfaceIPv4:(NSString *)tunIPv4
                            sni:(NSString *)sni
                    accessToken:(NSString *)accessToken
                 md5Fingerprint:(NSString *)md5Fingerprint
                  packetCallback:(void(^)(NSData *))packetCallback
              connectedCallback:(void(^)(void))connectedCallback;

- (BOOL)start;
- (BOOL)stop;
- (BOOL)sendPacket:(NSData *)packetData;
- (BOOL)isStarted;

@end

@implementation WebsocketClientBridge {
    void(^_packetCallback)(NSData *);
    void(^_connectedCallback)(void);
}

// Helper functions to convert blocks to C callbacks
static void packetCallbackWrapper(const uint8_t* data, uint32_t length, void* context) {
    WebsocketClientBridge* self = (__bridge WebsocketClientBridge*)context;
    if (self->_packetCallback) {
        NSData* packetData = [NSData dataWithBytes:data length:length];
        self->_packetCallback(packetData);
    }
}

static void connectedCallbackWrapper(void* context) {
    WebsocketClientBridge* self = (__bridge WebsocketClientBridge*)context;
    if (self->_connectedCallback) {
        self->_connectedCallback();
    }
}

- (instancetype)initWithServerIP:(NSString *)serverIP
                      serverPort:(int)serverPort
                tunInterfaceIPv4:(NSString *)tunIPv4
                            sni:(NSString *)sni
                    accessToken:(NSString *)accessToken
                 md5Fingerprint:(NSString *)md5Fingerprint
                  packetCallback:(void(^)(NSData *))packetCallback
              connectedCallback:(void(^)(void))connectedCallback {
    self = [super init];
    if (self) {
        _packetCallback = [packetCallback copy];
        _connectedCallback = [connectedCallback copy];
        
        const char *cServerIP = [serverIP UTF8String];
        const char *cTunIPv4 = [tunIPv4 UTF8String];
        const char *cSni = [sni UTF8String];
        const char *cAccessToken = [accessToken UTF8String];
        const char *cMd5Fingerprint = [md5Fingerprint UTF8String];
        
        self.handle = websocket_client_bridge_create(
            cServerIP,
            serverPort,
            cTunIPv4,
            cSni,
            cAccessToken,
            cMd5Fingerprint,
            packetCallbackWrapper,
            connectedCallbackWrapper,
            (__bridge void*)self
        );
    }
    return self;
}

- (BOOL)start {
    return self.handle ? websocket_client_bridge_start(self.handle) : NO;
}

- (BOOL)stop {
    return self.handle ? websocket_client_bridge_stop(self.handle) : NO;
}

- (BOOL)sendPacket:(NSData *)packetData {
    return self.handle ? websocket_client_bridge_send_packet(self.handle,
                                                           (const uint8_t*)packetData.bytes,
                                                           (uint32_t)packetData.length) : NO;
}

- (BOOL)isStarted {
    return self.handle ? websocket_client_bridge_is_started(self.handle) : NO;
}

- (void)dealloc {
    if (self.handle) {
        websocket_client_bridge_destroy(self.handle);
        self.handle = NULL;
    }
}

@end
