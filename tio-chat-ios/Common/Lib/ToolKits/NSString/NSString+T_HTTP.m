//
//  NSString+T_HTTP.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "NSString+T_HTTP.h"
#import "ServerConfig.h"
#import "TIOConfig.h"
#import "TIOChat.h"
@implementation NSString (T_HTTP)


- (NSString *)resourceURLString
{
    if (self) {
        if (![self hasPrefix:@"http"] && self.length!= 0) {
            NSString *url = [TIOChat.shareSDK.config.resourceAddress stringByAppendingString:self?:@""];
            // 处理URL中的中文编码
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            return url;
        } else {
            return self;
        }
    } else {
        return nil;
    }
}

- (NSString *)HTML5URLString
{
    if (![self hasPrefix:@"http"]) {
        return [kHTMLBaseURLString stringByAppendingString:self?:@""];
    } else {
        return self;
    }
}

@end
