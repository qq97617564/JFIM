//
//  TIOConversationManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOConversationManager.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOMessageSocket.h"
#import "NSString+tio.h"
#import "TIOSession.h"
#import "TIOHTTPSManager.h"
#import "TIOBroadcastDelegate.h"
#import "TIOMacros.h"
#import "NSString+tio.h"
#import "TIOMessageHistory.h"
#import "TIOCmdConfiguator.h"
#import "TIOChat.h"
#import "TIOSocketPackage.h"
#import "TIOSystemNotification.h"
#import "BGFMDB.h"
#import "BGDB.h"
#import "TIODataBase.h"
#import "TIODBDefines.h"
#import "TIOSessionActiveCenter.h"
#import "TIONetworkNotificationCenter.h"

#import <objc/message.h>

#if __has_include(<YYModel/YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif


@interface TIORecentSession ()

@property (copy,    nonatomic) NSString *avatar;

@property (copy,    nonatomic) NSString *lastmsguid; // 消息发件人的UID
@property (copy,    nonatomic) NSString *name; // 聊天会话名
@property (copy,    nonatomic) NSString *fromnick; // 发件人名字
@property (copy,    nonatomic) NSString *sendtime; // 发送时间
@property (copy,    nonatomic) NSString *msgresume; // 内容
@property (copy,    nonatomic) NSString *chatuptime;   // 按此时间排序，显示会话时间
@property (copy,    nonatomic) NSString *opernick;
@property (copy,    nonatomic) NSString *sysmsgkey;
@property (copy,    nonatomic) NSString *tonicks;
/// 好友组合uid的key-twouid
@property (copy,    nonatomic) NSString *fidkey;

@property (assign,  nonatomic) NSInteger atnotreadcount;    // 未读的被@的消息数
@property (assign,  nonatomic) NSInteger notreadcount;  // 未读消息数
@property (assign,  nonatomic) NSInteger notreadstartmsgid; // 第一条未读消息开始的msgId，再次进入会话，可以回滚从这条消息往下看新消息
@property (assign,  nonatomic) NSInteger atnotreadstartmsgid; // 最近被@的msgId
@property (assign,  nonatomic) NSInteger sysflag;
@property (assign,  nonatomic) NSInteger toreadflag;
@property (assign,  nonatomic) NSInteger viewflag;
@property (assign,  nonatomic) NSInteger bizid;
@property (assign,  nonatomic) NSInteger chatlinkid;
@property (assign,  nonatomic) NSInteger readflag; //
@property (assign,  nonatomic) NSInteger topflag;
@property (assign,  nonatomic) NSInteger linkflag;
@property (assign,  nonatomic) NSInteger chatmode; // 聊天会话的模型：1：私聊；2：群聊
@property (assign,  nonatomic) NSInteger lastmsgid; // 消息ID
@property (assign,  nonatomic) NSInteger linkid;    // 聊天好友的ID
@property (assign,  nonatomic) NSInteger msgtype;   // 消息类型，同TIOMessage


@end

@implementation TIORecentSession

@synthesize lastMessage = _lastMessage;
@synthesize session =   _session;

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"sysFlag" : @"sysflag",
        @"toReadFlag" : @"toreadflag",
        @"viewFlag" : @"viewflag",
        @"unReadCount" : @"notreadcount",
        @"toUId" : @"bizid",
        @"sessionId" : @"chatlinkid"
    };
}

- (BOOL)modelPropertiesTransformFromDictionary:(NSDictionary *)dic
{
    if (self.readflag == 1) {
        // 已读
        self.isUnread = NO;
    } else if (self.readflag == 2) {
        // 未读
        self.isUnread = YES;
    } else {
        self.isUnread = NO;
    }
    
    if (self.topflag == 1) {
        self.isTop = YES;
    } else if (self.topflag == 2) {
        self.isTop = NO;
    } else {
        self.isTop = NO;
    }
    
    if (self.linkflag == 1) {
        self.linkStatus = TIOSessionLinkStatusValid;
    } else if (self.linkflag == 2) {
        self.linkStatus = TIOSessionLinkStatusInvalid;
    } else {
        self.linkStatus = TIOSessionLinkStatusUnknown;
    }
    
    if (self.sysflag == 1) {
        self.toReadFlag = 1;
    }
    
    return YES;
}

- (TIOMessage *)lastMessage
{
    if (!_lastMessage) {
        _lastMessage = [TIOMessage.alloc init];
        _lastMessage.messageId = [NSString stringWithFormat:@"%zd",_lastmsgid];
        _lastMessage.from = _fromnick;
        _lastMessage.msgTime = _chatuptime;
        _lastMessage.timestamp = [self timeSwitchTimestamp:_chatuptime];
        _lastMessage.text = _msgresume?:@"";
        _lastMessage.opernick = _opernick;
        _lastMessage.sysmsgkey = _sysmsgkey;
        _lastMessage.tonicks = _tonicks;
        _lastMessage.sysFlag = _sysFlag;
        _lastMessage.fromUId = _lastmsguid;
        _lastMessage.isReaded = !_isUnread;
        _lastMessage.session = self.session;
        _lastMessage.messageType = _msgtype;
        if (_sysflag == 1) {
            _lastMessage.messageType = TIOMessageTypeTip;
        } else if (_msgtype == 1) {
            _lastMessage.messageType = TIOMessageTypeText;
        } else if (_msgtype == 2) {
            _lastMessage.messageType = TIOMessageTypeSuperLink;
        } else if (_msgtype == 3) {
            _lastMessage.messageType = TIOMessageTypeFile;
        } else if (_msgtype == 4) {
            _lastMessage.messageType = TIOMessageTypeAudio;
        } else if (_msgtype == 5) {
            _lastMessage.messageType = TIOMessageTypeVideo;
        } else if (_msgtype == 6) {
            _lastMessage.messageType = TIOMessageTypeImage;
        } else if (_msgtype == 9) {
            _lastMessage.messageType = TIOMessageTypeCard;
        } else if (_msgtype == 10) {
            _lastMessage.messageType = TIOMessageTypeVideoChat;
        } else if (_msgtype == 11) {
            _lastMessage.messageType = TIOMessageTypeAudioChat;
        } else if (_msgtype == 12) {
            _lastMessage.messageType = TIOMessageTypeRed;
        } else if (_msgtype == 13) {
            _lastMessage.messageType = TIOMessageTypeRichTip;
        } else {
            _lastMessage.messageType = TIOMessageTypeCustom;
        }
    }
    return _lastMessage;
}

- (NSInteger)unReadCount
{
    return _notreadcount;
}

