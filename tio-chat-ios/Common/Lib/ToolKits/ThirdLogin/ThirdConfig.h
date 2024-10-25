//
//  ThirdPlatform.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ThirdPlatform) {
    ThirdPlatformQQ    =   11, ///< QQ
    ThirdPlatformWX    =   22, ///< 微信
    ThirdPlatformWB    =   33  ///< 微博
};

typedef NS_ENUM(NSUInteger, ThirdShareType) {
    ThirdShareTypeQQSession =   0,  //QQ聊天页
    ThirdShareTypeWXSession =   1,  //微信聊天页
    ThirdShareTypeWXTimeLine=   2   //微信朋友圈
};

typedef NS_ENUM(NSUInteger, ThirdLoginError) {
    ThirdLoginNone  =   1000,   ///< 登录成功
    ThirdLoginFail  =   1001,   ///< 登录失败
    ThirdLoginCancel=   1002,   ///< 登录取消
    ThirdLoginNoNet =   1003,   ///< 没有网络
    ThirdLoginNoInstallQQ = 1004,   ///< 没有安装QQ客户端
    ThirdLoginNoInstallWX = 1005,   ///< 没有安装微信客户端
    ThirdLoginOther =   1006,   ///< 其他错误
};

@interface ThirdConfig : NSObject
@property (assign,  nonatomic) ThirdPlatform type;
@property (copy,    nonatomic) NSString *appId;
@property (copy,    nonatomic) NSString *appSecertKey;
@property (copy,    nonatomic) NSString *UniversalLink;
@end

NS_ASSUME_NONNULL_END
