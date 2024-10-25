//
//  TTeamMembersViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 群成员列表页
@interface TTeamMembersViewController : TCBaseViewController

- (instancetype)initWithTeamUser:(TIOTeamMember *)teamUser;

/// 是否是删除成员按钮进入
@property (assign, nonatomic) BOOL isRemoveMember;

/// 仅仅查看全部成员
@property (assign, nonatomic) BOOL isOnlySee;

/// 是否禁止加其他人
@property (assign, nonatomic) BOOL isForbiddenAddOther;

@end

NS_ASSUME_NONNULL_END