- (void)setLastMessage:(TIOMessage *)lastMessage
{
    _lastMessage = lastMessage;
    _fromnick = lastMessage.from;
    _sendtime = lastMessage.msgTime;
    _chatuptime = lastMessage.msgTime;
    _msgresume = lastMessage.text;
    // 根据消息类型显示不同文案
    if (lastMessage.messageType == TIOMessageTypeText) {
        _msgresume = lastMessage.text;
    } else if (lastMessage.messageType == TIOMessageTypeRed) {
        _msgresume = @"发了一个红包";
    } else if (lastMessage.messageType == TIOMessageTypeCard) {
        _msgresume = @"分享一个名片";
    } else if (lastMessage.messageType == TIOMessageTypeAudio) {
        _msgresume = @"[语音消息]";
    } else if (lastMessage.messageType == TIOMessageTypeAudioChat) {
        _msgresume = @"[语音通话]";
    } else if (lastMessage.messageType == TIOMessageTypeVideo) {
        _msgresume = @"分享一个视频";
    } else if (lastMessage.messageType == TIOMessageTypeVideoChat) {
        _msgresume = @"[视频通话]";
    } else if (lastMessage.messageType == TIOMessageTypeFile) {
        _msgresume = @"分享一个文件";
    } else if (lastMessage.messageType == TIOMessageTypeRichTip) {
        _msgresume = @"收到一条入群申请";
    } else if (lastMessage.messageType == TIOMessageTypeSuperLink) {
        _msgresume = @"分享一个链接";
    } else {
        _msgresume = lastMessage.text;
    }
    _msgtype = lastMessage.messageType;
    _opernick = lastMessage.opernick?:@""; // 不是服务端的每个消息里，该字段都会有值，当为nil时，数据库会沿用上一次的结果，需要手动存储@“”，下面的sysmsgkey，tonicks同此。
    _sysmsgkey = lastMessage.sysmsgkey?:@"";
    _lastmsguid = lastMessage.fromUId;
    _sysflag = lastMessage.sendBy == TIOMessageSendBySystem ? 1 : 2;
    _tonicks = lastMessage.tonicks?:@"";
}

- (TIOSession *)session
{
    if (!_session) {
        TIOSessionType type;
        NSString *sessionId = self.sessionId;
        if (self.chatmode == 1) {
            type = TIOSessionTypeP2P;
        } else if (self.chatmode == 2) {
            type = TIOSessionTypeTeam;
        } else {
            type = TIOSessionTypeP2P;
        }
        _session = [TIOSession session:sessionId toUId:self.toUId type:type];
        _session.name = _name;
        _session.avatar = _avatar.tio_resourceURLString;
        _session.linkStatus = _linkStatus;
    }
    return _session;
}

/// 下面所有重写set，都只是为了恢复server端的json原本各个key的内容，以便我们保存到数据库时，这些字段够有值。
/// 我们把server端的json当作标准，我们可以映射成OC model，所以无论是server来的、还是DB读取的原始数据，都可以转成我们的OC model。
- (void)setSession:(TIOSession *)session
{
    _session = session;
    
    if (session.sessionType == TIOSessionTypeP2P) {
        _chatmode = 1;
    } else {
        _chatmode = 2;
    }
    
    _bizid = session.toUId.integerValue;
    _name = session.name;
    _avatar = session.avatar;
    self.sessionId = session.sessionId;
    
    self.linkStatus = session.linkStatus;
}

- (void)setSessionId:(NSString *)sessionId
{
    _sessionId = sessionId;
    _chatlinkid = sessionId.integerValue;
}

- (void)setLinkStatus:(TIOSessionLinkStatus)linkStatus
{
    _linkStatus = linkStatus;
    
    if (linkStatus == TIOSessionLinkStatusValid) {
        _linkflag = 1;
    } else if (linkStatus == TIOSessionLinkStatusInvalid) {
        _linkflag = 2;
    } else if (linkStatus == TIOSessionLinkStatusUnknown) {
        _linkflag = 3;
    }
}

- (void)setSysFlag:(NSInteger)sysFlag
{
    _sysFlag = sysFlag;
    _sysflag = sysFlag;
}

- (void)setIsTop:(BOOL)isTop
{
    _isTop = isTop;
    _topflag = isTop?1:2;
}

- (void)setIsUnread:(BOOL)isUnread
{
    _isUnread = isUnread;
    
    _readflag = isUnread?2:1;
}

- (void)setToReadFlag:(NSInteger)toReadFlag
{
    _toReadFlag = toReadFlag;
    _toreadflag = toReadFlag;
}

- (void)setViewFlag:(NSInteger)viewFlag
{
    _viewFlag = viewFlag;
    _viewflag = viewFlag;
}

- (void)setUnReadCount:(NSInteger)unReadCount
{
    _notreadcount = unReadCount;
}

+ (NSArray *)bg_uniqueKeys
{
    return @[@"sessionId"];
    
}

+ (NSArray *)bg_ignoreKeys
{
    return @[@"session",@"lastMessage",@"linkStatus",@"sysFlag",@"isTop",@"isUnread",@"toReadFlag",@"viewFlag",@"unReadCount",@"toUId"];
}

#pragma mark - private

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

@end


//@interface TIOSessionUnReadObject : NSObject
///// 是否统计count
//@property (nonatomic, assign) BOOL canWrite;
///// 未读数
//@property (nonatomic, assign) NSInteger count;
//
//@end
//
//@implementation TIOSessionUnReadObject
//
//@end



@interface TIOConversationManager ()
@property (nonatomic, strong) TIOBroadcastDelegate<TIOConversationDelegate> *multiDelegate;
/// 会话未读消息数缓存
/// key：会话ID value：未读数
//@property (nonatomic, strong) NSMutableDictionary<NSString *, TIOSessionUnReadObject*> *unReadAndSessionCache;

@property (nonatomic,   copy) TIOFetchMessageHistoryHandler messageHistoryHandler;

@property (nonatomic,   copy) TIOEnterConversationHandler requestSessionInfoBlock;

@end

@implementation TIOConversationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOConversationDelegate> *)[TIOBroadcastDelegate.alloc init];
//        _unReadAndSessionCache = [NSMutableDictionary dictionary];
        
        CBWeakSelf
        TIOSessionActiveCenter.shareInstance.clearSession = ^(NSString * _Nonnull sesionId) {
            CBStrongSelfElseReturn
            [self updateDBForUnreadcount:0 sessionId:sesionId completion:^(TIORecentSession *session) {
                // 已经更新本地数据
                // 通知APP这条会话全部已读
                [self.multiDelegate didChangeUnreadCount:0 inSession:session];
            }];
        };
        
        // 监听表创建
        BGDB.shareManager.createdDBBlock = ^(NSString *tablename) {
            
        };
        
        TIOLog(@"数据库 : %@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject]);
    }
    return self;
}

- (void)enterConversationWithSession:(TIOSession *)session uid:(NSString *)uid completion:(nonnull TIOEnterConversationHandler)completion
{
    // 当前持有的会话
    _session = session;
    
    NSString *sessionId = session.sessionId;
    
    NSDictionary *params = @{@"chatlinkid" : sessionId?:@"",
                             @"oper" : @"1"
    };
    
    TIOSocketPackage *socketPackage = [TIOSocketPackage.alloc init];
    socketPackage.gzip = 0;
    socketPackage.cmd = 710;
    socketPackage.body = params;
    [TIOChat.shareSDK sendMessage:socketPackage];
//    [self updateDBForUnreadcount:0 sessionId:sessionId];
//    // 刷新未读消息总数
//    [self refreshUnReadTotalCount];
//    [self.multiDelegate didChangeUnreadCount:0 inSession:sessionId];
}

