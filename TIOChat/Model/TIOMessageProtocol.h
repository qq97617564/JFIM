//
//  TIOMessageProtocol.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIOMessageAttachmnet.h"
#import "TIODefines.h"
#import "TIOSession.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIOMessageProtocol <NSObject>

@property (readonly, assign, nonatomic) TIOMessageType messageType;

@property (readonly, assign, nonatomic) TIOMessageDeliveryState deliveryState;

@property (strong, nonatomic) TIOSession *session;

/// 发信人
@property (copy, nonatomic) NSString *from;

/// 收信人
@property (copy, nonatomic) NSString *toUser;

/// 文本消息
@property (copy, nonatomic) NSString *text;

/// 消息ID
@property (copy, nonatomic) NSString *messageId;

/// 时间
@property (copy, nonatomic) NSString *msgTime;

/// 头像
@property (copy, nonatomic) NSString *avatar;

/// 是否是收到的消息 由于有漫游消息的概念,所以自己发出的消息漫游下来后仍旧是"收到的消息",这个字段用于消息出错是时判断需要重发还是重收
@property (nonatomic,assign)       BOOL isReceivedMsg;

/// 是否是往外发的消息 由于能对自己发消息，所以并不是所有来源是自己的消息都是往外发的消息，这个字段用于判断头像排版位置（是左还是右）。
@property (nonatomic,assign)       BOOL isOutgoingMsg;

/// 是否是历史消息
@property (nonatomic,assign)       BOOL isHistory;

// 是否是群主
@property (nonatomic, assign) BOOL isTeamSuperManager;

/// 文件、图片、音频、视频的附件
@property (nonatomic, strong) TIOMessageAttachmnet *attachmentObject;

@end

NS_ASSUME_NONNULL_END
