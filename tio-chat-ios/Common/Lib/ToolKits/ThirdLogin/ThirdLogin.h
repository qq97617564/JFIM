//
//  ThirdLogin.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdResponse.h"
#import "ThirdConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThirdLogin : NSObject

+ (instancetype)shareInstance;

- (BOOL)handleOpenURL:(NSURL *)url;
/// 微信登录时必调
/// @param userActivity 系统传过来的
- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;

- (void)setConfig:(ThirdConfig *)config forPaltform:(ThirdPlatform)platform;

- (void)loginWithPlatform:(ThirdPlatform)platform currentVC:(UIViewController *)currentVC completion:(void(^)(ThirdResponse * _Nullable result , NSError * _Nullable error))completion;

#pragma mark - 分享

/// 纯文本分享(逻辑未实现)
- (void)shareText:(NSString *)text toPlatform:(ThirdPlatform)platform shareType:(ThirdShareType)shareType completion:(void(^)(id result, NSError * _Nullable error))completion;

/// 图片分享
- (void)shareImage:(UIImage *)image toPlatform:(ThirdPlatform)platform shareType:(ThirdShareType)shareType completion:(void(^)(id result, NSError * _Nullable error))completion;

/// 新闻分享/网页分享(逻辑未实现)
/// @param pageUrl 网页地址
/// @param title 标题
/// @param description 描述
/// @param thumbImage 缩略图 可以是UIImage 也可以是url
- (void)shareWebPageURL:(NSString *)pageUrl title:(NSString *)title description:(NSString *)description thumbImage:(id)thumbImage toPlatform:(ThirdPlatform)platform shareType:(ThirdShareType)shareType completion:(void(^)(id result, NSError * _Nullable error))completion;


- (BOOL)canOpenQQ;
- (BOOL)canOpenWX;

@end

NS_ASSUME_NONNULL_END