- (void)leaveConversationWithSessionId:(NSString *)sessionId completion:(TIOConversationError)completion
{
    
    NSDictionary *params = @{@"chatlinkid" : _session.sessionId?:@"",
                             @"oper" : @"2"
    };
    
    TIOSocketPackage *socketPackage = [TIOSocketPackage.alloc init];
    socketPackage.gzip = 0;
    socketPackage.cmd = 710;
    socketPackage.body = params;
    [TIOChat.shareSDK sendMessage:socketPackage];
}

- (void)fetchServerSessions:(TIOFetchRecentSessionsBlock)completion
{
    [TIOHTTPSManager tio_POST:@"/chat/list" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        START_TIME(t)
        NSArray<TIORecentSession *> *list = [TIORecentSession objectArrayWithJSONArray:responseObject[@"data"]];
        END_TIME(t, @"YYModel 转换时间")
            completion(list, nil);
        [TIORecentSession bg_saveOrUpdateArrayAsync:list complete:^(BOOL isSuccess) {
            if (isSuccess) {
                TIOLog(@"网络数据存储完毕");
            }
        }];

        NSInteger total = 0;
        for (TIORecentSession *recenetSession in list) {
            total += recenetSession.unReadCount;
        }

            // 通知上层开发者，所有的会话的未读消息总数
        [self.multiDelegate didChangeTotalUnreadCount:total];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            TIOLog(@"error:\n%@",error);
            completion(nil, error);
        }];
}

- (NSArray<TIORecentSession *> *)allRecentSessions
{
    NSArray<TIORecentSession *> *list = nil;
    if ([BGDB.shareManager bg_isExistWithTableName:bg_tablename]) {
        
        list = [TIORecentSession bg_findAll:bg_tablename];

        NSInteger total = 0;
        for (TIORecentSession *recenetSession in list) {
            total += recenetSession.unReadCount;
        }

        // 通知上层开发者，所有的会话的未读消息总数
        [self.multiDelegate didChangeTotalUnreadCount:total];
    }
    return list;
}

- (void)fetchAllRecentSessions:(TIOFetchRecentSessionsBlock)completion
{
    BGDB.shareManager.sqliteName = [TIOChat.shareSDK.loginManager.userInfo userId];
    [BGDB.shareManager addToThreadPool:^{
        
        if ([BGDB.shareManager bg_isExistWithTableName:bg_tablename]) {
            [BGDB.shareManager addToThreadPool:^{
                [BGDB.shareManager queryWithTableName:bg_tablename where:nil complete:^(NSArray * _Nullable array) {
                    
                    NSArray *modelArray = [TIORecentSession objectArrayWithJSONArray:array];
                    
                    TIOLog(@"[同步][DB][select] 读取本地所有会话个数：%zd",modelArray.count);

                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSInteger total = 0;
                        for (TIORecentSession *recenetSession in modelArray) {
                            total += recenetSession.unReadCount;
                        }
                        // 通知上层开发者，所有的会话的未读消息总数
                        [self.multiDelegate didChangeTotalUnreadCount:total];
                        completion(modelArray, nil);
                    });

                }];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@[],[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"表不存在"}]);
            });
        }
    }];
    
//    START_TIME(t)
//    [TIORecentSession bg_findAllAsync:bg_tablename complete:^(NSArray * _Nullable array) {
//        END_TIME(t,@"queryWithTableName——数据库读取完成")
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSInteger total = 0;
//            for (TIORecentSession *recenetSession in array) {
//                total += recenetSession.unReadCount;
//            }
//            // 通知上层开发者，所有的会话的未读消息总数
//            [self.multiDelegate didChangeTotalUnreadCount:total];
//            completion(array, nil);
//        });
//    }];
}

- (void)fetchMessagesHistory:(TIOSession *)session startMsgId:(NSString * _Nullable)startMsgId endMsgId:(NSString * _Nullable)endMsgId completion:(nonnull TIOFetchMessageHistoryHandler)completion
{
    self.messageHistoryHandler = completion;
    
    NSInteger cmd = 0;
    if (session.sessionType == TIOSessionTypeP2P) {
        cmd = 604;
    } else if (session.sessionType == TIOSessionTypeTeam) {
        cmd = 620;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"chatlinkid"] = session.sessionId;
    if (startMsgId) {
        params[@"startmid"] = startMsgId;
    }
    if (endMsgId) {
        params[@"endmid"] = endMsgId;
    }
    
    TIOSocketPackage *socketPackage = [TIOSocketPackage.alloc init];
    socketPackage.gzip = 0;
    socketPackage.cmd = cmd;
    socketPackage.body = params;
    [TIOChat.shareSDK sendMessage:socketPackage];
}

- (void)fetchSessionId:(TIOSessionType)sessionType friendId:(NSString *)friendId completion:(TIOEnterConversationHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error, nil);
        
        return;
    }
    
    NSDictionary *params = nil;
    
    if (sessionType == TIOSessionTypeP2P) {
        params = @{
            @"touid" : friendId
        };
    } else if (sessionType == TIOSessionTypeTeam) {
        params = @{
            @"groupid" : friendId
        };
    } else {
        return;
    }
    
    [TIOHTTPSManager tio_GET:@"/chat/actChat" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIORecentSession *session = [TIORecentSession objectWithJSONObject:responseObject[@"data"][@"chat"]];
        session.sessionId = responseObject[@"data"][@"chat"][@"id"];
        completion(nil,session);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error, nil);
    }];
}

- (void)fetchSessionInfoWithSessionId:(NSString *)sessionId completion:(TIOEnterConversationHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error, nil);
        
        return;
    }
    
    self.requestSessionInfoBlock = completion;
    
//    NSDictionary *params = @{
//        @"chatlinkid" : sessionId,
//    };
//    [TIOHTTPSManager tio_GET:@"/chat/chatInfo" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        TIORecentSession *session = [TIORecentSession objectWithJSONObject:responseObject[@"data"]];
//        completion(nil,session);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        completion(error, nil);
//    }];
    
    NSDictionary *params = @{@"chatlinkid" : sessionId?:@"",};
    
    TIOSocketPackage *socketPackage = [TIOSocketPackage.alloc init];
    socketPackage.gzip = 0;
    socketPackage.cmd = 708;
    socketPackage.body = params;
    [TIOChat.shareSDK sendMessage:socketPackage];
}

