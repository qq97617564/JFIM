//
//  TeamManageViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 群管理页
@interface TeamManageViewController : TCBaseViewController
@property (strong,  nonatomic) TIOTeam *team;
@end

NS_ASSUME_NONNULL_END
