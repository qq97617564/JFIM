//
//  TShareTeamCardListViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^NetworkResult)(BOOL re);

@interface TShareTeamCardListViewController : TCBaseViewController

@property (copy,    nonatomic) void(^shareCallback)(NetworkResult netre);

@end

NS_ASSUME_NONNULL_END