- (void)topSession:(TIOSession *)session isTop:(BOOL)top completon:(nonnull TIOConversationError)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    
    if (session.sessionId.length == 0) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *params = @{
        @"chatlinkid" : session.sessionId,
        @"oper" : top? @"21" : @"22"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)deleteSession:(TIOSession *)session isClearMessage:(BOOL)clearMessage completion:(nonnull TIOConversationError)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    if (session.sessionId.length == 0) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *params = nil;
    
    if (clearMessage) {
        params = @{
            @"chatlinkid" : session.sessionId,
            @"oper" : @"1"
        };
    } else {
        params = @{
            @"chatlinkid" : session.sessionId,
            @"oper" : @"11"
        };
    }
    
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self deleteSessionId:session.sessionId];
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)deleteAllMessagesInSession:(TIOSession *)session complrtion:(TIOConversationError)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    if (session.sessionId.length == 0) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *params = @{
        @"chatlinkid" : session.sessionId,
        @"oper" : @"8"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)tipoffSession:(NSString *)sessionId complrtion:(nonnull TIOConversationOperHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error,@"");
        
        return;
    }
    
    if (sessionId.length == 0) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completion(error,@"");
        
        return;
    }
    
    NSDictionary *params = @{
        @"chatlinkid" : sessionId,
        @"oper" : @"99"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil, responseObject[@"data"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error,@"");
    }];
}

- (void)clearAllMessagesInSession:(TIOSession *)session completion:(TIOConversationError)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSString *sessionId = session.sessionId;
    NSString *oper = @"8";
    
    NSDictionary *params = @{
        @"chatlinkid" : sessionId,
        @"oper" : oper
    };
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)answerMessageNotificationForUid:(NSString *)uid orTeamid:(NSString *)teamid flag:(NSInteger)flag completion:(TIOConversationOperHandler)completion
{
    if (!uid.length && !teamid.length) {
        return;
    }
    NSDictionary *params = nil;
    
    if (uid) {
        // 个人免打扰
        params = @{
            @"touid" : uid,
            @"freeflag" : @(flag)
        };
    } else {
        // 群免打扰
        params = @{
            @"groupid" : teamid,
            @"freeflag" : @(flag)
        };
    }
    
    [TIOHTTPSManager tio_POST:@"/chat/msgfreeflag" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id data = responseObject[@"data"];
        completion(nil, data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error, @"");
    }];
}

