//
//  TTeamInviteModel.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTeamDefines.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTeamInviteModel : NSObject

/// 用户信息
@property (strong, nonatomic) TIOUser *user;

/// 选中状态
@property (assign, nonatomic) TCellSelectedStatus status;

/// 组
@property (copy,    nonatomic) NSString *group;

+ (instancetype)modelWithUser:(TIOUser *)user;

@end

NS_ASSUME_NONNULL_END
