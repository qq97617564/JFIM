//
//  WalletManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WalletDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 外部业务中，直接使用该类
@interface WalletManager : NSObject

@property (copy,    nonatomic) NSString *sessionId;

+ (instancetype)shareInstance;

/// 必须指定是何种支付 易支付还是新生支付
@property (nonatomic,   assign) WalletVendor vendor;

/// 点击红包消息
- (void)openRedPackage:(NSDictionary *)params callback:(void(^)(id data))callback;

/// 调起开户页面，
/// 如果已开户，直接进入钱包主页
- (void)evokeOpenAccount:(NSDictionary *)params callback:(void(^)(id data))callback;

/// 调起私发红包页面
/// @param params currentVC:当前VC user：要传入的用户信息 |群信息  sessionId：会话ID
- (void)evokeSendRedViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