- (void)addDelegate:(id<TIOConversationDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOConversationDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdP2PChatNtf] || data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdTeamChatNtf])
    {
        // 收到新消息：群聊 私聊
        
        TIOMessageSocket *message = [TIOMessageSocket objectWithJSONObject:data.body];

        if (message.actflag == 1)
        {
            TIOLog(@"群聊私聊消息：激活会话");
            /// 收到未激活的新消息
            /// 告诉上层新增一条会话
            TIORecentSession *recentSession = [TIORecentSession.alloc init];
            recentSession.lastMessage = message;
            recentSession.session = message.session;
            recentSession.sessionId = message.session.sessionId;
            recentSession.unReadCount = (message.messageType==TIOMessageTypeVideoChat||message.messageType==TIOMessageTypeAudioChat ||message.sendBy == TIOMessageSendBySystem)?0:1;
            recentSession.isUnread = (message.messageType==TIOMessageTypeVideoChat||message.messageType==TIOMessageTypeAudioChat)?NO: !message.isReaded;
            recentSession.atreadflag = 1;
            recentSession.isTop = NO;
            recentSession.viewFlag = 1;
            // 判断是不是at自己
            if (message.at) {
                NSArray *ats = [message.at componentsSeparatedByString:@","];
                
                NSString *currId = [TIOChat.shareSDK.loginManager userInfo].userId;
                if ([ats containsObject:currId] || [ats containsObject:@"all"]) {
                    recentSession.atreadflag = 2;
                }
            }
            
            [self->_multiDelegate didAddSession:recentSession];
            
            recentSession.bg_tableName = bg_tablename;
            //存到数据库
            [recentSession bg_saveAsync:^(BOOL isSuccess) {
                [self refreshUnReadTotalCount];
                if (isSuccess) {
                    TIOLog(@"【激活会话】数据库插入新会话");
                } else {
                    TIOLog(@"【激活会话】数据库插入新会话失败");
                }
            }];
        }
        else if (message.actflag == 2)
        {
            /// 收到已经激活的新消息
            /// 告诉上层更新对应的会话
            TIOLog(@"群聊私聊更新消息：开启查找本地数据库事务");
            
            [self findSession:message.session.sessionId complete:^(TIORecentSession * _Nullable recentSession)
            {
                if (recentSession) {
                    TIOLog(@"【已经激活的会话】本地已有会话");
                    // 更新数据消息部分内容及未读消息等数据
                    TIOSession *session = message.session;
                    session.avatar = recentSession.avatar.tio_resourceURLString;
                    session.name = recentSession.name;
                    recentSession.session = session;
                    
                    recentSession.lastMessage = message;
                    recentSession.chatuptime = message.msgTime;
                    
                    if (!message.isOutgoingMsg)
                    {
                        if ([TIOSessionActiveCenter.shareInstance isActive:message.session.sessionId]) {
                            // 焦点在此会话内
                            recentSession.unReadCount = 0; // 清零
                            recentSession.isUnread = NO; // 标记不是未读消息
                        } else {
                            if (message.messageType==TIOMessageTypeVideoChat||message.messageType==TIOMessageTypeAudioChat ||message.sendBy == TIOMessageSendBySystem) {
                                
                            } else {
                                recentSession.unReadCount += 1;
                            }
                            recentSession.isUnread = (message.messageType==TIOMessageTypeVideoChat||message.messageType==TIOMessageTypeAudioChat)?NO: !message.isReaded;
                            
                            // 判断是不是at自己
                            if (message.at) {
                                NSArray *ats = [message.at componentsSeparatedByString:@","];
                                
                                NSString *currId = [TIOChat.shareSDK.loginManager userInfo].userId;
                                if ([ats containsObject:currId] || [ats containsObject:@"all"]) {
                                    recentSession.atreadflag = 2;
                                }
                            }
                        }
                        
                    } else {
                        recentSession.toReadFlag = message.isReaded?1:2;
                        recentSession.unReadCount = 0;
                        recentSession.isUnread = NO; // 标记不是未读消息
                    }
                    // 更新数据库
                    TIOLog(@"群聊私聊更新消息：开始更新本地数据库");
                    
                    [recentSession bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        TIOLog(@"群聊私聊更新消息：更新本地数据库完成");
                        if (!message.isOutgoingMsg) {
                            [self->_multiDelegate didChangeUnreadCount:recentSession.unReadCount inSession:recentSession];
                        } else {
                            [self->_multiDelegate didChangeUnreadCount:0 inSession:recentSession];
                        }
                        // 原会话消息更新
                        [self->_multiDelegate didUpdateSession:recentSession];
                        [self refreshUnReadTotalCount];
                    }];
                } else {
                    // 因为异常，上次的会话没有存入本地数据库，导致server认为这是一条已经激活的会话消息
                    TIOLog(@"【已经激活的会话】本地没有会话");
                    
                    TIORecentSession *recentSession = [TIORecentSession.alloc init];
                    recentSession.lastMessage = message;
                    recentSession.session = message.session;
                    recentSession.sessionId = message.session.sessionId;
                    recentSession.unReadCount = (message.messageType==TIOMessageTypeVideoChat||message.messageType==TIOMessageTypeAudioChat ||message.sendBy == TIOMessageSendBySystem)?0:1;
                    recentSession.isUnread = (message.messageType==TIOMessageTypeVideoChat||message.messageType==TIOMessageTypeAudioChat)?NO: !message.isReaded;
                    recentSession.atreadflag = 1;
                    recentSession.isTop = NO;
                    // 判断是不是at自己
                    if (message.at) {
                        NSArray *ats = [message.at componentsSeparatedByString:@","];
                        
                        NSString *currId = [TIOChat.shareSDK.loginManager userInfo].userId;
                        if ([ats containsObject:currId] || [ats containsObject:@"all"]) {
                            recentSession.atreadflag = 2;
                        }
                    }
                    
                    [recentSession bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        if (isSuccess) {
                            TIOLog(@"【已经激活的会话】本地没有会话 已经保存成功");
                            [self->_multiDelegate didAddSession:recentSession];
                            [self refreshUnReadTotalCount];
                        }
                    }];
                }
            }];
        }
    }
    else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdOperNtf])
    {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        
        if (model.oper == 4)
        {
            /// 激活操作的通知 == 新增会话
            /// 区别：激活是一个空的会话，只有自己知道
            
            if (model.actflag == 1)
            {
                TIORecentSession *recentSession = [TIORecentSession objectWithJSONObject:model.chatItems];
                //存到数据库
                [recentSession bg_saveAsync:^(BOOL isSuccess) {
                    TIOLog(@"数据库新增自己激活的会话");
                    [self->_multiDelegate didAddSession:recentSession];
                }];
            }
        }
        else if (model.oper == 1 || model.oper == 5 || model.oper == 2)
        {
            /// 已经删除聊天会话 || 已经删除好友
            [self deleteSessionId:[NSString stringWithFormat:@"%zd",model.chatlinkid]];
        }
        else if (model.oper == 8)
        {
            /// 清空所有消息
            TIOSession *session = [TIOSession session:[NSString stringWithFormat:@"%zd",model.chatlinkid] toUId:@"" type:TIOSessionTypeP2P];
            /// 更新本地数据库
            [self findSession:session.sessionId complete:^(TIORecentSession * _Nullable recentSession) {
                if (recentSession) {
                    recentSession.msgresume = @"你清空了所有聊天消息";
                    recentSession.msgtype = TIOMessageTypeTip;
                    recentSession.toReadFlag = 1;   // 自己的消息被读标记
                    recentSession.atreadflag = 1;   // 更改被@的标记
                    recentSession.isUnread = NO;    // 更改未读标记
                    recentSession.unReadCount = 0;  // 清空未读消息数
                    [recentSession bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        if (isSuccess) {
                            TIOLog(@"本地消息清空成功");
                        } else {
                            TIOLog(@"本地消息清空失败");
                        }
                    }];
                }
            }];
            
            
            [self.multiDelegate didClearAllMessagesInSession:session];
        }
        else if (model.oper == 21)
        {
            /// 置顶
            [self findSession:[NSString stringWithFormat:@"%zd",model.chatlinkid] complete:^(TIORecentSession * _Nullable session) {
                session.isTop = YES;
                [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    if (isSuccess) {
                        [self->_multiDelegate didTopSession:session.session];
                    }
                }];
            }];
        }
        else if (model.oper == 22)
        {
            /// 取消置顶
            [self findSession:[NSString stringWithFormat:@"%zd",model.chatlinkid] complete:^(TIORecentSession * _Nullable session) {
                session.isTop = NO;
                [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    if (isSuccess) {
                        [self->_multiDelegate didCancelTopSession:session.session];
                    }
                }];
            }];
        }
        else if (model.oper == 6)
        {
            /// 自己被删除
        }
        else if (model.oper == 7)
        {
            /// 对方已读自己的消息
            [self findSession:[NSString stringWithFormat:@"%zd",model.chatlinkid] complete:^(TIORecentSession * _Nullable session) {
                if (session) {
                    if (session.toReadFlag != 1) {
                        session.toReadFlag = 1;
                        [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                            if (isSuccess) {
                                [self->_multiDelegate didUpdateSession:session];
                            }
                        }];
                    }
                }
            }];
        }
        else if (model.oper == 10)
        {
            TIORecentSession *recentSession = [TIORecentSession objectWithJSONObject:model.chatItems];
            /// 存到数据库
            [recentSession bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                TIOLog(@"数据库新增自己激活的会话");
                [self->_multiDelegate didUpdateSession:recentSession];
            }];
        }
        else if (model.oper == 25)
        {
            NSString *sessionId = [NSString stringWithFormat:@"%zd",model.chatlinkid];
            [self findSession:sessionId complete:^(TIORecentSession * _Nullable session) {
                if (session) {
                    session.msgfreeflag = [model.chatItems[@"msgfreeflag"] integerValue];
                    [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        if (isSuccess) {
                            TIOLog(@"【同步】会话消息免打扰状态 msgfreeflag=%zd",session.msgfreeflag);
                            [self.multiDelegate didUpdateSession:session];
                        } else {
                            TIOLog(@"【同步】会话消息免打扰状态异常");
                        }
                    }];
                }
            }];
        }
        
        [self refreshUnReadTotalCount];
    }
    else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdP2PHistoryMessagesResp])
    {   /// 私聊历史消息
        NSDictionary *body = data.body;
        NSString *sessionId = body[@"chatlinkid"];
        
        if ([sessionId isEqualToString:_session.sessionId])
        {
            NSArray *messages = [TIOMessageHistory objectArrayWithJSONArray:body[@"data"]];
            self.messageHistoryHandler(nil, messages);
        }
        
        [self refreshUnReadTotalCount];
    }
    else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdTeamHistoryMessagesResp])
    {   // 群聊历史消息
        NSDictionary *body = data.body;
        NSString *sessionId = body[@"chatlinkid"];
        
        if ([sessionId isEqualToString:_session.sessionId])
        {
            NSArray *messages = [TIOMessageHistory objectArrayWithJSONArray:body[@"data"]];
            self.messageHistoryHandler(nil, messages);
        }
        
        [self refreshUnReadTotalCount];
    }
    else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdGroupOperNtf])
    {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        if (model.oper == 2 || model.oper == 3 || model.oper == 4) {
            // 修改bizrole joinnum 群信息修改
            TIORecentSession *recentSession = [TIORecentSession objectWithJSONObject:model.chatItems];

            TIOLog(@"oper=4 查询数据库");
            // 存到数据库
            // 只更改后台给的储增量字段
            [self db_updateKeys:model.chatItems.allKeys values:model.chatItems.allValues sessionId:recentSession.sessionId callback:^(BOOL isSucess) {
                if (isSucess) {
                    [self findSession:recentSession.sessionId complete:^(TIORecentSession * _Nullable session) {
                        TIOLog(@"TioCmdGroupOperNtf oper = %zd didUpdateSession",model.oper);
                        [self->_multiDelegate didUpdateSession:session];
                    }];
                }
            }];
        }
        else if (model.oper == 10) {
            // 群聊内 删除一条消息 需要更新会话列表
            TIORecentSession *recentSession = [TIORecentSession objectWithJSONObject:model.chatItems];
            
            // 只更改后台给的储增量字段
            [self db_updateKeys:model.chatItems.allKeys values:model.chatItems.allValues sessionId:recentSession.sessionId callback:^(BOOL isSucess) {
                if (isSucess) {
                    [self findSession:recentSession.sessionId complete:^(TIORecentSession * _Nullable session) {
                        [self->_multiDelegate didUpdateSession:session];
                    }];
                }
            }];
        }
        else if (model.oper == 21) {
            // 更新群名
            [self findSession:[NSString stringWithFormat:@"%zd",model.chatlinkid] complete:^(TIORecentSession * _Nullable session) {
                if (session) {
                    session.name = model.bizdata;
                    [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        if (isSuccess) {
                            [self->_multiDelegate didUpdateSession:session];
                        }
                    }];
                }
            }];
        }
        else if (model.oper == 22) {
            // 更改群头像
            TIORecentSession *recentSession = [TIORecentSession objectWithJSONObject:model.chatItems];
            
            // 只更改后台给的储增量字段
            [self db_updateKeys:model.chatItems.allKeys values:model.chatItems.allValues sessionId:recentSession.sessionId callback:^(BOOL isSucess) {
                if (isSucess) {
                    [self findSession:recentSession.sessionId complete:^(TIORecentSession * _Nullable session) {
                        [self->_multiDelegate didUpdateSession:session];
                    }];
                }
            }];
        }
        else if (model.oper == 1 || model.oper == 5) {
            // 解散或者退群
            // 先检查本地有没有该记录
            NSString *sessionId = [NSString stringWithFormat:@"%zd",model.chatlinkid];
            [self findSession:sessionId complete:^(TIORecentSession * _Nullable session) {
                if (session) {
                    // 本地有这个会话 删除
                    [self deleteSessionId:sessionId];
                }
            }];
        } else if (model.oper == 11) {
            // 更新群角色,本地数据库
            NSString *sessionId = [NSString stringWithFormat:@"%zd",model.chatlinkid];
            [self findSession:sessionId complete:^(TIORecentSession * _Nullable session) {
                if (session) {
                    session.bizrole = [model.chatItems[@"bizrole"] integerValue];
                    [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        if (isSuccess) {
                            TIOLog(@"【同步】更新本地群聊角色成功");
                        } else {
                            TIOLog(@"【同步】更新本地群聊角色失败");
                        }
                    }];
                }
            }];
        }
        
        [self refreshUnReadTotalCount];
    }
    else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdSystemNtf])
    {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        if (model.type == TIOSystemNotificationTypeFriendUpdate) {
            TIORecentSession *recentSession = [TIORecentSession objectWithJSONObject:model.chatItems];
            // 只更改后台给的储增量字段
            [self db_updateKeys:model.chatItems.allKeys values:model.chatItems.allValues sessionId:recentSession.sessionId callback:^(BOOL isSucess) {
                if (isSucess) {
                    [self findSession:recentSession.sessionId complete:^(TIORecentSession * _Nullable session) {
                        TIOLog(@"好友信息变更 => %@",session.name);
                        [self->_multiDelegate didUpdateSession:session];
                    }];
                }
            }];
        }
        
        [self refreshUnReadTotalCount];
    }
    else if (data.cmd == 709) {
        // 会话详情
        if (self.requestSessionInfoBlock) {
            TIORecentSession *session = [TIORecentSession objectWithJSONObject:data.body[@"data"]];
            self.requestSessionInfoBlock(nil, session);
        }
    }
}

