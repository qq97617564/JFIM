//
//  TIOChatChatManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/18.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOSocketPackage;
@class TIOChat;
@class TIOMessage;
@class TIOMessageReceipt;
@class TIOSession;

/**
--------------------------------------------------------------
`TIOChatDelegate`聊天回调
--------------------------------------------------------------
*/
@protocol TIOChatDelegate <NSObject>
@optional
/// 消息已经发送 (暂不可用)
/// @param message 已经发送的消息
/// @param error 发送失败
- (void)didSendMessage:(TIOMessage *)message completion:(NSError * _Nullable)error;

/// 文件、图片、视频上传回调
/// @param message 上传的消息
/// @param error 上传失败
- (void)didUploadFile:(TIOMessage *)message completion:(NSError * _Nullable)error;

/// 收到消息的回调
/// @param messages 收到的消息
- (void)onRecvMessages:(NSArray<TIOMessage *> *)messages;

/// 消息删除
- (void)didDeleteMessage:(TIOMessage *)message;

/// 消息撤回
- (void)didRevokeMessage:(TIOMessage *)message;

/// 好友已读所有消息
- (void)didReadedAllMessage;

@end


/**
--------------------------------------------------------------
`TIOChatManager`聊天管理类
--------------------------------------------------------------
*/
@interface TIOChatManager : NSObject

/// 发送消息
/// 构建TIOMessage对象，text , toUid , messageType不能为空，当为
- (void)sendMessage:(TIOMessage *)message completionHandler:(nonnull void (^)(NSError * _Nullable error))completionHandler;


/// 撤回消息
/// @param message 要撤回的消息
/// @param session 所在会话
- (void)revokeMessage:(TIOMessage *)message inSession:(TIOSession *)session completionHandler:(nonnull void (^)(NSError * _Nullable error))completionHandler;

///  删除消息
/// @param message 要删除的消息
/// @param session 所在会话
- (void)deleteMessage:(TIOMessage *)message inSession:(TIOSession *)session completionHandler:(nonnull void (^)(NSError * _Nullable error))completionHandler;

/// 转发消息
/// @param messageIds 要转发的消息ID的数组
/// @param uIds 要发送给的用户ID的数组
/// @param teamIds 要转发给的的群的ID数组
/// @param session 所在会话
- (void)repostMessages:(NSArray *)messageIds toUsers:(NSArray * _Nullable)uIds teams:(NSArray * _Nullable)teamIds inSession:(TIOSession *)session completionHandler:(nonnull void (^)(NSError * _Nullable error))completionHandler;

/// 举报
- (void)tipoffMessage:(TIOMessage *)message inSession:(TIOSession *)session completionHandler:(nonnull void (^)(NSError * _Nullable error))completionHandler DEPRECATED_MSG_ATTRIBUTE("该方法已废弃，请使用[TIOChat.shareSDK report:completion:]");

- (void)handler:(TIOSocketPackage *)data;

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOChatDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOChatDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
