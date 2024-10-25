//
//  TIOUploadManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

#if __has_include(<AFNetworking/AFNetworking-umbrella.h>)
#import <AFNetworking/AFNetworking-umbrella.h>
#else
#import "AFNetworking-umbrella.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 上传
@interface TIOUploadManager : NSObject

+ (instancetype)sharedInstance;

+ (void)registerBaseURL:(NSURL *)URL;

/// 以NSData上传
/// @param data 文件的NSData数据
/// @param sessionId 会话ID
/// @param messageType  消息类型
/// @param ext 扩展名（png,jpg,mp3,mp4,pdf...）
/// @param uploadProgress 上传进度
/// @param completion 成功毁掉
/// @param failure 失败回调
+ (void)uploadFileWithData:(NSData *)data
                 sessionId:(NSString *)sessionId
               messageType:(TIOMessageType)messageType
                  fileName:(NSString *)fileName
                       ext:(NSString *)ext
                  progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                completion:(void (^)(NSArray *urls))completion
                   failure:(void (^)(NSError * error))failure;

/// 以URL上传文件
/// @param fileURL 沙盒中的文件路径
/// @param sessionId 会话ID
/// @param uploadProgress 进度
/// @param completion 成功
/// @param failure 失败
+ (void)uploadFileWithFileURL:(NSURL *)fileURL
                    sessionId:(NSString *)sessionId
                  messageType:(TIOMessageType)messageType
                     progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                   completion:(void (^)(NSArray *urls))completion
                      failure:(void (^)(NSError * error))failure;

+ (void)upload:(NSString *)URLString
    parameters:(nullable id)parameters
constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
      progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
