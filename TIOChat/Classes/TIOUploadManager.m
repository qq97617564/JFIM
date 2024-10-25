//
//  TIOUploadManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOUploadManager.h"
#import "TIOHTTPSManager.h"
#import "TIOMacros.h"
#import "TIOTokenStorage.h"
#import "UIDevice+CBExtension.h"

#import <AdSupport/AdSupport.h>
#import <MobileCoreServices/MobileCoreServices.h>

/// 获取扩展名对应的mimeType
/// @param extension 扩展名
NSString * TIOContentTypeForPathExtension(NSString *extension) {
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
}

@interface TIOUploadManager ()
@property (strong, nonatomic) AFHTTPSessionManager  * _Nullable sessionManager;
@property (strong, nonatomic) AFHTTPRequestSerializer *sessionRequest;
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *domain;
@end

@implementation TIOUploadManager

+ (void)load
{
    [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TIOUploadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
//        _sessionManager.requestSerializer = [AFHTTPRequestSerializer.alloc init];
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
        // multipart/form-data
        [_sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    }
    return _sessionManager;
}

- (AFHTTPRequestSerializer *)sessionRequest
{
    if (!_sessionRequest) {
        _sessionRequest = [AFHTTPRequestSerializer serializer];
        [_sessionRequest setValue:UIDevice.currentDevice.deviceModel forHTTPHeaderField:@"tio-deviceinfo"];
        [_sessionRequest setValue:UIDevice.currentDevice.IMEI forHTTPHeaderField:@"tio-imei"];
        [_sessionRequest setValue:NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] forHTTPHeaderField:@"tio-appversion"];
        [_sessionRequest setValue:@"59" forHTTPHeaderField:@"tio-cid"];
        [_sessionRequest setValue:UIDevice.currentDevice.resolution forHTTPHeaderField:@"tio-resolution"];
        [_sessionRequest setValue:UIDevice.currentDevice.size forHTTPHeaderField:@"tio-size"];
        NSString *operator = UIDevice.currentDevice.mobileOperator;
        operator = [operator stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [_sessionRequest setValue:operator forHTTPHeaderField:@"tio-operator"];
        [_sessionRequest setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [_sessionRequest setValue:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forHTTPHeaderField:@"tio-idfa"];
    }
    return _sessionRequest;
}

#pragma mark - 公开

+ (void)registerBaseURL:(NSURL *)URL
{
    TIOUploadManager *manager = self.sharedInstance;
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

+ (void)uploadFileWithData:(NSData *)data sessionId:(nonnull NSString *)sessionId messageType:(TIOMessageType)messageType fileName:(nonnull NSString *)fileName ext:(nonnull NSString *)ext progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress completion:(nonnull void (^)(NSArray * _Nonnull))completion failure:(nonnull void (^)(NSError * _Nonnull))failure
{
    NSDictionary *params = @{
        @"chatlinkid": sessionId,
    };
    
    NSString *url = nil;
    
    if (messageType == TIOMessageTypeAudio) {
        url = @"/chat/audio";
    } else if (messageType == TIOMessageTypeImage) {
        url = @"/chat/img";
    } else if (messageType == TIOMessageTypeVideo) {
        url = @"/chat/video";
    } else {
        url = @"/chat/file";
    }
    
    __block NSString *fName = fileName;
    
    NSString *path = @"/mytio";
    
    NSString *t_url = [[[self sharedInstance] baseURL].absoluteString stringByAppendingPathComponent:[path stringByAppendingString:url]];
    
    NSMutableURLRequest *request = [[[self sharedInstance] sessionRequest] multipartFormRequestWithMethod:@"POST" URLString:t_url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传的参数(上传图片，以文件流的格式)
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        if (!fName) {
            fName = [NSString  stringWithFormat:@"%@.%@", dateString, ext];
        }
        
        NSString *mimeType = TIOContentTypeForPathExtension(ext);
        TIOLog(@"mimeType = %@",mimeType);
        TIOLog(@"fName = %@",fName);
        
        [formData appendPartWithFileData:data
                                    name:@"uploadFile"
                                fileName:fName
                                mimeType:mimeType];//multipart/form-data
        
    } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:uploadProgress
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"[request] %@", request.allHTTPHeaderFields);
                      if (error) {
                          TIOLog(@"error:\n%@",error);
                          failure(error);
                      } else {
                          if ([responseObject[@"ok"] boolValue]) {
                              TIOLog(@"[Request(UPLOAD)] => \nParams = %@ \nHeaders => %@", params, request.allHTTPHeaderFields);
                              TIOLog(@"[Response ] \n data=>%@",response);
                              completion(responseObject[@"data"]);
                          } else {
                              NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:responseObject[@"msg"]?:@"上传失败"}];
                              TIOLog(@"error:\n%@",error);
                              failure(error);
                          }
                      }
                  }];

    [uploadTask resume];
    
//    [[[self sharedInstance] sessionManager] POST:[path stringByAppendingString:url] parameters:params headers:[[[self sharedInstance] sessionManager] requestSerializer].HTTPRequestHeaders constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        //上传的参数(上传图片，以文件流的格式)
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        // 设置时间格式
//        [formatter setDateFormat:@"yyyyMMddHHmmss"];
//        NSString *dateString = [formatter stringFromDate:[NSDate date]];
//
//        if (!fName) {
//            fName = [NSString  stringWithFormat:@"%@.%@", dateString, ext];
//        }
//
//        NSString *mimeType = TIOContentTypeForPathExtension(ext);
//        TIOLog(@"mimeType = %@",mimeType);
//        TIOLog(@"fName = %@",fName);
//
//        [formData appendPartWithFileData:data
//                                    name:@"uploadFile"
//                                fileName:fName
//                                mimeType:mimeType];//multipart/form-data
//
//    } progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        completion(responseObject[@"data"]);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        TIOLog(@"error:\n%@",error);
//        failure(error);
//    }];
}

