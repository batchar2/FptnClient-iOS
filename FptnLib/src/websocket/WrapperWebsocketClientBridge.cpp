/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

#include <memory>
#include <string>
#include <thread>
#include <atomic>
#include <chrono>
#include <mutex>

#include <fptn-protocol-lib/websocket/websocket_client.h>

#include "WrapperWebsocketClientBridge.h"

#ifndef FPTN_CLIENT_DEFAULT_ADDRESS_IP6
#define FPTN_CLIENT_DEFAULT_ADDRESS_IP6 "fd00::1"
#endif

constexpr const int kMaxReconnectionAttempts = 3;

// Internal C++ websocket client wrapper
struct WebsocketClientWrapper {
    IPPacketCallback packet_callback;
    ConnectionCallback connected_callback;
    void* context;
    std::shared_ptr<fptn::protocol::websocket::WebsocketClient> client;
    std::thread client_thread;
    std::atomic<bool> running{false};
    std::mutex mutex;
    int reconnection_attempts;
    
    // Configuration
    std::string server_ip;
    int server_port;
    std::string tun_ipv4;
    std::string sni;
    std::string access_token;
    std::string md5_fingerprint;
    
    WebsocketClientWrapper(IPPacketCallback p_callback, 
                          ConnectionCallback c_callback,
                          void* ctx)
        : packet_callback(p_callback), connected_callback(c_callback),
          context(ctx), reconnection_attempts(kMaxReconnectionAttempts) {}
};

namespace {
void packet_callback_adapter(fptn::common::network::IPPacketPtr packet, 
                            void* user_data) {
    auto wrapper = static_cast<WebsocketClientWrapper*>(user_data);
    if (wrapper && wrapper->packet_callback && packet) {
        const auto* raw_packet = packet->GetRawPacket();
        const auto* data = static_cast<const uint8_t*>(raw_packet->getRawData());
        const auto len = raw_packet->getRawDataLen();

        wrapper->packet_callback(data, len, wrapper->context);
    }
}

void connected_callback_adapter(void* user_data) {
    auto wrapper = static_cast<WebsocketClientWrapper*>(user_data);
    if (wrapper && wrapper->connected_callback) {
        wrapper->connected_callback(wrapper->context);
    }
}

void client_run_thread(WebsocketClientWrapper* wrapper) {
    // Time window for counting attempts (1 minute)
    constexpr auto kReconnectionWindow = std::chrono::seconds(60);
    // Delay between reconnection attempts
    constexpr auto kReconnectionDelay = std::chrono::milliseconds(300);

    // Current count of reconnection attempts
    wrapper->reconnection_attempts = kMaxReconnectionAttempts;
    auto window_start_time = std::chrono::steady_clock::now();

    while (wrapper->running && wrapper->reconnection_attempts > 0) {
        try {
            {
                std::unique_lock<std::mutex> lock(wrapper->mutex);
                
                if (wrapper->running) {
                    wrapper->client = std::make_shared<fptn::protocol::websocket::WebsocketClient>(
                        fptn::common::network::IPv4Address::Create(wrapper->server_ip),
                        wrapper->server_port,
                        fptn::common::network::IPv4Address::Create(wrapper->tun_ipv4),
                        fptn::common::network::IPv6Address::Create(FPTN_CLIENT_DEFAULT_ADDRESS_IP6),
                        [wrapper](auto packet) {
                            packet_callback_adapter(std::move(packet), wrapper);
                        },
                        wrapper->sni,
                        wrapper->access_token,
                        wrapper->md5_fingerprint,
                        [wrapper]() {
                            connected_callback_adapter(wrapper);
                        });
                }
            }
            
            if (wrapper->running && wrapper->client) {
                wrapper->client->Run();  // This will block until connection fails
            }
        } catch (const std::exception& ex) {
            // Log exception if needed
        } catch (...) {
            // Log unknown exception if needed
        }

        if (!wrapper->running) {
            break;
        }

        // Calculate time since last window start
        auto current_time = std::chrono::steady_clock::now();
        auto elapsed = current_time - window_start_time;

        // Reconnection attempt counting logic
        if (elapsed >= kReconnectionWindow) {
            // Reset counter if we're past the time window
            wrapper->reconnection_attempts = kMaxReconnectionAttempts;
            window_start_time = current_time;
        } else {
            // Decrement counter if within time window
            wrapper->reconnection_attempts--;
        }

        if (wrapper->running && wrapper->reconnection_attempts > 0) {
            std::this_thread::sleep_for(kReconnectionDelay);
        }
    }
}
} // namespace

extern "C" {

WebsocketClientBridgePtr websocket_client_bridge_create(
    const char* server_ip,
    int server_port,
    const char* tun_ipv4,
    const char* sni,
    const char* access_token,
    const char* md5_fingerprint,
    IPPacketCallback packet_callback,
    ConnectionCallback connected_callback,
    void* context) {
    
    try {
        auto wrapper = new WebsocketClientWrapper(packet_callback, connected_callback, context);
        
        wrapper->server_ip = server_ip;
        wrapper->server_port = server_port;
        wrapper->tun_ipv4 = tun_ipv4;
        wrapper->sni = sni;
        wrapper->access_token = access_token;
        wrapper->md5_fingerprint = md5_fingerprint;
        
        return static_cast<WebsocketClientBridgePtr>(wrapper);
    } catch (...) {
        return nullptr;
    }
}

void websocket_client_bridge_destroy(WebsocketClientBridgePtr client) {
    auto wrapper = static_cast<WebsocketClientWrapper*>(client);
    if (wrapper) {
        websocket_client_bridge_stop(client);
        delete wrapper;
    }
}

bool websocket_client_bridge_start(WebsocketClientBridgePtr client) {
    try {
        auto wrapper = static_cast<WebsocketClientWrapper*>(client);
        if (!wrapper->running) {
            wrapper->running = true;
            wrapper->client_thread = std::thread(client_run_thread, wrapper);
            return true;
        }
        return false;
    } catch (...) {
        return false;
    }
}

bool websocket_client_bridge_stop(WebsocketClientBridgePtr client) {
    try {
        auto wrapper = static_cast<WebsocketClientWrapper*>(client);
        if (wrapper->running) {
            wrapper->running = false;
            
            {
                std::unique_lock<std::mutex> lock(wrapper->mutex);
                if (wrapper->client) {
                    wrapper->client->Stop();
                    wrapper->client.reset();
                }
            }
            
            if (wrapper->client_thread.joinable()) {
                wrapper->client_thread.join();
            }
            return true;
        }
        return false;
    } catch (...) {
        return false;
    }
}

bool websocket_client_bridge_send_packet(WebsocketClientBridgePtr client,
                                        const uint8_t* packet_data,
                                        uint32_t length) {
    try {
        auto wrapper = static_cast<WebsocketClientWrapper*>(client);
        if (wrapper && wrapper->client && wrapper->running) {
            auto packet = fptn::common::network::IPPacket::Parse(packet_data, length);
            if (packet) {
                return wrapper->client->Send(std::move(packet));
            }
            return false;
        }
    } catch (...) {
        // Log error if needed
    }
    return false;
}

bool websocket_client_bridge_is_started(WebsocketClientBridgePtr client) {
    try {
        auto wrapper = static_cast<WebsocketClientWrapper*>(client);
        return wrapper && wrapper->client && wrapper->client->IsStarted();
    } catch (...) {
        return false;
    }
}

} // extern "C"
