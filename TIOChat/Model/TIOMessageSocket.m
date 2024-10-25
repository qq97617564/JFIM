//
//  TIOMessageSocket.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOMessageSocket.h"
#import "NSString+tio.h"
#import "TIOChat.h"
#import "NSObject+CBJSONSerialization.h"
#if __has_include(<YYModel/YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif

@interface TIOMessageSocket ()

@property (copy, nonatomic) NSString *nick;
/// 该消息是否由系统发出，1、是系统发出的消息，2、不是系统发的消息
@property (assign, nonatomic) NSInteger sendbysys;
/// 已读标识。1、已读，2、未读
@property (assign, nonatomic) NSInteger readflag;
/// （私聊）发送方的userid，此字段和curruid对比
@property (copy, nonatomic) NSString *uid;
/// 消息接收方的uid
@property (copy, nonatomic) NSString *touid;
/// （群聊）发送方的userid，此字段和curruid对比
@property (copy, nonatomic) NSString *f;
/// 消息格式。1、普通文本消息，2、博客，3、文件，4、音频，5、视频，6：图片 
@property (assign, nonatomic) NSInteger ct;
/// 消息的类型：1：正常消息：2：操作消息
@property (assign, nonatomic) NSInteger msgtype;
/// 聊天会话id
@property (copy, nonatomic) NSString *chatlinkid;

@property (copy, nonatomic) NSString *readtime;

/// 会话头像 当actflag = 1 为激活消息时，属性有效
@property (copy, nonatomic) NSString *actavatar;

/// 会话名称 当actflag = 1 为激活消息时，属性有效
@property (copy, nonatomic) NSString *actname;


@property (strong, nonatomic) NSString *c;
@property (strong, nonatomic) TIOMessageAttachmnet *ic; // 图片消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *fc; // 文件消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *vc; // 视频消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *ac; // 音频消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *bc; // 微博消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *cardc; // 微博消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *call; // 视频通话
@property (strong, nonatomic) TIOMessageAttachmnet *red; // 红包

@end

@implementation TIOMessageSocket

@synthesize avatar = _avatar;
//
//@synthesize deliveryState;
//
//@synthesize from;
//
//@synthesize isHistory;
//
//@synthesize isOutgoingMsg;
//
//@synthesize isReceivedMsg;
//
//@synthesize isTeamSuperManager;
//
@synthesize messageId = _messageId;
@synthesize toUId = _toUId;
@synthesize groupId = _groupId;
//
@synthesize messageType = _messageType;
//
@synthesize msgTime = _msgTime;
//
@synthesize session = _session;

@synthesize fromUId = _fromUId;

@synthesize isReaded = _isReaded;
//
//@synthesize text;
//
//@synthesize toUser;
//

@synthesize timestamp = _timestamp;

@synthesize attachmentObjects = _attachmentObjects;

@synthesize sendBy = _sendBy;

@synthesize text = _text;

@synthesize sysFlag = _sysFlag;

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"messageId" : @"mid",
        @"groupId" : @"g",
        @"timestamp" : @"t",
        @"toUId" : @"touid",
        @"sysFlag" : @"sysflag",
        @"superlinkItem" : @"temp"
    };
}

+ (NSDictionary<NSString *,Class> *)JSONArrayClassMapping
{
    return @{
        @"ic" : [TIOMessageAttachmnet class],
        @"fc" : [TIOMessageAttachmnet class],
        @"vc" : [TIOMessageAttachmnet class],
        @"ac" : [TIOMessageAttachmnet class],
        @"bc" : [TIOMessageAttachmnet class],
        @"cardc" : [TIOMessageAttachmnet class],
        @"red" : [TIOMessageAttachmnet class],
        @"call" : [TIOMessageAttachmnet class]
    };
}

- (NSString *)text
{
    if (!_text) {
        if (_ct == 9) {
            _text = @"分享一个名片";
        } else if (_ct == 6) {
            _text = @"分享一个图片";
        } else if (_ct == 3) {
            _text = @"分享一个文件";
        } else if (_ct == 4) {
            _text = @"[语音消息]";
        } else if (_ct == 5) {
            _text = @"分享一个视频";
        } else if (_ct == 10){
            _text = @"[视频通话]";
        } else if (_ct == 11) {
            _text = @"[音频通话]";
        } else if (_ct == 12) {
            _text = @"发了一个红包";
        } else if (_ct == 13) {
            _text = @"收到一条入群申请";
        } else if (_ct == 88) {
            _text = @"分享一个链接";
        } else {
            _text = _c;
        }
    }
    return _text;
}

