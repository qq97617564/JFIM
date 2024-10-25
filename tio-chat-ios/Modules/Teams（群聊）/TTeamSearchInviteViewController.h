//
//  TTeamSearchInviteViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "TTeamDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTeamSearchInviteViewControllerDelegate <NSObject>

- (void)didSelectedUser:(NSString *)uid;

@end

/// 群聊搜索邀请好友
@interface TTeamSearchInviteViewController : TCBaseViewController

/// 该属性仅当邀请入群时传入   创建群时无效
@property (copy, nonatomic) NSString *teamId;

- (instancetype)initWithTitle:(NSString *)title type:(TTeamSearchType)type;

@property (assign, nonatomic) id<TTeamSearchInviteViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
