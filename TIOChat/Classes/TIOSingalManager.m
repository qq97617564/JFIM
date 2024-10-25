//
//  TIORTCManager.m
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOSingalManager.h"
#import "TIOBroadcastDelegate.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOChat.h"
#import "TIOSocketPackage.h"
#import "TIOCmdConfiguator.h"
#import "TIOHTTPSManager.h"
#import "TIOMacros.h"

@interface TIOSingalManager ()<TIOSystemDelegate>
@property (nonatomic, strong) TIOBroadcastDelegate<TIORTCDelegate> *multiDelegate;
@property (nonatomic, assign) NSInteger callState; // 0:没有呼叫 1:呼出 2:呼入
@end

@implementation TIOSingalManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIORTCDelegate> *)[TIOBroadcastDelegate.alloc init];
        [TIOChat.shareSDK.systemManager addDelegate:self];
    }
    
    return self;
}

- (void)start
{
    [TIOHTTPSManager tio_GET:@"/im/turnserver" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"turnServer:%@",responseObject);
        
        NSArray *ices = responseObject[@"data"];
        NSMutableArray *iceArray = [NSMutableArray arrayWithCapacity:ices.count];
        [ices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *credential = obj[@"credential"];
            NSString *urls = obj[@"urls"];
            NSString *username = obj[@"username"];
            RTCIceServer *iceserver = [RTCIceServer.alloc initWithURLStrings:@[urls] username:username credential:credential];
            [iceArray addObject:iceserver];
        }];
        
        [self->_multiDelegate onIceServer:iceArray error:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"turnserver error : %@",error);
        [self->_multiDelegate onIceServer:@[] error:error];
    }];
}

/// 800
- (void)caller_callUser:(NSString *)userId callType:(TIORTCType)callType
{
    NSDictionary *body = @{
        @"touid" : userId,
        @"type" : @(callType)
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall01Req];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

/// 802
- (void)reciver_replyCall:(NSString *)callId result:(TIORTCReplyResult)result resaon:(NSString *)reason
{
    NSDictionary *body = nil;
    
    if (result == TIORTCReplyResultCancel) {
        body = @{
            @"result" : @(result),
            @"id" : callId
        };
        
        self.callState = 0;
    } else if (result == TIORTCReplyResultAgree) {
        body = @{
            @"result" : @(result),
            @"id" : callId,
            @"reason" : reason?:@""
        };
        
        self.callState = 2;
    } else {
        body = @{
            @"result" : @(result),
            @"id" : callId,
            @"reason" : reason?:@""
        };
        
        self.callState = 0;
    }
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall03ReplyReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)caller_offerSDP:(NSDictionary *)sdp toCallId:(NSString *)callId
{
    NSDictionary *body = @{
        @"sdp" : sdp,
        @"id" : callId
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall05OfferSdpReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)caller_offerCandidate:(NSDictionary *)candidate toCallId:(NSString *)callId
{
    NSDictionary *body = @{
        @"candidate" : candidate,
        @"id" : callId
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall09OfferIceReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)reciver_offerSDP:(NSDictionary *)sdp toCallId:(NSString *)callId
{
    NSDictionary *body = @{
        @"sdp" : sdp,
        @"id" : callId
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall07AnswerSdpReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)reciever_offerCandidate:(NSDictionary *)candidate toCallId:(NSString *)callId
{
    NSDictionary *body = @{
        @"candidate" : candidate,
        @"id" : callId
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall11AnswerIceReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)hangup:(NSString *)callId type:(TIOCallHangupType)hangupType
{
    NSDictionary *body = @{
        @"hanguptype" : @(hangupType),
        @"id" : callId
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall13EndReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)cancelCall:(NSString *)callId
{
    NSDictionary *body = @{
    };
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall02_1CancelReq];
    data.gzip = 0;
    data.body = body;
    [TIOChat.shareSDK sendMessage:data];
}

- (void)addDelegate:(id<TIORTCDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIORTCDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall02Ntf]) {
        // B 收到A的呼叫通知
        TIOWxCallItem *model = [TIOWxCallItem objectWithJSONObject:data.body];
        [_multiDelegate onReciver_recieveCall:model];
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall04ReplyNtf]) {
        // A 收到B的呼叫应答
        TIOWxCallItemReply *model = [TIOWxCallItemReply objectWithJSONObject:data.body];
        [_multiDelegate onCaller_recieveAnswerCall:model];
        if (model.result == TIORTCReplyResultAgree) {
            self.callState = 1;
        } else {
            self.callState = 0;
        }
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall06OfferSdpNtf]) {
        // B收到A的SDP
        TIOWxCallItemAnswerSDP *model = [TIOWxCallItemAnswerSDP objectWithJSONObject:data.body];
        [_multiDelegate onReciver_recieveSDP:model];
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall08AnswerSdpNtf]) {
        // A收到B的应答SDP
        TIOWxCallItemAnswerSDP *model = [TIOWxCallItemAnswerSDP objectWithJSONObject:data.body];
        [_multiDelegate onCaller_recieveAnswerSDP:model];
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall10OfferIceNtf]) {
        // B 收到A的ICE
        TIOWxCallItemAnswerCandidate *model = [TIOWxCallItemAnswerCandidate objectWithJSONObject:data.body];
        [_multiDelegate onReciever_recieveCandidate:model];
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall12AnswerIceNtf]) {
        // A 收到B的应答ICE
        TIOWxCallItemAnswerCandidate *model = [TIOWxCallItemAnswerCandidate objectWithJSONObject:data.body];
        [_multiDelegate onCaller_recieveAnswerCandidate:model];
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall14EndNtf]) {
        // 通话结束
        TIOWxCallItem *model = [TIOWxCallItem objectWithJSONObject:data.body];
        [_multiDelegate onHangup:model];
        self.callState = 0;
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall02_2CancelNtf]) {
        TIOWxCallItem *model = [TIOWxCallItem objectWithJSONObject:data.body];
        if (![model.fromuid isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
            [_multiDelegate onCancelCall:model];
        }
        self.callState = 0;
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCallRespNtf]) {
        // 888
        TIOWxCallItem *callItem = [TIOWxCallItem objectWithJSONObject:data.body];
        
        /*
         是否由当前设备接听
         */
        if (callItem.todevice != TIORTCDeviceTypeIOS)
        {   // 不是当前设备接听
            
            /*
             是否是自己呼叫自己
             */
            if ([callItem.fromuid isEqualToString:callItem.touid])
            {   // 自己呼叫自己
                
                /*
                 是否是当前设备发起呼叫
                 */
                if (callItem.fromdevice == TIORTCDeviceTypeIOS)
                {   // 是当前设备呼叫
                    // 当前设备呼叫  +  不是当前设备接听  =>   接通
                    // 直接return 不做处理
                    
                    TIOLog(@"自己当前设备呼叫自己的另一台设备");
                    return;
                }
            }
            
            /*
             处理 : 通知上层销毁呼叫界面/接听界面
             */
            [_multiDelegate onHangup:callItem];
        } else {
            if (callItem.status == TIORTCStatusSingnalConnected) {
                [_multiDelegate onReciver_SingnalConnected];
            }
        }
    }
}

- (void)onServerConnectChanged:(BOOL)connected
{
    [_multiDelegate onNetworkChange:connected];
}

@end
