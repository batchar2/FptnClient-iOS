//
// HttpsClientBridge.mm
//

#import <Foundation/Foundation.h>

//#import "WrapperHttpsClientBridge.h"
#import <fptn_native_lib/WrapperHttpsClientBridge.h>


@interface HttpsClientSwift : NSObject

@property (nonatomic, assign) HttpsClientHandle handle;

- (instancetype)initWithHost:(NSString *)host
                         port:(NSInteger)port
                          sni:(NSString *)sni
                md5Fingerprint:(NSString *)md5Fingerprint;

- (void)destroy;

- (NSDictionary *)getWithPath:(NSString *)path
                      timeout:(NSInteger)timeout;

- (NSDictionary *)postWithPath:(NSString *)path
                         body:(NSString *)body
                      timeout:(NSInteger)timeout;

@end

@implementation HttpsClientSwift

- (instancetype)initWithHost:(NSString *)host
                         port:(NSInteger)port
                          sni:(NSString *)sni
                md5Fingerprint:(NSString *)md5Fingerprint {
    self = [super init];
    if (self) {
        const char *cHost = [host UTF8String];
        const char *cSni = [sni UTF8String];
        const char *cFingerprint = [md5Fingerprint UTF8String];
        
        self.handle = createHttpsClient(cHost, (int)port, cSni, cFingerprint);
    }
    return self;
}

- (void)destroy {
    if (self.handle) {
        destroyHttpsClient(self.handle);
        self.handle = NULL;
    }
}

- (NSDictionary *)getWithPath:(NSString *)path timeout:(NSInteger)timeout {
    const char *cPath = [path UTF8String];
    
    CHttpResponse response = httpsClientGet(self.handle, cPath, (int)timeout);
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[@"code"] = @(response.code);
    
    if (response.body) {
        NSString *bodyStr = [NSString stringWithUTF8String:response.body];
        result[@"body"] = bodyStr;
    }
    
    if (response.errmsg) {
        NSString *errMsg = [NSString stringWithUTF8String:response.errmsg];
        result[@"error"] = errMsg;
    }
    
    freeHttpResponse(response);
    
    return [result copy];
}

- (NSDictionary *)postWithPath:(NSString *)path
                         body:(NSString *)body
                      timeout:(NSInteger)timeout {
    const char *cPath = [path UTF8String];
    const char *cBody = [body UTF8String];

    CHttpResponse response = httpsClientPost(self.handle, cPath, cBody, (int)timeout);
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[@"code"] = @(response.code);
    
    if (response.body) {
        NSString *bodyStr = [NSString stringWithUTF8String:response.body];
        result[@"body"] = bodyStr;
    }
    
    if (response.errmsg) {
        NSString *errMsg = [NSString stringWithUTF8String:response.errmsg];
        result[@"error"] = errMsg;
    }
    
    freeHttpResponse(response);
    
    return [result copy];
}

@end
