//
//  NWSendTeamRedPackageVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/11.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWSendTeamRedPackageVC : TCBaseViewController
@property (strong,  nonatomic) TIOTeam *team;
@property (copy,    nonatomic) NSString *sessionId;
@end

NS_ASSUME_NONNULL_END
