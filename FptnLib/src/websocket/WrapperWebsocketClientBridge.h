/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

#ifndef WRAPPER_WEBSOCKET_CLIENT_BRIDGE_H
#define WRAPPER_WEBSOCKET_CLIENT_BRIDGE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque pointer to C++ WebsocketClient instance
typedef void* WebsocketClientBridgePtr;

// Callback types
typedef void (*IPPacketCallback)(const uint8_t* packet_data, uint32_t length, void* context);
typedef void (*ConnectionCallback)(void* context);

// Creates new websocket client instance
WebsocketClientBridgePtr websocket_client_bridge_create(
    const char* server_ip,
    int server_port,
    const char* tun_ipv4,
    const char* sni,
    const char* access_token,
    const char* md5_fingerprint,
    IPPacketCallback packet_callback,
    ConnectionCallback connected_callback,
    void* context);

// Destroys websocket client instance
void websocket_client_bridge_destroy(WebsocketClientBridgePtr client);

// Starts websocket client connection
bool websocket_client_bridge_start(WebsocketClientBridgePtr client);

// Stops websocket client connection
bool websocket_client_bridge_stop(WebsocketClientBridgePtr client);

// Sends IP packet through websocket
bool websocket_client_bridge_send_packet(WebsocketClientBridgePtr client,
                                        const uint8_t* packet_data,
                                        uint32_t length);

// Checks if websocket client is started
bool websocket_client_bridge_is_started(WebsocketClientBridgePtr client);

#ifdef __cplusplus
}
#endif

#endif // WRAPPER_WEBSOCKET_CLIENT_BRIDGE_H
