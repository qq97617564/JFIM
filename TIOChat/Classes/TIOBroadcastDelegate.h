//
//  TIOBroadcastDelegate.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/23.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 多播委托：用于实现 （1:N）一对多代理通知
/// eg. 收到的消息可以“同时”通知给所有注册的代理对象（或页面）
@interface TIOBroadcastDelegate : NSObject

/// 添加广播的委托对象
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
/// 移除广播的委托对象
- (void)removeDelegate:(id)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;

@end

NS_ASSUME_NONNULL_END
