//
//  TIOHTTPSManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<AFNetworking/AFNetworking-umbrella.h>)
#import <AFNetworking/AFNetworking-umbrella.h>
#else
#import "AFNetworking-umbrella.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TIOHTTPSManager : NSObject

+ (instancetype)sharedInstance;

+ (void)registerBaseURL:(NSURL *)URL;


/// 以下两个方法为post请求
/// 第一个方法有retryCount 可以指定重连次数
/// 第二个方法没有retryCount参数 默认重连3次
+ (void)tio_POST:(NSString *)URLString
      parameters:(nullable id)parameters
         success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
      retryCount:(NSInteger)retryCount;

+ (void)tio_POST:(NSString *)URLString
      parameters:(nullable id)parameters
         success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

+ (void)tio_GET:(NSString *)URLString
     parameters:(nullable id)parameters
        success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

+ (void)tio_UPLOAD:(NSString *)URLString
        parameters:(nullable id)parameters
constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
          progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
           success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
