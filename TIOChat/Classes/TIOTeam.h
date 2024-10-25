//
//  TIOTeam.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/25.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TIOTeamJoinType) {
    TIOTeamJoinTypeReview   =   1,  ///< 审核入群
    TIOTeamJoinTypeNotReview   =   2,  ///< 不审核入群
};

typedef NS_ENUM(NSUInteger, TIOTeamStatus) {
    TIOTeamStatusNormal =   1,  ///< 正常群
    TIOTeamStatusDissolved  =   3, ///< 已被群主解散
};


@interface TIOTeam : NSObject

/// 群id
@property (copy,    nonatomic) NSString *teamId;

/// 群简介
@property (copy,    nonatomic) NSString *intro;

/// 群名字
@property (copy,    nonatomic) NSString *name;

/// 群头像
@property (copy,    nonatomic) NSString *avatar;

/// 群公告
@property (copy,    nonatomic) NSString *notice;

/// 创建时间
@property (copy,    nonatomic) NSString *createtime;

/// 群主ID
@property (copy,    nonatomic) NSString *managerId;

/// 群成员数
@property (assign,  nonatomic) NSInteger    memberNumber;

/// 进群方式
@property (assign,  nonatomic) TIOTeamJoinType joinType;

/// 当前群的状态
@property (assign,  nonatomic) TIOTeamStatus status;

/// YES:开启群邀请   NO：关闭群邀请
@property (assign,  nonatomic) BOOL applyFlag;

/// 全员禁用：1：是；2：否
@property (assign,  nonatomic) NSInteger forbiddenflag;

@property (assign, nonatomic) TIOTeamUserRole grouprole;

/// 群内互加好友 1:可以 2:不可以
@property (assign,  nonatomic) NSInteger friendflag;

@end

NS_ASSUME_NONNULL_END
