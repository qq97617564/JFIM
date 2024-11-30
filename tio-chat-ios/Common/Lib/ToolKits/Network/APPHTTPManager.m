//
//  THTTPManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "APPHTTPManager.h"
#import "TDeviceInfo.h"
#import <AdSupport/AdSupport.h>
#import "ImportSDK.h"
#import "APPResponse.h"
#import <Foundation/Foundation.h>
#import "ServerConfig.h"


@interface APPHTTPManager()
@property (strong, nonatomic) AFHTTPResponseSerializer *responseSerializer;
@property (strong, nonatomic) AFHTTPSessionManager  * _Nullable sessionManager;
@property (strong, nonatomic) NSURL *baseURL;
@end

@implementation APPHTTPManager

+ (void)load
{
    [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static APPHTTPManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
#if DEBUG
//        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
        _sessionManager = [[AFHTTPSessionManager alloc]init];
#else
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
#endif
//        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = 15;
        _sessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
        [_sessionManager.requestSerializer setValue:@"application/json; charset=UTF-8"
                                 forHTTPHeaderField:@"Content-Type"];
        [_sessionManager.requestSerializer setValue:TDeviceInfo.deviceModel
                                 forHTTPHeaderField:@"tio-deviceinfo"];
        [_sessionManager.requestSerializer setValue:TDeviceInfo.IMEI
                                 forHTTPHeaderField:@"tio-imei"];
        [_sessionManager.requestSerializer setValue:NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]
                                 forHTTPHeaderField:@"tio-appversion"];
        [_sessionManager.requestSerializer setValue:@"59"
                                 forHTTPHeaderField:@"tio-cid"];
        [_sessionManager.requestSerializer setValue:TDeviceInfo.resolution
                                 forHTTPHeaderField:@"tio-resolution"];
        [_sessionManager.requestSerializer setValue:TDeviceInfo.size
                                 forHTTPHeaderField:@"tio-size"];
        
        NSString *operator = TDeviceInfo.mobileOperator;
        operator = [operator stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        [_sessionManager.requestSerializer setValue:operator
                                 forHTTPHeaderField:@"tio-operator"];
        [_sessionManager.requestSerializer setValue:@"gzip"
                                 forHTTPHeaderField:@"Content-Encoding"];
        [_sessionManager.requestSerializer setValue:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]
                                 forHTTPHeaderField:@"tio-idfa"];
        
        _sessionManager.responseSerializer = [APPResponse new];
    }
    return _sessionManager;
}

+ (void)t_POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{

    
    NSString *path = @"/mytio";

    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [[self sharedInstance] POST:[path stringByAppendingString:URLString] parameters:parameters success:success failure:failure retryCount:3];
}

+ (void)t_POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryCount
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        [baseUrl stringByAppendingString:path];
    };
    [[self sharedInstance] POST:[path stringByAppendingString:URLString] parameters:parameters success:success failure:failure retryCount:retryCount];
}

+ (void)t_GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryCount
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [[self sharedInstance] GET:[path stringByAppendingString:URLString] parameters:parameters success:success failure:failure retryCount:retryCount];
}

#pragma mark - 私有

- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryConut
{
    // @"https://www.tiocloud.com"
    // @"https://tx.t-io.org"
//    NSArray *array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://www.tiocloud.com"]];
//    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];

    NSLog(@"[cookie] APP内 = %@",TIOTokenStorage.shareStorage.cookie);
    [self.sessionManager.requestSerializer setValue:TIOTokenStorage.shareStorage.cookie forHTTPHeaderField:@"Cookie"];
    
    id params = parameters;
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
    p[@"p_is_ios"] = @"1";
    
    params = p;
    
    [self.sessionManager POST:URLString parameters:params headers:self.sessionManager.requestSerializer.HTTPRequestHeaders progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, task.currentRequest.allHTTPHeaderFields);
        
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
        !success ?: success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, parameters, task.originalRequest);
        NSLog(@"[Response(%@) error] \n data=>%@",URLString,task.response);
        // 失败重连
        if (retryConut > 0 && ![error.domain isEqualToString:NSBundle.mainBundle.bundleIdentifier]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString *baseUrl = [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
                NSInteger index = [NSUserDefaults.standardUserDefaults integerForKey:@"baseURLIndex"];
                if (index < kBaseURLArr.count-1) {
                    index ++ ;
                }else{
                    index = 0;
                }
                NSString *changeUrl = kBaseURLArr[index];
                [NSUserDefaults.standardUserDefaults setObject:changeUrl forKey:@"baseURL"];
                [NSUserDefaults.standardUserDefaults setInteger:index forKey:@"baseURLIndex"];
                NSString *url = [URLString stringByReplacingOccurrencesOfString:baseUrl withString:changeUrl];//请求域名替换为副域名
                baseUrl = url;
                [TIOChat.shareSDK requestBaseConfig];
                [self POST:baseUrl parameters:parameters success:success failure:failure retryCount:retryConut-1];
            });
        } else {
            !failure ?: failure(task, error);
        }
    }];
}

- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryConut
{
//    NSArray *array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://www.tiocloud.com"]];
//    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];

//    [self.sessionManager.requestSerializer setValue:dict[@"Cookie"] forHTTPHeaderField:@"Cookie"];
    
    NSLog(@"[cookie] APP内  = %@",TIOTokenStorage.shareStorage.cookie);
    [self.sessionManager.requestSerializer setValue:TIOTokenStorage.shareStorage.cookie forHTTPHeaderField:@"Cookie"];
    
    id params = parameters;
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
    p[@"p_is_ios"] = @"1";
    
    params = p;
    
    
    
    [self.sessionManager GET:URLString parameters:params headers:self.sessionManager.requestSerializer.HTTPRequestHeaders  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"[Request(GET)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, task.currentRequest.allHTTPHeaderFields);
        
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
        !success ?: success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"[Request(GET)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, parameters, task.originalRequest);
        NSLog(@"[Response(%@) error] \n data=>%@",URLString,task.response);
        // 失败重连
        if (retryConut > 0 && ![error.domain isEqualToString:NSBundle.mainBundle.bundleIdentifier]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString *baseUrl = [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
                NSInteger index = [NSUserDefaults.standardUserDefaults integerForKey:@"baseURLIndex"];
                if (index < kBaseURLArr.count-1) {
                    index ++ ;
                }else{
                    index = 0;
                }
                NSString *changeUrl = kBaseURLArr[index];
                [NSUserDefaults.standardUserDefaults setObject:changeUrl forKey:@"baseURL"];
                [NSUserDefaults.standardUserDefaults setInteger:index forKey:@"baseURLIndex"];
                NSString *url = [URLString stringByReplacingOccurrencesOfString:baseUrl withString:changeUrl];//请求域名替换为副域名
                baseUrl = url;
                [TIOChat.shareSDK requestBaseConfig];
//                NSString *baseUrl = [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
//                if ([baseUrl isEqualToString:kBaseURLString]){
//                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLStringX forKey:@"baseURL"];
//                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLString withString:kBaseURLStringX];
//                    baseUrl = url;
//                }else{
//                    [NSUserDefaults.standardUserDefaults setObject:kBaseURLString forKey:@"baseURL"];
//                    NSString *url = [URLString stringByReplacingOccurrencesOfString:kBaseURLStringX withString:kBaseURLString];
//                    baseUrl = url;
//                };

                [self POST:baseUrl parameters:parameters success:success failure:failure retryCount:retryConut-1];
            });
        } else {
            !failure ?: failure(task, error);
        }
    }];
}

+ (void)t_UPLOAD:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    NSString *path = @"/mytio";
    if (![URLString containsString:@"http"]) {
        NSString *baseUrl =     [NSUserDefaults.standardUserDefaults objectForKey:@"baseURL"];
        path = [baseUrl stringByAppendingString:path];
    };
    [self.sharedInstance UPLOAD:[path stringByAppendingString:URLString] parameters:parameters constructingBodyWithBlock:block progress:uploadProgress success:success failure:failure retryCount:9999];
}

- (void)UPLOAD:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure retryCount:(NSInteger)retryConut
{
    id params = parameters;
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
    p[@"p_is_ios"] = @"1";
    
    params = p;
    
    [self.sessionManager POST:URLString parameters:params headers:self.sessionManager.requestSerializer.HTTPRequestHeaders  constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, parameters, task.currentRequest.allHTTPHeaderFields);
        
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
        !success ?: success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"[Request(POST)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, parameters, task.originalRequest);
        NSLog(@"[Response(%@) error] \n data=>%@",URLString,task.response);
        !failure ?: failure(task, error);
    }];
}


@end
