//
//  WalletSendTeamRedPackageVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 发送群红包页
@interface WalletSendTeamRedPackageVC : TCBaseViewController

@property (strong,  nonatomic) TIOTeam *team;
@property (copy,    nonatomic) NSString *sessionId;

@end

NS_ASSUME_NONNULL_END