#pragma mark - Private

- (void)refreshUnReadTotalCount
{
    TIOLog(@"————————————————————开始查询未读的消息");
    [BGDB.shareManager addToThreadPool:^{
        [BGDB.shareManager queryWithTableName:bg_tablename where:@"where readflag=2" complete:^(NSArray * _Nullable array) {
            TIOLog(@"————————————————————未读消息查询结束");
            NSArray *models = [TIORecentSession objectArrayWithJSONArray:array];
            NSInteger total = 0;
            for (TIORecentSession *session in models) {
                total+=session.unReadCount;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                TIOLog(@"————————————————————UI更新未读消息");
                [self->_multiDelegate didChangeTotalUnreadCount:total];
            });
        }];
    }];
}

/// 更新数据库内的未读消息字段
/// @param count 最新数量
/// @param sessionId 会话ID
- (void)updateDBForUnreadcount:(NSInteger)count sessionId:(NSString *)sessionId completion:(void(^)(TIORecentSession *session))completion
{
//    NSInteger readflag = count>0 ? 2 : 1;
    
//    NSString *where = [NSString stringWithFormat:@"set notreadcount=%@,readflag=%@ where sessionId=%@",bg_sqlValue(@(count)),bg_sqlValue(@(readflag)),bg_sqlValue(@(sessionId.integerValue))];
    
    [self findSession:sessionId complete:^(TIORecentSession * _Nullable session) {
        if (session) {
            
            if (count > 0) {
                session.isUnread = YES;
                session.unReadCount = count;
            } else {
                session.isUnread = NO;
                session.unReadCount = 0;
                session.atreadflag = 1; // 表示
            }
            [session bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                if (isSuccess) {
                    TIOLog(@"更新消息的小红点完成");
                    // 刷新最新
                    [self refreshUnReadTotalCount];
                    completion(session);
                } else {
                    TIOLog(@"更新消息的小红点失败");
                }
            }];
        }
    }];
}

- (void)saveUpdateToDBForLastMessage:(TIOMessage *)message
{
    
}

