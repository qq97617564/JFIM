//
//  TIOSession.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOSession : NSObject <NSCopying>

/// 会话名称 会话列表中显示的是好友的昵称 或者 群昵称
@property (copy, nonatomic) NSString *name;

/// 会话头像 会话列表中显示的是好友的头像 或者 群头像
@property (copy, nonatomic) NSString *avatar;

/// 当前的群ID 或对方的ID
@property (copy, nonatomic) NSString *toUId;

/// 自己的uid
@property (copy, nonatomic) NSString *ownerId;

/// 会话ID，区分会话唯一标志
@property (copy,    nonatomic,  readonly) NSString *sessionId;

/// 会话类型,当前仅支持P2P,Team和Chatroom
@property (assign,  nonatomic,  readonly) TIOSessionType sessionType;

@property (assign,  nonatomic) TIOSessionLinkStatus linkStatus;


/// 通过id和type构造会话对象
/// @param sessionId    会话ID
/// @param sessionType  会话类型
+ (instancetype)session:(NSString *)sessionId
                  toUId:(NSString *)toUId
                   type:(TIOSessionType)sessionType;

@end

NS_ASSUME_NONNULL_END
