//
//  NSString+tio.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (tio)

+ (BOOL)isEmpty:(NSString *) str;

/// 资源服务器
- (NSString *)tio_resourceURLString;

/// web服务器
- (NSString *)tio_HTML5URLString;

/// 月-日
- (NSString *)tio_getMMdd;
/// 分：秒
- (NSString *)tio_getHHmm;

+ (NSString *)tio_getTimeWithFormat:(NSString *)format timeInterval:(NSTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END
