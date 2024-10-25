//
//  TIOChatChatManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/18.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOChatManager.h"
#import "TIOSocketPackage.h"
#import "TIOBroadcastDelegate.h"
#import "TIOChat.h"
#import "TIOMessage.h"
#import "TIOCmdConfiguator.h"
#import "TIOMessageSocket.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOMacros.h"
#import "TIOUploadManager.h"
#import "TIOHTTPSManager.h"

@interface TIOChatManager ()
@property (nonatomic, strong) TIOBroadcastDelegate<TIOChatDelegate> *multiDelegate;
@end

@implementation TIOChatManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOChatDelegate> *)[TIOBroadcastDelegate.alloc init];
    }
    return self;
}

- (void)sendMessage:(TIOMessage *)message completionHandler:(nonnull void (^)(NSError * _Nullable))completionHandler
{
    // TODO: 待完善
    NSError *error = nil;
    
    if (message.text.length == 0 && message.messageType == TIOMessageTypeText) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2000 userInfo:@{NSLocalizedDescriptionKey: @"发送的消息内容为空"}];
        completionHandler(error);
        return;
    }
    
    if (!TIOChat.shareSDK.isConnected) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2000 userInfo:@{NSLocalizedDescriptionKey: @"当前网络异常"}];
        completionHandler(error);
        return;
    }
    
//    if (message.session.toUId.length == 0) {
//        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"收信人的ID为空"}];
//        completionHandler(error);
//        return;
//    }
    
    NSInteger cmd = 0;
//    NSString *toKey = nil;
    
    if (message.session.sessionType == TIOSessionTypeP2P) {
        cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdP2PChatReq];
//        toKey = @"to";
    } else if (message.session.sessionType == TIOSessionTypeTeam) {
        cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdTeamChatReq];
//        toKey = @"g";
    } else {
//        toKey = @"";
    }
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = cmd;
    data.gzip = 0;
    
    NSDictionary *body = nil;
    if (message.messageType == TIOMessageTypeText) {
        if (message.at) {
            body = @{
                @"chatlinkid" : message.session.sessionId,
                @"c" : message.text,
                @"at" : message.at
            };
        } else {
            body = @{
                @"chatlinkid" : message.session.sessionId,
                @"c" : message.text,
            };
        }
        data.body = body;
    } else if (message.messageType == TIOMessageTypeImage) {
        if (message.attachmentObjects.firstObject.localURL)
        {
            [self sendFile:message];
        }
        else
        {
            [self sendImage:message];
        }
    } else if (message.messageType == TIOMessageTypeVideo) {
        [self sendFile:message];
    } else if (message.messageType == TIOMessageTypeAudio) {
        [self sendFile:message];
    } else if (message.messageType == TIOMessageTypeLocation) {
        
    } else if (message.messageType == TIOMessageTypeFile) {
        [self sendFile:message];
    } else if (message.messageType == TIOMessageTypeRed) {
        
    } else if (message.messageType == TIOMessageTypeCard) {
        body = @{
            @"chatlinkid" : message.session.sessionId,
            @"cardid" : message.cardid,
            @"cardtype" : @(message.cardType)
        };
        data.body = body;
    }
    
    if (body) {
        [TIOChat.shareSDK sendMessage:data];
    }
}

- (void)revokeMessage:(TIOMessage *)message inSession:(nonnull TIOSession *)session completionHandler:(nonnull void (^)(NSError * _Nullable))completionHandler
{
    NSError *error = nil;
    
    if (message.messageId.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"消息ID为空"}];
        completionHandler(error);
        return;
    }
    
    if (session.sessionId.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completionHandler(error);
        return;
    }
    
    NSDictionary *params = @{
        @"chatlinkid" : session.sessionId,
        @"mids" : message.messageId,
        @"oper" : @"9"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/msgOper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completionHandler(error);
    }];
}

- (void)deleteMessage:(TIOMessage *)message inSession:(nonnull TIOSession *)session completionHandler:(nonnull void (^)(NSError * _Nullable))completionHandler
{
    NSError *error = nil;
    
    if (message.messageId.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"消息ID为空"}];
        completionHandler(error);
        return;
    }
    
    if (session.sessionId.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completionHandler(error);
        return;
    }
    
    NSDictionary *params = @{
        @"chatlinkid" : session.sessionId,
        @"mids" : message.messageId,
        @"oper" : @"1"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/msgOper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completionHandler(error);
    }];
}