+ (void)uploadFileWithFileURL:(NSURL *)fileURL sessionId:(NSString *)sessionId messageType:(TIOMessageType)messageType progress:(void (^)(NSProgress * _Nonnull))uploadProgress completion:(void (^)(NSArray * _Nonnull))completion failure:(void (^)(NSError * _Nonnull))failure
{
    __block NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if (!data) {
        data = [NSData dataWithContentsOfFile:fileURL.absoluteString];
        if (!data) {
            NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey:@"上传文件不合法，是个空文件"}];
            failure(error);
            
            return ;
        }
    }
    
    
    NSDictionary *params = @{
        @"chatlinkid": sessionId,
    };
    
    NSString *url = nil;
    
    if (messageType == TIOMessageTypeAudio) {
        url = @"/chat/audio";
    } else if (messageType == TIOMessageTypeImage) {
        url = @"/chat/img";
    } else if (messageType == TIOMessageTypeVideo) {
        url = @"/chat/video";
    } else {
        url = @"/chat/file";
    }
    
    NSString *path = @"/mytio";
    
    NSString *t_url = [[[self sharedInstance] baseURL].absoluteString stringByAppendingPathComponent:[path stringByAppendingString:url]];
    
    NSMutableURLRequest *request = [[[self sharedInstance] sessionRequest] multipartFormRequestWithMethod:@"POST" URLString:t_url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSString *fileName = fileURL.lastPathComponent;
        NSString *ext = fileURL.pathExtension;
        NSString *mimeType = TIOContentTypeForPathExtension(ext);
        TIOLog(@"mimeType = %@",mimeType);
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:fileName mimeType:mimeType];
        
    } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:uploadProgress
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"[request] %@", request.allHTTPHeaderFields);
                      if (error) {
                          TIOLog(@"error:\n%@",error);
                          failure(error);
                      } else {
                          if ([responseObject[@"ok"] boolValue]) {
                              TIOLog(@"[Request(UPLOAD)] => \nParams = %@ \nHeaders => %@", params, request.allHTTPHeaderFields);
                              TIOLog(@"[Response ] \n data=>%@",response);
                              completion(responseObject[@"data"]);
                          } else {
                              NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:responseObject[@"msg"]?:@"上传失败"}];
                              TIOLog(@"error:\n%@",error);
                              failure(error);
                          }
                      }
                  }];

    [uploadTask resume];
    
//    [[[self sharedInstance] sessionManager] POST:[path stringByAppendingString:url] parameters:params headers:[[[self sharedInstance] sessionManager] requestSerializer].HTTPRequestHeaders constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//
//        NSString *fileName = fileURL.lastPathComponent;
//        NSString *ext = fileURL.pathExtension;
//        NSString *mimeType = TIOContentTypeForPathExtension(ext);
//        TIOLog(@"mimeType = %@",mimeType);
//        [formData appendPartWithFileData:data name:@"uploadFile" fileName:fileName mimeType:mimeType];
//
//    } progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        TIOLog(@"[Request(UPLOAD)] => \nParams = %@ \nHeaders => %@", params, [[self sharedInstance] sessionManager].requestSerializer.HTTPRequestHeaders);
//        TIOLog(@"[Response ] \n data=>%@",task.response);
//        completion(responseObject[@"data"]);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        TIOLog(@"error:\n%@",error);
//        failure(error);
//    }];
    
}

+ (void)upload:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    id params = parameters;
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:parameters];
    p[@"p_is_ios"] = @"1";
    
    params = p;
    
//    TIOLog(@"[request]%@",[[self sharedInstance] sessionManager].requestSerializer.HTTPRequestHeaders);
//    [[[self sharedInstance] sessionManager].requestSerializer setValue:TIOTokenStorage.shareStorage.cookie
//                                 forHTTPHeaderField:@"Cookie"];
    
    NSString *path = @"/mytio";
//    [[[self sharedInstance] sessionManager] POST:[path stringByAppendingString:URLString] parameters:params headers:[[[self sharedInstance] sessionManager] requestSerializer].HTTPRequestHeaders constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        TIOLog(@"[Request(UPLOAD)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, [[self sharedInstance] sessionManager].requestSerializer.HTTPRequestHeaders);
//        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"返回参数格式异常");
//        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//        TIOLog(@"[Response(%@)] \nHeaders => %@ \nData => %@",URLString, response.allHeaderFields, responseObject);
//        !success ?: success(task, responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        TIOLog(@"[Request(UPLOAD)] => \nURL => %@ \nParams = %@ \nHeaders => %@", URLString, params, [[self sharedInstance] sessionManager].requestSerializer.HTTPRequestHeaders);
//        TIOLog(@"[Response(%@) error] \n data=>%@\nerror = %@",URLString,task.response, error);
//        failure(task, error);
//    }];
    
    NSString *url = [[[self sharedInstance] baseURL].absoluteString stringByAppendingPathComponent:[path stringByAppendingString:URLString]];
    
    NSMutableURLRequest *request = [[[self sharedInstance] sessionRequest] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:block error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:uploadProgress
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"[request] %@", request.allHTTPHeaderFields);
                      if (error) {
                          failure(nil, error);
                      } else {
                          if ([responseObject[@"ok"] boolValue]) {
                              success(nil, responseObject);
                          } else {
                              NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:responseObject[@"msg"]?:@"上传失败"}];
                              TIOLog(@"error:\n%@",error);
                              failure(nil, error);
                          }
                      }
                  }];

    [uploadTask resume];
}

@end
