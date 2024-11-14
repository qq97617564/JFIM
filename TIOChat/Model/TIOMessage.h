//
//  TIOMessage.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"
#import "TIOSession.h"
#import "TIOMessageAttachmnet.h"
#import "TIOMessageObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOMessage : TIOMessageObject

@property (assign, nonatomic) TIOMessageType messageType;

@property (readonly, assign, nonatomic) TIOMessageDeliveryState deliveryState;

/// 构造发送消息时，一定要设置session
@property (strong, nonatomic) TIOSession *session;

/// 消息发送者昵称
@property (copy, nonatomic) NSString *from;
/// 消息发送者的用户ID
@property (copy, nonatomic) NSString *fromUId;

/// 消息接收人
@property (copy, nonatomic) NSString *toUser;

/// 消息接收方的uid
@property (copy, nonatomic) NSString *toUId;
/// 会话方用户ID 群聊时：群ID
@property (copy, nonatomic) NSString *groupId;

@property (copy, nonatomic) NSString *at;

/// 文本消息
@property (copy, nonatomic) NSString *text;

/// 消息ID
@property (copy, nonatomic) NSString *messageId;

/// 发送时间 已格式化
@property (copy, nonatomic) NSString *msgTime;
/// 发送时间 时间戳
@property (assign, nonatomic) NSTimeInterval timestamp;

/// 头像
@property (copy, nonatomic) NSString *avatar;

/// 是否是收到的消息 由于有漫游消息的概念,所以自己发出的消息漫游下来后仍旧是"收到的消息",这个字段用于消息出错是时判断需要重发还是重收
@property (nonatomic,assign)       BOOL isReceivedMsg;

/// 是否是往外发的消息 由于能对自己发消息，所以并不是所有来源是自己的消息都是往外发的消息，这个字段用于判断头像排版位置（是左还是右）。
@property (nonatomic,assign)       BOOL isOutgoingMsg;

/// 是否是历史消息
@property (nonatomic,assign)       BOOL isHistory;

/// 是否已读
@property (nonatomic, assign) BOOL  isReaded;

// 是否是群主
@property (nonatomic, assign) BOOL isTeamSuperManager;

/// 文件、图片、音频、视频、视频通话
@property (nonatomic, strong) NSArray<TIOMessageAttachmnet *> *attachmentObjects;

/// 异常代码
@property (assign, nonatomic) NSInteger code;

/// 是否激活聊天消息 1:是；2：否
@property (assign, nonatomic) NSInteger actflag;

/// 消息是不是由系统发出
@property (assign, nonatomic) TIOMessageSendBy sendBy;

/// 通道：2:消息可以显示   1:该消息且sigleuid是当前登陆用户自己，显示，否则不显示
@property (assign, nonatomic) NSInteger sigleflag;
@property (copy  , nonatomic) NSString *sigleuid;
/// 1:需要再判断whereuid中是否有自己，有，不显示该消息   2:正常显示该消息
@property (assign, nonatomic) NSInteger whereflag;
@property (copy  , nonatomic) NSString *whereuid;

#pragma mark - 消息提醒

@property (assign, nonatomic) NSInteger sysFlag;

/// 操作者
@property (copy,   nonatomic) NSString *opernick;
/// 被操操作对象
@property (copy,   nonatomic) NSString *tonicks;
/// 消息提醒的操作
/// create 邀请
/// join                        opernick+"邀请"+tonicks+"加入了群聊";
/// ownerleave           opernick+"退出了群聊，"+tonicks+"自动成为群主";
/// leave                     opernick+"退出了群聊";
/// operkick                opernick+"将"+tonicks+"移除了群聊";
/// tokick                    tonicks+"被"+nick+"移除了群聊";
/// msgback               opernick+"撤回了一条消息";
/// ownerchange        opernick+"将群主转让给了"+tonicks;
/// applyopen             opernick+"开启了群邀请开关：所有人都可以邀请人员进群";
/// applyclose             opernick+"关闭了群邀请开关：只有群主或者群管理员才能邀请人员进群";
/// reviewopen           opernick+"开启群审核开关：成员进群前,必须群主或者群管理员审核通过";
/// reviewclose           opernick+"关闭了群审核开关：成员进群不需要审核"
/// updatenotice         opernick+"修改了群公告:"+tonicks;
/// updatename          opernick+"修改了群名称:"+tonicks;
/// delgroup                opernick+"解散了群";
@property (copy,   nonatomic) NSString *sysmsgkey;

#pragma mark - 发送名片时，必须为设置以下属性

/// 1:个人名片  2:群名片
@property (assign, nonatomic) NSInteger cardType;
/// 名片id:好友的用户id/群的id
@property (copy,   nonatomic) NSString *cardid;

@property (strong,  nonatomic) NSDictionary *apply;

#pragma mark - 超链接消息

@property (strong,  nonatomic) NSDictionary *superlinkItem;

@property (assign, nonatomic) NSInteger officialflag;
@property (assign, nonatomic) NSInteger xx;

@end

NS_ASSUME_NONNULL_END
