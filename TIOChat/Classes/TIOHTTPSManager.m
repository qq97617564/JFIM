//
//  TIOHTTPSManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOHTTPSManager.h"
#import "TIOHTTPResponse.h"
#import "UIDevice+CBExtension.h"
#import <AdSupport/AdSupport.h>

#import "TIOChat.h"
#import "TIOMacros.h"

#import "TIOTokenStorage.h"
#import "ServerConfig.h"

static CGFloat const kRetryDelay = 0.3;  ///< 重连延时
static NSInteger const kMaxRetryCount = 3; ///< 最大重连次数

@interface TIOHTTPSManager()

@property (strong, nonatomic) AFHTTPResponseSerializer *responseSerializer;
@property (strong, nonatomic) AFHTTPSessionManager  * _Nullable sessionManager;
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *domain;

@end

@implementation TIOHTTPSManager

+ (void)load
{
    [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TIOHTTPSManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
        [_sessionManager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [_sessionManager.requestSerializer setValue:UIDevice.currentDevice.deviceModel forHTTPHeaderField:@"tio-deviceinfo"];
        [_sessionManager.requestSerializer setValue:UIDevice.currentDevice.IMEI forHTTPHeaderField:@"tio-imei"];
        [_sessionManager.requestSerializer setValue:NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] forHTTPHeaderField:@"tio-appversion"];
        [_sessionManager.requestSerializer setValue:@"59" forHTTPHeaderField:@"tio-cid"];
        [_sessionManager.requestSerializer setValue:UIDevice.currentDevice.resolution forHTTPHeaderField:@"tio-resolution"];
        [_sessionManager.requestSerializer setValue:UIDevice.currentDevice.size forHTTPHeaderField:@"tio-size"];
        NSString *operator = UIDevice.currentDevice.mobileOperator;
        operator = [operator stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [_sessionManager.requestSerializer setValue:operator forHTTPHeaderField:@"tio-operator"];
        [_sessionManager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [_sessionManager.requestSerializer setValue:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forHTTPHeaderField:@"tio-idfa"];

        _sessionManager.responseSerializer = [TIOHTTPResponse new];
    }
    return _sessionManager;
}

#pragma mark - 公开

+ (void)registerBaseURL:(NSURL *)URL
{
    TIOHTTPSManager *manager = self.sharedInstance;
    manager.baseURL = URL;
    manager.sessionManager = nil;
    
    if ([URL.absoluteString hasPrefix:@"https://"]) {
        manager.domain = [URL.absoluteString substringFromIndex:8];
    } else if ([URL.absoluteString hasPrefix:@"http://"]) {
        manager.domain = [URL.absoluteString substringFromIndex:7];
    } else {
        manager.domain = URL.absoluteString;
    }
}

+ (void)tio_POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [[self sharedInstance] POST:[path stringByAppendingString:URLString] parameters:parameters success:success failure:failure retryCount:kMaxRetryCount];
}

+ (void)tio_GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [[self sharedInstance] GET:[path stringByAppendingString:URLString] parameters:parameters success:success failure:failure retryCount:kMaxRetryCount];
}

+ (void)tio_POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryCount
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [[self sharedInstance] POST:[path stringByAppendingString:URLString] parameters:parameters success:success failure:failure retryCount:retryCount];
}

+ (void)tio_UPLOAD:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [self.sharedInstance UPLOAD:[path stringByAppendingString:URLString] parameters:parameters constructingBodyWithBlock:block progress:uploadProgress success:success failure:failure retryCount:kMaxRetryCount];
}

#pragma mark - 私有

- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryConut
{
    
//    NSArray *array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.baseURL];
//    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];
//
//    [self.sessionManager.requestSerializer setValue:dict[@"Cookie"]
//                                 forHTTPHeaderField:@"Cookie"];
    TIOLog(@"[cookie] [POST] [request]%@",TIOTokenStorage.shareStorage.cookie);
    [self.sessionManager.requestSerializer setValue:TIOTokenStorage.shareStorage.cookie forHTTPHeaderField:@"Cookie"];
    
    id params = parameters;
    if (TIOChat.shareSDK.allowOnlineOnMultiTerminal) {
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
        p[@"p_is_ios"] = @"1";
        
        params = p;
    }

    [self.sessionManager POST:URLString parameters:params headers:self.sessionManager.requestSerializer.HTTPRequestHeaders progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, task.originalRequest);
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        TIOLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
        !success ?: success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, task.originalRequest);
        TIOLog(@"[Response(%@) error] \n data=>%@",URLString,task.response);
        // 失败重连

        if (retryConut > 0 && ![error.domain isEqualToString:TIOChatErrorDomain]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRetryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *baseUrl = [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
                if ([baseUrl isEqualToString:kBaseURLString]){
                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLStringX forKey:@"baseURL"];
                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLString withString:kBaseURLStringX];
                    baseUrl = url;
                }else{
                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLString forKey:@"baseURL"];
                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLStringX withString:kBaseURLString];
                    baseUrl = url;
                };

                [self POST:baseUrl parameters:parameters success:success failure:failure retryCount:retryConut-1];
            });
        } else {
            !failure ?: failure(task, error);
        }
    }];
}

- (void)GET:(NSString *)URLString parameters:(nullable id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryConut
{
//    NSArray *array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.baseURL];
//    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];
    TIOLog(@"[cookie] [POST] [request]%@",TIOTokenStorage.shareStorage.cookie);
    [self.sessionManager.requestSerializer setValue:TIOTokenStorage.shareStorage.cookie
                                 forHTTPHeaderField:@"Cookie"];
    
    id params = parameters;
    if (TIOChat.shareSDK.allowOnlineOnMultiTerminal) {
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
        p[@"p_is_ios"] = @"1";
        
        params = p;
    }
    
    [self.sessionManager GET:URLString parameters:params headers:self.sessionManager.requestSerializer.HTTPRequestHeaders progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, task.currentRequest.allHTTPHeaderFields);
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        TIOLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
        !success ?: success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 失败重连
        TIOLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, task.originalRequest);
        TIOLog(@"[Response(%@) error] \n data=>%@",URLString,task.response);
        if (retryConut > 0 && ![error.domain isEqualToString:NSBundle.mainBundle.bundleIdentifier]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRetryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *baseUrl = [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
                if ([baseUrl isEqualToString:kBaseURLString]){
                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLStringX forKey:@"baseURL"];
                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLString withString:kBaseURLStringX];
                    baseUrl = url;
                }else{
                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLString forKey:@"baseURL"];
                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLStringX withString:kBaseURLString];
                    baseUrl = url;
                };
                [self GET:baseUrl parameters:parameters success:success failure:failure retryCount:retryConut-1];
            });
        } else {
            !failure ?: failure(task, error);
        }
    }];
}

- (void)UPLOAD:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryConut
{
    id params = parameters;
    if (TIOChat.shareSDK.allowOnlineOnMultiTerminal) {
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
        p[@"p_is_ios"] = @"1";
        
        params = p;
    }
    
    TIOLog(@"[cookie] [POST] [request]%@",TIOTokenStorage.shareStorage.cookie);
    [self.sessionManager.requestSerializer setValue:TIOTokenStorage.shareStorage.cookie
                                 forHTTPHeaderField:@"Cookie"];
    
    [self.sessionManager POST:URLString parameters:params headers:self.sessionManager.requestSerializer.HTTPRequestHeaders constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"[Request(UPLOAD)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, self.sessionManager.requestSerializer.HTTPRequestHeaders);
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        TIOLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
        !success ?: success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"[Request(UPLOAD)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, self.sessionManager.requestSerializer.HTTPRequestHeaders);
        TIOLog(@"[Response(%@) error] \n data=>%@",URLString,task.response);
        // 失败重连
        if (retryConut > 0 && ![error.domain isEqualToString:NSBundle.mainBundle.bundleIdentifier]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRetryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *baseUrl = [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
                if ([baseUrl isEqualToString:kBaseURLString]){
                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLStringX forKey:@"baseURL"];
                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLString withString:kBaseURLStringX];
                    baseUrl = url;
                }else{
                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLString forKey:@"baseURL"];
                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLStringX withString:kBaseURLString];
                    baseUrl = url;
                };
                [self UPLOAD:baseUrl parameters:parameters constructingBodyWithBlock:block progress:uploadProgress success:success failure:failure retryCount:retryConut-1];
            });
        } else {
            !failure ?: failure(task, error);
        }
    }];
}

@end
