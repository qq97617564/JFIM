//
//  TCardToRecentSessionViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 将名片分享给最近会话列表的某个会话
/// 将消息转发给最近会话列表的某个会话
@interface TRepostToSessionViewController : TCBaseViewController

/// 1:发送名片 2:转发
@property (assign,  nonatomic) NSInteger type;

@end

NS_ASSUME_NONNULL_END
