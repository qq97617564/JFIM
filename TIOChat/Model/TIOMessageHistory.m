//
//  TIOMessageHistory.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOMessageHistory.h"
#import "NSString+tio.h"
#import "TIOChat.h"
#import "NSObject+CBJSONSerialization.h"
#import <YYModel/YYModel.h>

@interface TIOMessageHistory ()

@property (copy, nonatomic) NSString *nick;
/// 该消息是否由系统发出，1、是系统发出的消息，2、不是系统发的消息
@property (assign, nonatomic) NSInteger sendbysys;
/// 已读标识。1、已读，2、未读
@property (assign, nonatomic) NSInteger readflag;
/// 发送方的userid，此字段和curruid对比
@property (copy, nonatomic) NSString *uid;
/// （群聊）发送方的userid，此字段和curruid对比
@property (copy, nonatomic) NSString *f;
/// 消息格式。1、普通文本消息，2、博客，3、文件，4、音频，5、视频，6：图片
@property (assign, nonatomic) NSInteger ct;
/// 消息的类型：1：正常消息：2：操作消息
@property (assign, nonatomic) NSInteger msgtype;
/// 聊天会话id
@property (copy, nonatomic) NSString *chatlinkid;

@property (copy, nonatomic) NSString *readtime;

@property (strong, nonatomic) TIOMessageAttachmnet *ic; // 图片消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *fc; // 文件消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *vc; // 视频消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *ac; // 音频消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *bc; // 微博消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *cardc; // 微博消息内容
@property (strong, nonatomic) TIOMessageAttachmnet *call; // 视频通话
@property (strong, nonatomic) TIOMessageAttachmnet *red; // 红包

@end

@implementation TIOMessageHistory

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
//
@synthesize messageType = _messageType;
//
@synthesize msgTime = _msgTime;
//
@synthesize session = _session;

@synthesize fromUId = _fromUId;
//
//@synthesize text;
//
//@synthesize toUser;
//
@synthesize timestamp = _timestamp;

@synthesize attachmentObjects = _attachmentObjects;

@synthesize isReaded = _isReaded;

@synthesize sysFlag = _sysFlag;
@synthesize sendBy = _sendBy;

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"messageId" : @"mid",
        @"toUId" : @"uid",
        @"groupId" : @"g",
        @"msgTime" : @"t",
        @"text" : @"c",
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

- (TIOMessageType)messageType
{
    if (!_messageType) {
        
        if (self.sendbysys == 1) {
            return _messageType = TIOMessageTypeTip;
        }
        
        if (_ct == 1) {
            _messageType = TIOMessageTypeText;
        } else if (_ct == 2) {
            _messageType = TIOMessageTypeSuperLink;
        } else if (_ct == 3) {
            _messageType = TIOMessageTypeFile;
        } else if (_ct == 4) {
            _messageType = TIOMessageTypeAudio;
        } else if (_ct == 5) {
            _messageType = TIOMessageTypeVideo;
        } else if (_ct == 6) {
            _messageType = TIOMessageTypeImage;
        } else if (_ct == 9) {
            _messageType = TIOMessageTypeCard;
        } else if (_ct == 10) {
            _messageType = TIOMessageTypeVideoChat;
        } else if (_ct == 11) {
            _messageType = TIOMessageTypeAudioChat;
        } else if (_ct == 12) {
            _messageType = TIOMessageTypeRed;
        } else if (_ct == 13) {
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
        _session = [TIOSession session:self.groupId?:self.chatlinkid toUId:self.uid type:self.groupId?TIOSessionTypeTeam:TIOSessionTypeP2P];
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

- (NSTimeInterval )timestamp
{
    if (!_timestamp) {
        _timestamp = [self timeSwitchTimestamp:_msgTime];
    }
    return _timestamp;
}

- (NSTimeInterval)timeSwitchTimestamp:(NSString *)formatTime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    NSTimeInterval timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue] * 1000;
    
    return timeSp;
    
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
    if (_sendBy == 1) {
        return TIOMessageSendBySystem;
    } else if (_sendBy == 2) {
        return TIOMessageSendByUser;
    } else {
        return TIOMessageSendByUser;
    }
}

@end
