//
//  TIOHTTPResponse.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/6.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOHTTPResponse.h"
#import "TIOMacros.h"
#import "TIOTokenStorage.h"

@implementation TIOHTTPResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.removesKeysWithNullValues = YES;
        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
    }
    return self;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error
{
    BOOL valid = [super validateResponse:response data:data error:error];
    if (!valid) {
        return valid;
    }
    
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![responseObject[@"ok"] boolValue]) {
        [TIOTokenStorage.shareStorage checkToken:nil];
            // 是否是全局code
            if ([responseObject.allKeys containsObject:@"code"]) {
                
                NSNumber *code = responseObject[@"code"];
                NSString *errorMsg = responseObject[@"msg"]?:[self msgForCode:code.integerValue];
                
                /// 是否需要登录
                NSArray *needLoginCodes = @[@(1001),@(1002),@(1003)];
                if ([needLoginCodes containsObject:code]) {
                    [NSNotificationCenter.defaultCenter postNotificationName:@"kOnKickNotification" object:@"kOnKickNotification" userInfo:@{@"code":code, @"msg":errorMsg}];
                }
                
                if ([self msgForCode:code.integerValue]) {
                    *error = [NSError errorWithDomain:TIOChatErrorDomain
                                                 code:code.integerValue
                                             userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                    return NO;
                }
            }
            // 非全局错误，是否包含msg
            if ([responseObject.allKeys containsObject:@"msg"]) {
                *error = [NSError errorWithDomain:TIOChatErrorDomain
                                             code:1000
                                         userInfo:@{NSLocalizedDescriptionKey: responseObject[@"msg"]}];
                return NO;
            }
            
            *error = [NSError errorWithDomain:TIOChatErrorDomain
                                         code:1000
                                     userInfo:@{NSLocalizedDescriptionKey: @"服务端未知异常"}];
            return NO;
        
    } else {
        [TIOTokenStorage.shareStorage checkToken:response.URL.absoluteString];
    }
    return valid;
}

- (NSString *)msgForCode:(NSInteger)code
{
    if (code == 1001) return @"没有登录";
    if (code == 1002) return @"登录超时";
    if (code == 1003) return @"在其它地方登录";
    if (code == 1004) return @"登录了，但是没权限";
    if (code == 1005) return @"访问过快";
    if (code == 1006) return @"需要提供正确的access_token";
    if (code == 1007) return @"图形验证异常";
    if (code == 20001) return @"数据库记录重复";
    return nil;
}

@end