/// 同步更新本地聊天会话列表
- (void)updateLocalFromRemote:(void (^)(BOOL, NSInteger))completion retryCount:(NSInteger)retryCount
{
    // 数据库名：用户id的数据库
    BGDB.shareManager.sqliteName = [TIOChat.shareSDK.loginManager.userInfo userId];
    [self.multiDelegate shouldUpdateLocalFromRemote];
    
    if (TIOLogEnable) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *datenow = [NSDate date];
        NSString *currentTimeString = [formatter stringFromDate:datenow];
        TIOLog(@"[同步]同步时间 %@",currentTimeString);
    }
    
    
    [TIOHTTPSManager tio_GET:@"/syn/chat" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSInteger all = [responseObject[@"data"][@"all"] integerValue];
        NSArray<TIORecentSession *> *arr = [TIORecentSession objectArrayWithJSONArray:responseObject[@"data"][@"chatlist"]];
        NSArray *dellist = [TIORecentSession objectArrayWithJSONArray:responseObject[@"data"][@"dellist"]];
        NSDictionary *synitem = responseObject[@"data"][@"synitem"];
        NSString *synid = synitem[@"id"];
        
        
        if (all == 1) {
            // 更新所有的
            TIOLog(@"[同步] 更新所有数据=>%@",responseObject[@"data"][@"chatlist"]);
            if (arr.count) {
                [self writeToDB:arr all:all completion:^(BOOL isSucess) {
                    if (isSucess) {
                        // 向服务器发送ack
                        [self updateLocalDataBaseFromServerAck:synid];
                        [self->_multiDelegate didUpdateLocalFromRemote:YES];
                        completion(YES, all);
                    } else {
                        if (retryCount>0) {
                            TIOLog(@"[同步] 开始补偿请求全部的同步数据");
                            [self updateLocalFromRemote:completion retryCount:retryCount-1];
                        } else {
                            [self->_multiDelegate didUpdateLocalFromRemote:NO];
                            completion(NO, all);
                        }
                    }
                }];
            } else {
                TIORecentSession *recentSession = [TIORecentSession.alloc init];
                recentSession.sessionId = @"-9999999";
                // 激活数据库
                // 存入一条空数据激活数据库
                // 事后要删除并建立索引
                [recentSession bg_saveAsync:^(BOOL isSuccess) {
                    NSString *sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS %@ on %@ (%@)",db_index_name,bg_tablename,bg_sqlKey(@"sessionId")];
                    [BGDB.shareManager bg_executeSql:sql tablename:bg_tablename class:TIORecentSession.class];
                    TIOLog(@"[同步] 空数据下建立索引");
                    if (isSuccess) {
                        [self deleteSessionId:@"-9999999"];
                    }
                    TIOLog(@"[同步] 服务器没有全部数据");
                    [self->_multiDelegate didUpdateLocalFromRemote:YES];
                    completion(YES, all);
                }];

                TIOLog(@"[同步] 服务器没有全部数据");
                [self->_multiDelegate didUpdateLocalFromRemote:YES];
                completion(YES, all);
            }
        } else {
            // 更新部分数据
            TIOLog(@"[同步] 更新部分数据=>%@",arr);
            if (arr.count) {    
                [arr enumerateObjectsUsingBlock:^(TIORecentSession *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([TIOSessionActiveCenter.shareInstance isActive:obj.sessionId]) {
                        obj.unReadCount = 0;
                    }
                }];
                [self writeToDB:arr all:all completion:^(BOOL isSucess) {
                    if (isSucess) {
                        // 向服务器发送ack
                        [self updateLocalDataBaseFromServerAck:synid];
                        [self->_multiDelegate didUpdateLocalFromRemote:YES];
                        completion(YES, all);
                    } else {
                        if (retryCount>0) {
                            TIOLog(@"[同步] 开始补偿同步更新的数据");
                            [self updateLocalFromRemote:completion retryCount:retryCount-1];
                        } else {
                            [self->_multiDelegate didUpdateLocalFromRemote:NO];
                            completion(NO, all);
                        }
                    }
                }];
            } else {
                TIOLog(@"[同步] 服务器没有需要更新的部分数据");
                [self->_multiDelegate didUpdateLocalFromRemote:NO];
            }
            
            if (dellist.count) {
                [self deleteSessionIds:[dellist valueForKeyPath:@"sessionId"] completion:^(BOOL isSuccess) {
                    if (isSuccess) {
                        TIOLog(@"[同步] 数据库删除部分数据成功");
                        [self updateLocalDataBaseFromServerAck:synid];
                        // 通知上层开发者，所有的会话的未读消息总数
                        [self refreshUnReadTotalCount];
                        // 通知上层开发者刷新数据
                        [self->_multiDelegate didUpdateLocalFromRemote:YES];
                        !completion?:completion(YES, all);
                    } else {
                        TIOLog(@"[同步] 数据库删除部分数据失败");
                        [self->_multiDelegate didUpdateLocalFromRemote:NO];
                        !completion?:completion(NO, all);
                    }
                }];
            } else {
                [self->_multiDelegate didUpdateLocalFromRemote:NO];
                TIOLog(@"[同步] 没有收到部分删除数据");
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"[同步] 同步接口异常 error:\n%@",error);
        [self->_multiDelegate didUpdateLocalFromRemote:NO];
        // 此处没有做重连 是因为，tio_post接口本身具备网络响应级别的重连，上面的success内是业务失败进行的重连刷新
        !completion?:completion(NO, 0);
    }];
}

- (void)clearLocal:(void (^)(BOOL))completion
{
    [BGDB.shareManager dropTable:bg_tablename complete:^(BOOL isSuccess) {
        if (isSuccess) {
            TIOLog(@"本地删会话列表除成功");
            [BGDB.shareManager closeDB];
            
            completion(YES);
        } else {
            [BGDB.shareManager closeDB];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *str in [fileManager subpathsAtPath:[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()]]) {
                if (str.length > 3 && [[str substringWithRange:NSMakeRange(str.length - 3, 3)] isEqualToString:@".db"]) {
                    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),str];
                    NSError *error = nil;
                    [fileManager removeItemAtPath:path error:&error];
                    if (error) {
                        TIOLog(@"删除数据库文件%@失败",path);
                        completion(NO);
                    } else {
                        TIOLog(@"删除数据库文件%@成功",path);
                        completion(YES);
                    }
                }
            }
        }
    }];
}

- (void)updateLocalDataBaseFromServerAck:(NSString *)synid
{
    [TIOHTTPSManager tio_GET:@"/syn/ack" parameters:@{@"synid":synid} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"[同步] 本地同步ack 成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"[同步] error:\n%@",error);
    }];
}

/// 向数据库写入同步数据
/// @param arr 同步的数据
/// @param completion 写入结果
- (void)writeToDB:(NSArray *)arr all:(NSInteger)all completion:(void(^)(BOOL isSucess))completion
{
    [TIORecentSession bg_saveOrUpdateArrayAsync:arr complete:^(BOOL isSuccess) {
        // 因为bg_saveOrUpateArray:是在子线程，所以需要回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                if ([TIORecentSession bg_isExistForTableName:bg_tablename]) {
                    if (all==1) {
                        TIOLog(@"[同步] 全部数据写入成功");
                        
                        NSString *sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS %@ on %@ (%@)",db_index_name,bg_tablename,bg_sqlKey(@"sessionId")];
                        [BGDB.shareManager bg_executeSql:sql tablename:bg_tablename class:TIORecentSession.class];
                        TIOLog(@"[同步] 建立索引");
                    } else {
                        TIOLog(@"[同步] 更新数据写入成功");
                    }
                    
                    // 通知上层开发者,数据库更新后有新消息
                    if (arr.count) {
                        
                        NSInteger total = 0;
                        for (TIORecentSession *recenetSession in arr) {
                            total += recenetSession.unReadCount;
                        }

                        // 通知上层开发者，所有的会话的未读消息总数
                        [self.multiDelegate didChangeTotalUnreadCount:total];
                        // 通知上层开发者刷新数据
                    }
                    
                    completion(YES);
                } else {
                    TIOLog(@"[同步] 数据库异常，表建立失败");
                    completion(NO);
                }
            } else {
                if (all==1) {
                    TIOLog(@"[同步] 数据库保存全部数据失败");
                } else {
                    TIOLog(@"[同步] 数据库保存更新数据失败");
                }
                completion(NO);
            }
        });
        
    }];
}

