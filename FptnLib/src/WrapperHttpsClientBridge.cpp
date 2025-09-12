#include <string>

#include <cstring>

#include "WrapperHttpsClientBridge.h"

#include "https/https_client.h"


extern "C" {

HttpsClientHandle createHttpsClient(const char* host, int port, const char* sni, const char* md5_fingerprint) {
    try {
        auto client = new fptn::protocol::https::HttpsClient(
            std::string(host),
            port,
            std::string(sni),
            std::string(md5_fingerprint)
        );
        return static_cast<HttpsClientHandle>(client);
    } catch (const std::exception& e) {
        // Log error if needed
        return nullptr;
    } catch (...) {
        return nullptr;
    }
}

void destroyHttpsClient(HttpsClientHandle handle) {
    if (handle) {
        auto client = static_cast<fptn::protocol::https::HttpsClient*>(handle);
        delete client;
    }
}

CHttpResponse httpsClientGet(HttpsClientHandle handle, const char* handle_str, int timeout) {
    CHttpResponse response = {nullptr, 0, nullptr};
    if (!handle) {
        response.errmsg = strdup("Invalid handle");
        return response;
    }
    try {
        auto client = static_cast<fptn::protocol::https::HttpsClient*>(handle);
        const auto cpp_response = client->Get(handle_str, timeout);
        
        response.code = cpp_response.code;
        
        if (!cpp_response.body.empty()) {
            response.body = strdup(cpp_response.body.c_str());
        }
        if (!cpp_response.errmsg.empty()) {
            response.errmsg = strdup(cpp_response.errmsg.c_str());
        }
    } catch (const std::exception& e) {
        response.errmsg = strdup(e.what());
    } catch (...) {
        response.errmsg = strdup("Unknown error occurred");
    }
    return response;
}

CHttpResponse httpsClientPost(HttpsClientHandle handle, const char* handle_str, const char* request, int timeout) {
    CHttpResponse response = {nullptr, 0, nullptr};
    if (!handle) {
        response.errmsg = strdup("Invalid handle");
        return response;
    }
    try {
        auto client = static_cast<fptn::protocol::https::HttpsClient*>(handle);
        const auto cpp_response = client->Post(handle_str, request, "application/json", timeout);
        response.code = cpp_response.code;
        if (!cpp_response.body.empty()) {
            response.body = strdup(cpp_response.body.c_str());
        }
        if (!cpp_response.errmsg.empty()) {
            response.errmsg = strdup(cpp_response.errmsg.c_str());
        }
    } catch (const std::exception& e) {
        response.errmsg = strdup(e.what());
    } catch (...) {
        response.errmsg = strdup("Unknown error occurred");
    }
    return response;
}

void freeHttpResponse(CHttpResponse response) {
    if (response.body) {
        free(response.body);
    }
    if (response.errmsg) {
        free(response.errmsg);
    }
}

} // extern "C"
