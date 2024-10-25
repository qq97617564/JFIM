//
//  UIColor+TDTheme.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TDTheme)

+ (UIColor *)colorWithHex:(UInt32)hex;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

/// TabBar默认状态颜色
+ (UIColor *)TDTheme_TabBarNormalColor;

/// TabBar选中状态颜色
+ (UIColor *)TDTheme_TabBarSelectedColor;

/// 未读消息的颜色
+ (UIColor *)TDTheme_UnreadColor;

/// 模块标题颜色
+ (UIColor *)TDTheme_ModuleTitleColor;

/// 会话列表的昵称颜色
+ (UIColor *)TDTheme_SessionNickColor;

/// 会话列表的消息颜色
+ (UIColor *)TDTheme_SessionMessageColor;

@end

NS_ASSUME_NONNULL_END
