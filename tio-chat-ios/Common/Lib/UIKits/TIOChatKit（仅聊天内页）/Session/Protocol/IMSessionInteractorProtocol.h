//
//  IMSessionInteractorProtocol.h
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import <Foundation/Foundation.h>
#import "IMKitMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOMessage;

@protocol IMKitSessionInteractorDelegate <NSObject>

- (void)didFetchMessageData;

- (void)didRefreshMessageData;

- (void)didPullUpMessageData;

/// 当开启关闭新消息自动滑动到底部功能
/// @param messagesCount 底部新消息
- (void)didRecievedBottomNewMessage:(NSInteger)messagesCount;

/// 已经阅读底部消息
- (void)didReadBottomMessage;

@end

@protocol IMKitSessionInteractor <NSObject>

#pragma mark - 网络接口
- (void)sendMessage:(TIOMessage *)message;

- (void)sendMessage:(TIOMessage *)message completion:(void(^)(NSError * error))completion;

- (void)sendMessageReceipt:(NSArray *)messages;

#pragma mark - 界面操作接口

- (void)insertMessages:(NSArray *)messages callback:(void(^ _Nullable)(id data))callback;

- (void)addMessages:(NSArray *)messages;

- (IMKitMessageModel *)deleteMessage:(TIOMessage *)message;

- (IMKitMessageModel *)updateMessage:(TIOMessage *)message;

- (void)clearAllMessages;

#pragma mark - 数据接口
- (NSArray *)items;

- (void)markRead;

- (IMKitMessageModel *)findMessageModel:(TIOMessage *)message;

- (void)resetMessages:(void (^)(NSError *error))handler;

- (void)loadMessages:(void (^)(NSArray *messages, NSError *error))handler;

- (void)loadNewMessages:(void (^)(NSArray * _Nonnull, NSError * _Nonnull))handler;

- (NSInteger)findMessageIndex:(TIOMessage *)message;

#pragma mark - 排版接口
- (void)resetLayout;

- (void)changeLayout:(CGFloat)inputHeight;

- (void)cleanCache;

- (void)pullUp;

- (void)scrollToBottom:(BOOL)animated; // 滚动到最下面一行 最新消息处

/// 默认0 1:已经滑到底 2:未滑到底
@property (nonatomic,   assign) NSInteger scrollToBottomStatus;

#pragma mark - 页面状态同步接口
- (void)onViewWillAppear;

- (void)onViewDidDisappear;

/// 程序进入后台
- (void)onApplicationDidEnterBack;

/// 程序回到活跃状态
- (void)onApplicationDidBecomeActive;

@end

NS_ASSUME_NONNULL_END
