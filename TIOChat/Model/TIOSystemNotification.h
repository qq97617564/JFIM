//
//  TIOSystemNotification.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIOUser.h"
#import "TIOMessageObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TIOSystemNotificationType) {
    TIOSystemNotificationTypeNone   = 0,        ///< 类型不可用
    TIOSystemNotificationTypeFriendApply = 30,  ///< 好友申请
    TIOSystemNotificationTypeFriendAdd = 31,    ///< 新增好友
    TIOSystemNotificationTypeFriendDelete = 32, ///< 删除好友
    TIOSystemNotificationTypeFriendUpdate = 33, ///< 好友信息发生变更
    TIOSystemNotificationTypeError = 1000,      ///< 异常
};

typedef NS_ENUM(NSUInteger, TIOSystemNotificationCode) {
    TIOSystemNotificationCodeNotLogin   =   1001,   ///< 未登录
    TIOSystemNotificationCodeLoginTimeout=  1002,   ///< 登录超时
    TIOSystemNotificationCodeOnkicked   =   1003,   ///< 异地登陆，被挤掉
    TIOSystemNotificationCodeNotPermission= 1004,   ///< 登陆没有权限
    TIOSystemNotificationCodeRefuse     =   1005,   ///< 拒绝访问
    TIOSystemNotificationCodeNeedAccessToken=1006,  ///< 需要提供正确的access_token
    TIOSystemNotificationCodeCaptchaError=  1007,   ///< 图形验证异常
    TIOSystemNotificationCodeWasBlack   =   20002,  ///< 被拉黑
    TIOSystemNotificationCodeNotFriend  =   20003,  ///< 不是好友, 对方单方面删除你
    TIOSystemNotificationCodeFriendError=   20004,  ///< 好友异常
    TIOSystemNotificationCodeGlobalForbidden = 20005,   ///< 全局禁言
};

@interface TIOSystemNotification : TIOMessageObject

/// 通知细分的命令码，与下面的oper不同，oper是自己操作的通知码
/// TIOSystemNotificationCode
@property (assign, nonatomic) NSInteger code;

/// 会话ID
@property (assign, nonatomic) NSInteger chatlinkid;

/// 消息ID
@property (assign, nonatomic) NSInteger mid;

@property (assign, nonatomic) NSInteger touid;

@property (assign, nonatomic) NSInteger uid;

@property (assign, nonatomic) NSTimeInterval t;

@property (copy, nonatomic) NSString *msg;

/// 通知类型
@property (assign, nonatomic) TIOSystemNotificationType type;

/// 通知中带回的数据对象。比如，更改用户头像之后，bizdata就是新的用户信息，json字符串，需要手动处理
@property (copy, nonatomic) NSString *bizdata;
@property (copy, nonatomic) NSString *operbizdata;
@property (strong,  nonatomic) NSDictionary *chatItems;


// 操作通知

/// 激活状态
@property (assign, nonatomic) NSInteger actflag;

/// 操作 1:删除聊天会话；2：拉黑；3：恢复拉黑；4：激活通知；5：删除好友通知； 6:自己被删除 7：好友已读通知；8：清空聊天消息通知
/// 注意：“5:删除好友通知” 仅当同时存在会话时才会触发，TIOSystemNotificationTypeFriendDelete 没有会话时触发
@property (assign, nonatomic) NSInteger oper;
/// 激活的聊天模型：1：私聊；2：群聊
@property (assign, nonatomic) NSInteger chatmode;
/// 聊天内容
@property (copy, nonatomic) NSString *c;
/// 激活会话的头像
@property (copy, nonatomic) NSString *actavatar;
/// 激活会话的名称
@property (copy, nonatomic) NSString *actname;

/// 群操作通知的群ID
@property (copy, nonatomic) NSString *g;

#pragma mark - 红包

/// 是不是红包系统消息 1:是 2:不是
@property (assign,  nonatomic) NSInteger redflag;

@end

NS_ASSUME_NONNULL_END
