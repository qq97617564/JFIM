//
//  Target_Friends.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_Friends : NSObject

/// 跳转UserHomePageViewController
/// @param params chatBlock : 回调 user：TIOUser对象 type页面类型
- (UIViewController *)Action_UserHomePageViewController:(NSDictionary *)params;
/// 获取好友私聊会话的设置页
/// @param params uid:好友的uid  sessionId:会话ID
- (UIViewController *)Action_SessionSettingViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
