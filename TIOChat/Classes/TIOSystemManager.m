//
//  TIOSystemManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOSystemManager.h"
#import "TIOBroadcastDelegate.h"
#import "TIOSocketPackage.h"
#import "TIOSystemNotification.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOCmdConfiguator.h"
#import "TIOChat.h"

@interface TIOSystemManager ()
@property (nonatomic, strong) TIOBroadcastDelegate<TIOSystemDelegate> *multiDelegate;
@end
@implementation TIOSystemManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOSystemDelegate> *)[TIOBroadcastDelegate.alloc init];
    }
    return self;
}

- (void)addDelegate:(id<TIOSystemDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOSystemDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdSystemNtf]) {
        // 好友申请
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        model.resp = data.body;
        [_multiDelegate onRecieveSystemNotification:model];
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdErrorNtf]) {
        // 异常通知
        TIOSystemNotification *message = [TIOSystemNotification objectWithJSONObject:data.body];
        message.type = TIOSystemNotificationTypeError;
        message.resp = data.body;
        [_multiDelegate onRecieveSystemNotification:message];
    } else if (data.cmd == 16) {
        // 群聊发送过快
        TIOSystemNotification *message = [TIOSystemNotification objectWithJSONObject:data.body];
        message.t = [[NSDate date] timeIntervalSince1970] * 1000;
        message.mid = 10000+arc4random()%10*1000+arc4random()%10*100+arc4random()%10*10+arc4random()%10;
        message.resp = data.body;
        [_multiDelegate onRecieveSystemNotification:message];
    } else {
        // 自定义的消息
        [_multiDelegate onRecieveCustomNotification:data];
    }
}

- (void)handlerServerConnected:(BOOL)connected
{
    [_multiDelegate onServerConnectChanged:connected];
}


@end