- (TIOMessageType)messageType
{
    if (!_messageType) {
        
        if (self.sendbysys == 1) {
            return _messageType = TIOMessageTypeTip;
        }
        
        if (self.ct == 1) {
            _messageType = TIOMessageTypeText;
        } else if (self.ct == 2) {
            _messageType = TIOMessageTypeSuperLink;
        } else if (self.ct == 3) {
            _messageType = TIOMessageTypeFile;
        } else if (self.ct == 4) {
            _messageType = TIOMessageTypeAudio;
        } else if (self.ct == 5) {
            _messageType = TIOMessageTypeVideo;
        } else if (self.ct == 6) {
            _messageType = TIOMessageTypeImage;
        } else if (self.ct == 9) {
            _messageType = TIOMessageTypeCard;
        } else if (self.ct == 10) {
            _messageType = TIOMessageTypeVideoChat;
        } else if (self.ct == 11) {
            _messageType = TIOMessageTypeAudioChat;
        } else if (self.ct == 12) {
            _messageType = TIOMessageTypeRed;
        } else if (self.ct == 13) {
            _messageType = TIOMessageTypeRichTip;
        } else if (self.ct == 88) {
            _messageType = TIOMessageTypeSuperLink;
        } else {
            _messageType = TIOMessageTypeCustom;
        }
    }
    
    return _messageType;
}

- (TIOSession *)session
{
    if (!_session) {
        NSString *toUid = nil;
        if (self.isOutgoingMsg) {
            // 自己的消息
            toUid = self.groupId?:self.toUId;
        } else {
            // 别人的消息
            toUid = self.groupId?:self.fromUId;
        }

        _session = [TIOSession session:self.chatlinkid toUId:toUid type:self.groupId?TIOSessionTypeTeam:TIOSessionTypeP2P];
        _session.name = _actname;
        _session.avatar = _actavatar.tio_resourceURLString;
    }
    
    return _session;
}

- (NSString *)from
{
    return self.nick;
}

- (NSString *)fromUId
{
    if (!_fromUId ) {
        if (self.groupId) {
            _fromUId = self.f;
        } else {
            _fromUId = self.uid;
        }
    }
    return _fromUId;
}

- (NSString *)toUser
{
    return @"未知";
}

- (BOOL)isHistory
{
    return YES;
}

- (BOOL)isOutgoingMsg
{
    return [self.fromUId isEqualToString:[TIOChat.shareSDK.loginManager userInfo].userId];
}

- (BOOL)isTeamSuperManager
{
    return NO;
}

- (BOOL)isReaded
{
    return self.readflag == 1;
}

- (void)setIsReaded:(BOOL)isReaded
{
    self.readflag = isReaded?1:2;
}

- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}

- (NSString *)msgTime
{
    if (!_msgTime) {
        _msgTime = [self getTimestamp:_timestamp];
    }
    return _msgTime;
}

/// 时间戳转时间
/// @param timestamp 时间戳
- (NSString *)getTimestamp:(NSTimeInterval)timestamp
{
    
    NSDate *date              = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    
    NSString *dateString      = [formatter stringFromDate: date];
    
    return dateString;
    
}

- (NSArray<TIOMessageAttachmnet *> *)attachmentObjects
{
    if (!_attachmentObjects) {
        
        if (self.ct == 2) {
            _attachmentObjects = @[self.bc];
        } else if (self.ct == 3) {
            _attachmentObjects = @[self.fc];
        } else if (self.ct == 4) {
            _attachmentObjects = @[self.ac];
        } else if (self.ct == 5) {
            _attachmentObjects = @[self.vc];
        } else if (self.ct == 6) {
            _attachmentObjects = @[self.ic];
        } else if (self.ct == 9) {
            _attachmentObjects = @[self.cardc];
        } else if (self.ct == 10 || self.ct == 11) {
            _attachmentObjects = @[self.call];
        } else if (self.ct == 12) {
            _attachmentObjects = @[self.red];
        } else {
            
        }
    }
    
    return _attachmentObjects;
}

- (TIOMessageSendBy)sendBy
{
    if (_sendBy == 1 || _sendbysys == 1) {
        return TIOMessageSendBySystem;
    } else if (_sendBy == 2 || _sendbysys == 2) {
        return TIOMessageSendByUser;
    } else {
        return TIOMessageSendByUser;
    }
}

@end
