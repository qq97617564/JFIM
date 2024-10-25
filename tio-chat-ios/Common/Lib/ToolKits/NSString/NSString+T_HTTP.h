//
//  NSString+T_HTTP.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (T_HTTP)

/// 资源服务器
- (NSString *)resourceURLString;

/// web服务器
- (NSString *)HTML5URLString;

@end

NS_ASSUME_NONNULL_END
