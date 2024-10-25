//
//  TIOUser.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOUser : NSObject <NSCopying>

/// 用户ID
@property (copy, nonatomic) NSString *userId;

/// 当以下情形时 该字段为用户ID 
/// 按昵称搜索所有用户 【TIOFriendManager】 searchUserWithOption: completion:
/// 按UID获取用户信息 【TIOFriendManager】fetchUserInfo: completion:
@property (assign, nonatomic) NSInteger friendId;

/// 头像
@property (copy, nonatomic) NSString *avatar;

/// 登录名
@property (copy, nonatomic) NSString *loginname;

/// 好友的备注名
@property (copy, nonatomic) NSString *remarkname;

/// 昵称
@property (copy, nonatomic) NSString *nick;

/// 注册时间
@property (copy, nonatomic) NSString *createtime;

/// 最新的登录时间
@property (copy, nonatomic) NSString *updatetime;

/// 等级
@property (assign, nonatomic) NSInteger level;

@property (copy, nonatomic) NSString *country;

@property (copy, nonatomic) NSString *province;

@property (copy, nonatomic) NSString *city;

@property (copy, nonatomic) NSString *sign;

/// 索引
@property (copy, nonatomic) NSString *chatindex;


@end

NS_ASSUME_NONNULL_END
