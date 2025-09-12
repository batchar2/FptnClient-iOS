#ifndef HttpsClientBridge_h
#define HttpsClientBridge_h

#ifdef __cplusplus
extern "C" {
#endif

// Opaque pointer to hide C++ implementation
typedef void* HttpsClientHandle;

// Response structure for C interface
typedef struct {
    char* body;
    int code;
    char* errmsg;
} CHttpResponse;

// Create and destroy
HttpsClientHandle createHttpsClient(const char* host, int port, const char* sni, const char* md5_fingerprint);
void destroyHttpsClient(HttpsClientHandle handle);

// Methods
CHttpResponse httpsClientGet(HttpsClientHandle handle, const char* handle_str, int timeout);
CHttpResponse httpsClientPost(HttpsClientHandle handle, const char* handle_str, const char* request, int timeout);

// Memory management
void freeHttpResponse(CHttpResponse response);

#ifdef __cplusplus
}
#endif

#endif /* HttpsClientBridge_h */
