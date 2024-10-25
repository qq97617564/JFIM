//
//  TFriendSettingViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/27.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 私聊会话设置页
@interface TP2PSessionSettingViewController : TCBaseViewController

/// 用户ID
@property (copy,    nonatomic) NSString *uid;
/// 会话ID
@property (copy,    nonatomic) NSString *sessionId;

@end

NS_ASSUME_NONNULL_END
