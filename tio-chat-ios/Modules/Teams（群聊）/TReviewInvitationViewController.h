//
//  TInviteReviewViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 成员邀请审核页
@interface TReviewInvitationViewController : TCBaseViewController

/// 申请好友加入群的ID
@property (strong,    nonatomic) NSNumber *applyId;
@property (strong,    nonatomic) TIOMessage *message;
@property (copy,    nonatomic) void(^onClick)(TIOMessage *msg);

@end

NS_ASSUME_NONNULL_END
