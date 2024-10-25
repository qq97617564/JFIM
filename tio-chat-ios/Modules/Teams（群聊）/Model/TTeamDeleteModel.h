//
//  TTeamDeleteModel.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/20.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTeamDefines.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 批量删除好友的model
@interface TTeamDeleteModel : NSObject

/// 成员信息
@property (strong, nonatomic) TIOTeamMember *user;

/// 选中状态
@property (assign, nonatomic) TCellSelectedStatus status;

+ (instancetype)modelWithUser:(TIOTeamMember *)user;

@end

NS_ASSUME_NONNULL_END
