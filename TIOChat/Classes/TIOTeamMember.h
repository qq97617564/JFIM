//
//  TIOUserInTeam.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 用户在群里的信息
@interface TIOTeamMember : NSObject

/// 成员头像
@property (copy, nonatomic) NSString *avatar;
/// 成员昵称。当搜索可艾特用户时，nick是群昵称
@property (copy, nonatomic) NSString *nick;
/// 成员昵称。当搜索可艾特用户时，srcnick就是昵称
@property (copy, nonatomic) NSString *srcnick;
/// 群ID
@property (copy, nonatomic) NSString *groupId;
/// 群内昵称。仅在获取用户在群内信息时有效
@property (copy, nonatomic) NSString *groupNick;
/// 角色
@property (assign, nonatomic) TIOTeamUserRole role;
@property (copy, nonatomic) NSString *uid;
/// 备注
@property (copy, nonatomic) NSString *remarkname;

/// 禁言时长
@property (assign,  nonatomic) NSInteger forbiddenduration;
/// （禁言标识：1：时长禁言；2：否；3：长久禁用）
@property (assign,  nonatomic) NSInteger forbiddenflag;

/// 消息免打扰标识 1:开启免打扰 2:关闭免打扰
@property (assign,  nonatomic) NSInteger msgfreeflag;
/// 显示成员昵称 1:显示 2:不显示
@property (assign,  nonatomic) NSInteger nickviewflag;
///
@property (assign,  nonatomic) NSInteger officialflag;

@end

NS_ASSUME_NONNULL_END
