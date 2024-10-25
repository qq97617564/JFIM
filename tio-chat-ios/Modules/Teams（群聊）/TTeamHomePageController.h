//
//  TTeamHomePageController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "TIOChat.h"

NS_ASSUME_NONNULL_BEGIN

/// 群主页
@interface TTeamHomePageController : TCBaseViewController

- (instancetype)initWithTeam:(TIOTeam *)team;
@property (copy,    nonatomic) NSString *sessionId; // 会话ID
@property (assign,  nonatomic) NSInteger topflag;//群置顶状态

@end

NS_ASSUME_NONNULL_END
