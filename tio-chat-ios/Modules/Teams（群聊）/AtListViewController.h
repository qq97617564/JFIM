//
//  AtListViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// @的群成员列表
@interface AtListViewController : TCBaseViewController

- (instancetype)initWithTeamUser:(TIOTeamMember *)teamUser;

@end

NS_ASSUME_NONNULL_END