- (void)repostMessages:(NSArray *)messageIds toUsers:(NSArray *)uIds teams:(NSArray *)teamIds inSession:(TIOSession *)session completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (messageIds) {
        NSMutableString *uidsString = [NSMutableString.alloc init];
        [messageIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == messageIds.count-1) {
                [uidsString appendFormat:@"%@",obj];
            } else {
                [uidsString appendFormat:@"%@,",obj];
            }
        }];
        
        params[@"mids"] = uidsString;
    }
    
    if (uIds) {
        NSMutableString *uidsString = [NSMutableString.alloc init];
        [uIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == uIds.count-1) {
                [uidsString appendFormat:@"%@",obj];
            } else {
                [uidsString appendFormat:@"%@,",obj];
            }
        }];
        
        params[@"uids"] = uidsString;
    }
    
    if (teamIds) {
        NSMutableString *uidsString = [NSMutableString.alloc init];
        [teamIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == teamIds.count-1) {
                [uidsString appendFormat:@"%@",obj];
            } else {
                [uidsString appendFormat:@"%@,",obj];
            }
        }];
        
        params[@"groupids"] = uidsString;
    }
    
    params[@"chatlinkid"] = session.sessionId;
    
    [TIOHTTPSManager tio_POST:@"/chat/msgForward" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completionHandler(error);
    }];
}

- (void)tipoffMessage:(TIOMessage *)message inSession:(TIOSession *)session completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    NSError *error = nil;
    
    if (message.messageId.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"消息ID为空"}];
        completionHandler(error);
        return;
    }
    
    if (session.sessionId.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey: @"会话ID为空"}];
        completionHandler(error);
        return;
    }
    
    NSDictionary *params = @{
        @"chatlinkid" : session.sessionId,
        @"mids" : message.messageId,
        @"oper" : @"99"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/msgOper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completionHandler(error);
    }];
}

- (void)addDelegate:(id<TIOChatDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOChatDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - Private

- (void)sendImage:(TIOMessage *)message
{
    [TIOUploadManager uploadFileWithData:message.attachmentObjects.firstObject.localData.copy
                               sessionId:message.session.sessionId.copy
                             messageType:message.messageType
                                fileName:message.attachmentObjects.firstObject.filename
                                     ext:message.attachmentObjects.firstObject.ext?:@"jpg"
                                progress:nil
                              completion:^(NSArray * _Nonnull urls) {
        [self.multiDelegate didUploadFile:message completion:nil];
    } failure:^(NSError * _Nonnull error) {
        TIOLog(@"error:%@",error);
        [self.multiDelegate didUploadFile:message completion:error];
    }];
}

- (void)sendFile:(TIOMessage *)message
{
    [TIOUploadManager uploadFileWithFileURL:message.attachmentObjects.firstObject.localURL.copy
                                  sessionId:message.session.sessionId.copy
                                messageType:message.messageType
                                   progress:nil
                                 completion:^(NSArray * _Nonnull urls) {
        [self.multiDelegate didUploadFile:message completion:nil];
    } failure:^(NSError * _Nonnull error) {
        TIOLog(@"error:%@",error);
        [self.multiDelegate didUploadFile:message completion:error];
    }];
}

#pragma mark - 接收

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdP2PChatNtf]) {
        
        TIOMessageSocket *message = [TIOMessageSocket objectWithJSONObject:data.body];
        message.resp = @{
            @"cmd" : @(data.cmd),
            @"body" : data.body
        };
        TIOSession *CuS = TIOChat.shareSDK.conversationManager.session;
        if ([CuS.sessionId isEqualToString:message.session.sessionId]) {
            [_multiDelegate onRecvMessages:@[message]];
        }
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdTeamChatNtf]) {
        
        TIOMessageSocket *message = [TIOMessageSocket objectWithJSONObject:data.body];
        message.resp = @{
            @"cmd" : @(data.cmd),
            @"body" : data.body
        };
        
        // 注意：群聊时  会话ID没有 群ID当会话ID使用 但是获取群历史聊天记录有
        TIOSession *CuS = TIOChat.shareSDK.conversationManager.session;
        TIOSession *mS = message.session;
        TIOLog(@"当前会话的toUId %@",CuS.toUId);
        TIOLog(@"新消息会话的toUId %@",mS.toUId);
        if ([CuS.sessionId isEqualToString:mS.sessionId]) {
            [_multiDelegate onRecvMessages:@[message]];
        }
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdOperNtf]) {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        if (model.oper == 9) {
            // 私聊 撤回
            TIOMessage *msg = [TIOMessage.alloc init];
            msg.messageId = model.operbizdata;
            [_multiDelegate didRevokeMessage:msg];
        } else if (model.oper == 10) {
            // 私聊 删除
            TIOMessage *msg = [TIOMessage.alloc init];
            msg.messageId = model.operbizdata;
            [_multiDelegate didDeleteMessage:msg];
        } else if (model.oper == 7) {
            // 已读
            [_multiDelegate didReadedAllMessage];
        }
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdGroupOperNtf]) {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        if (model.oper == 9) {
            // 群聊内 - 撤回
            TIOMessage *msg = [TIOMessage.alloc init];
            msg.messageId = model.bizdata;
            [_multiDelegate didRevokeMessage:msg];
        } else if (model.oper == 10) {
            // 群聊内 - 删除
            TIOMessage *msg = [TIOMessage.alloc init];
            msg.messageId = model.bizdata;
            [_multiDelegate didDeleteMessage:msg];
        }
    } 
}

@end
