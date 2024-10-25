//
//  TTeamSearchViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "TTeamDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 搜索可拉入群的好友
@interface TTeamInviteViewController : TCBaseViewController

/// 该属性仅当邀请入群时传入   创建群时无效
@property (copy, nonatomic) NSString *teamId;

/// 初始化创建邀请页面
/// @param title 页面标题
/// @param type 页面类型
- (instancetype)initWithTitle:(NSString *)title type:(TTeamSearchType)type;

@end

NS_ASSUME_NONNULL_END