- (void)findSession:(NSString *)sessionId complete:(void(^_Nullable)(TIORecentSession * _Nullable session))complete
{
    [BGDB.shareManager addToThreadPool:^{
        TIOLog(@"INDEXED BY %@ WHERE %@=%@",db_index_name,bg_sqlKey(@"sessionId"),bg_sqlValue(sessionId));
        [BGDB.shareManager queryWithTableName:bg_tablename where:[NSString stringWithFormat:@"WHERE %@=%@",bg_sqlKey(@"sessionId"),bg_sqlValue(sessionId)] complete:^(NSArray * _Nullable array) {
            NSArray *models = [TIORecentSession objectArrayWithJSONArray:array];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (models.count) {
                    complete(models.firstObject);
                } else {
                    complete(nil);
                }
            });
        }];
    }];
}

- (void)deleteSessionId:(NSString *)sessionId
{
    [TIORecentSession bg_deleteAsync:bg_tablename where:[NSString stringWithFormat:@"where %@=%zd",bg_sqlKey(@"sessionId"),sessionId.integerValue] complete:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                TIOLog(@"已删除会话");
                [self.multiDelegate didDeleteSession:sessionId];
                [self refreshUnReadTotalCount];
            }
        });
    }];
}

- (void)deleteSessionIds:(NSArray *)sessionIds completion:(void(^)(BOOL isSuccess))completion
{
    if (!sessionIds.count) {
        return;
    }

    __block NSString *whereSql = [NSString stringWithFormat:@"WHERE %@ IN (",bg_sqlKey(@"sessionId")];
    // BG_sessionId IN (1,2,3)
    [sessionIds enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == sessionIds.count-1) {
            whereSql = [whereSql stringByAppendingFormat:@"%zd)",obj.integerValue];
        } else {
            whereSql = [whereSql stringByAppendingFormat:@"%zd,",obj.integerValue];
        }
    }];
    
    [TIORecentSession bg_deleteAsync:bg_tablename where:whereSql complete:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(isSuccess);
        });
    }];
}


/// 过滤更新过程中，整型属性在没有值时默认的0 覆盖对应数据库字段value
/// @param old_object 数据库中原数据
/// @param n_object 新 需要用来更新的数据
- (void)ignoreZeroValue:(TIORecentSession *)old_object model:(TIORecentSession *)n_object
{
    NSArray *zeroValueKeys = @[@"atnotreadcount",@"notreadcount",@"bizrole",@"notreadstartmsgid",@"atnotreadstartmsgid",@"sysflag",@"toreadflag",@"viewflag",@"bizid",@"chatlinkid",@"readflag",@"topflag",@"linkflag",@"chatmode",@"lastmsgid",@"linkid"];
    
    
    unsigned int outCount, i;

    objc_property_t *properties = class_copyPropertyList(old_object.class, &outCount);

    for (i = 0; i<outCount; i++)
    {

        objc_property_t property = properties[i];

        const char* char_f =property_getName(property);

        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        BOOL flag = NO;
        
        for (NSString *key in zeroValueKeys) {
            if ([propertyName isEqualToString:key]) {
                
                
                flag = YES;
                
                NSInteger propertyValue = [[old_object valueForKey:(NSString *)propertyName] integerValue];
                NSInteger nValue = [[n_object valueForKey:(NSString *)propertyName] integerValue];
                
                if (nValue==0) {
                    [n_object setValue:@(propertyValue) forKey:(NSString *)propertyName];
                }
                
                break;
            }
        }
        
        if (!flag) {
            if ([n_object valueForKey:(NSString *)propertyName] == NULL) {
                id value = [old_object valueForKey:(NSString *)propertyName];
                [n_object setValue:value forKey:(NSString *)propertyName];
            }
        }
    }

    free(properties);
}

- (void)db_updateKeysValues:(NSDictionary *)dict sessionId:(NSString *)sessionId callback:(void(^)(BOOL isSucess))callback
{
    NSArray *keys = dict.allKeys;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSString *key in keys) {
        [values addObject:dict[key]];
    }
    [self db_updateKeys:keys values:values sessionId:sessionId callback:callback];
}

- (void)db_updateKeys:(NSArray *)keys values:(NSArray *)values sessionId:(NSString *)sessionId callback:(void(^)(BOOL isSucess))callback
{
    if (!keys || keys.count == 0) {
        return;
    }
    
    
    [BGDB.shareManager addToThreadPool:^{
        // 获取表的所有列名，除掉忽略的字段
        NSArray *colums = [BGDB.shareManager getAllColumsInTable:bg_tablename ignoredkeys:TIORecentSession.bg_ignoreKeys cls:TIORecentSession.class];
        
        __block NSString *where = @"";
        __block BOOL first = YES; // 忽律字典中没有
        
        [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([colums containsObject:obj]) {
                if (first) {
                    first = NO;
                    
                    if ([self isIntValueAtKey:keys[idx]]) {
                        NSInteger value = [values[idx] integerValue];
                        where = [where stringByAppendingFormat:@"%@=%ld",keys[idx], value];
                    } else {
                        where = [where stringByAppendingFormat:@"%@='%@'", keys[idx], values[idx]];
                    }
                } else {
                    if ([self isIntValueAtKey:keys[idx]]) {
                        NSInteger value = [values[idx] integerValue];
                        where = [where stringByAppendingFormat:@",%@=%ld",keys[idx], value];
                    } else {
                        where = [where stringByAppendingFormat:@",%@='%@'", keys[idx], values[idx]];
                    }
                }
            }
        }];
        
        where = [where stringByAppendingFormat:@" where sessionId=%@",sessionId];
        
        NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET %@",bg_tablename,where];
        NSNumber *result = [BGDB.shareManager bg_executeSql:sql tablename:bg_tablename class:TIORecentSession.class];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(result.boolValue);
        });
    }];
}

- (BOOL)isIntValueAtKey:(NSString *)key
{
    NSArray *intValueKeys = @[@"joinnum",@"atnotreadcount",@"notreadcount",@"bizrole",@"notreadstartmsgid",@"atnotreadstartmsgid",@"sysflag",@"toreadflag",@"viewflag",@"bizid",@"chatlinkid",@"readflag",@"topflag",@"linkflag",@"chatmode",@"lastmsgid",@"linkid"];
    
    __block BOOL flag = NO;
    [intValueKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([key isEqualToString:obj]) {
            flag = YES;
            *stop = YES;
        }
    }];
    
    return flag;
}

@end
