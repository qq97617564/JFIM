//
//  TIOTokenStorage.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOTokenStorage : NSObject

+ (instancetype)shareStorage;

/// 调用TIOChat网络配置后，cookieName会自动动态填充
@property (copy,    nonatomic) NSString *cookieName;

/// 用于长链接 cookie的value
@property (copy,    nonatomic) NSString *token;

@property (copy,    nonatomic) NSString *oldToken;

/// 每次请求时，使用cookie key=value 的形式
@property (copy,  nonatomic) NSString *cookie;

/// 登录状态 1:已登录 2:未登录
@property (assign,  nonatomic) NSInteger loginStatus;

/// 检查token 
- (void)checkToken:(NSString * _Nullable)urlString;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
