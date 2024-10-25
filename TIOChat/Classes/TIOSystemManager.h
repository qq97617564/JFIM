//
//  TIOSystemManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TIOSystemNotification;
@class TIOSocketPackage;

NS_ASSUME_NONNULL_BEGIN

@protocol TIOSystemDelegate <NSObject>
@optional
/// 收到系统通知
/// @param notification 通知信息
- (void)onRecieveSystemNotification:(TIOSystemNotification *)notification;

/// 监听socket链接状态
/// @param connected YES：已连接  NO：已断开
- (void)onServerConnectChanged:(BOOL)connected;

/// 自定义通知
/// @param object 自定义对象, 需要自己解析处理
- (void)onRecieveCustomNotification:(TIOSocketPackage *)object;

@end

@interface TIOSystemManager : NSObject



/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOSystemDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOSystemDelegate>)delegate;

- (void)handler:(TIOSocketPackage *)data;

- (void)handlerServerConnected:(BOOL)connected;

@end

NS_ASSUME_NONNULL_END
