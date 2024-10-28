//
//  TIOConversationManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOSession;
@class TIOMessage;
@class TIOSocketPackage;

/**
--------------------------------------------------------------
`TIORecentSession`最近会话
--------------------------------------------------------------
*/
@interface TIORecentSession : NSObject
@property (strong,  nonatomic) TIOSession *session;
@property (strong,  nonatomic) TIOMessage *lastMessage;
/// 会话ID ，也可以从session.sessionId
@property (copy,    nonatomic) NSString *sessionId;
///  聊天会话的有效链接状态
@property (assign,  nonatomic) TIOSessionLinkStatus linkStatus;
/// 最后一条消息系统标识：1：是系统消息；2：是正常消息
@property (assign,  nonatomic) NSInteger sysFlag;
/// 是否置顶
@property (assign,  nonatomic) BOOL isTop;
/// 是否是未读消息
@property (assign,  nonatomic) BOOL isUnread;
/// 发送给对方的消息 的未读标识（私聊专用）：1:已读；2：未读
@property (assign,  nonatomic) NSInteger toReadFlag;
/// 是否显示标识：1：是；2：否
@property (assign,  nonatomic) NSInteger viewFlag;
/// 自己的用户ID
@property (assign,  nonatomic) NSInteger uid;
/// 自己未读的消息条数
@property (assign,  nonatomic) NSInteger unReadCount;
/// 聊天好友的uid或者群的groupid
@property (copy,    nonatomic) NSString *toUId;
/// 好友备注
@property (copy,    nonatomic) NSString *remarkname;
/// 群聊人数
@property (copy,    nonatomic) NSString *joinnum;
///1=官方， 2=正常
@property (assign,  nonatomic) NSInteger officialflag;
/// 为2时:at自己
@property (assign,  nonatomic) NSInteger atreadflag;
/// 角色 用户在群聊会话内的角色状态： 成员｜管理员｜群主
@property (assign,  nonatomic) NSInteger bizrole;
/// 免打扰 1:开启免打扰  2:未开启免打扰
@property (assign,  nonatomic) NSInteger msgfreeflag;

@end

/**
--------------------------------------------------------------
`TIOConversationDelegate`会话回调
--------------------------------------------------------------
*/
@protocol TIOConversationDelegate <NSObject>
@optional

/// 新增会话
- (void)didAddSession:(TIORecentSession *)recentSession;
/// 更新会话
- (void)didUpdateSession:(TIORecentSession *)recentSession;
/// 删除会话 注意触发条件：
/// 1、当本机执行deleteSession删除会话时
/// 2、当异地设备执行deleteSession删除会话时
- (void)didDeleteSession:(NSString *)session;

/// 即将开始同步远端数据到本地数据库
/// updateLocalFromRemote触发
/// 监听此回调可以实现微信一样的：显示 “接收中......”
- (void)shouldUpdateLocalFromRemote;
/// 已经从远端服务器同步本地数据：在下面几种情况下会触发此代理回调
/// 1、网络断开重连
/// 2、APP回到前台
/// 3、登录成功
/// 4、手动调用 updateLocalFromRemote
/// 监听此回调可以实现微信一样的：“接收中......” 消失
/// @param isUpdate 更新后是否有新消息的变动
- (void)didUpdateLocalFromRemote:(BOOL)isUpdate;

/// 已清除某个会话内的所有聊天记录
- (void)didClearAllMessagesInSession:(TIOSession *)session;
/// 已经将某个会话置顶
- (void)didTopSession:(TIOSession *)session;
/// 已经将某个会话取消置顶
- (void)didCancelTopSession:(TIOSession *)session;

/// 好友已读自己的消息
/// @param session 会话
- (void)friendDidReadMyMessageInSession:(TIOSession *)session;

/// 所有会话的总未读消息数改变
/// @param total 最新的总未读消息数
- (void)didChangeTotalUnreadCount:(NSInteger)total;
/// 某个会话的未读消息发生变更
/// @param total 最新的未读消息数
- (void)didChangeUnreadCount:(NSInteger)total inSession:(TIORecentSession *)session;

@end

/// 获取最近会话列表回调
typedef void (^TIOFetchRecentSessionsBlock)(NSArray<TIORecentSession *> * __nullable recentSessions , NSError * __nullable error);

/// 获取历史消息列表回调
typedef void (^TIOFetchMessageHistoryHandler)(NSError * __nullable error,NSArray<TIOMessage *> * __nullable messages);

typedef void (^TIOEnterConversationHandler)(NSError * __nullable error, TIORecentSession * __nullable session);

typedef void (^TIOConversationError)(NSError * __nullable error);
typedef void (^TIOConversationOperHandler)(NSError * __nullable error, id data);

/**
--------------------------------------------------------------
`TIOConversationManager`会话管理
--------------------------------------------------------------
*/
@interface TIOConversationManager : NSObject

/// 当前的会话
@property (nonatomic, strong, readonly) TIOSession *session;

/// 进入私聊会话
/// Note：执行此方法的同时外部聊天列表中的该会话不会被标记未读消息数量
/// @param session 会话
/// @param uid 用户ID
- (void)enterConversationWithSession:(TIOSession *)session uid:(NSString *)uid completion:(nonnull TIOEnterConversationHandler)completion;

/// 离开私聊会话
- (void)leaveConversationWithSessionId:(NSString *)sessionId completion:(TIOConversationError)completion;


/// 从服务端获取所有的最近会话, 同时会更新本地DB
/// 注意：调用该方法，会覆盖已有的全部的本地会话列表；从服务端获取的是全部的列表，数据量会比较大
- (void)fetchServerSessions:(TIOFetchRecentSessionsBlock)completion;

/// 同步：从本地获取所有最近会话
- (nullable NSArray<TIORecentSession *> *)allRecentSessions;
/// 异步获取本地所有的最近会话
- (void)fetchAllRecentSessions:(TIOFetchRecentSessionsBlock)completion;

/// 从本地查找某一个会话
/// @param sessionId 会话ID
- (void)findSession:(NSString *)sessionId complete:(void(^_Nullable)(TIORecentSession * _Nullable session))complete;

/// 从服务端更新本地DB，做增量改变
/// 监听 - (void)didUpdateLocalDatabaseFromRemote;          allRecentSessions获取最新数据
/// @param retryCount 更新失败后的自动刷新次数 
/// @param completion retryCount仍未成功，会通过completion返回给调用处
- (void)updateLocalFromRemote:(void(^ _Nullable)(BOOL isSuccess, NSInteger all))completion retryCount:(NSInteger)retryCount;

/// 手动清空本地数据库的会话列表
- (void)clearLocal:(void(^)(BOOL isSuccess))completion;

/// 获取历史消息
/// @param session 会话
/// @param startMsgId 开始的消息ID
/// @param completion 回调
- (void)fetchMessagesHistory:(TIOSession *)session startMsgId:(NSString * __nullable)startMsgId endMsgId:(NSString * __nullable)endMsgId completion:(TIOFetchMessageHistoryHandler)completion;

/// 获取会话ID
/// @param sessionType 会话类型
/// @param friendId 私聊时参数为好友UID 群聊时参数为群ID
/// @param completion 回调
- (void)fetchSessionId:(TIOSessionType)sessionType friendId:(NSString *)friendId completion:(TIOEnterConversationHandler)completion;

- (void)fetchSessionInfoWithSessionId:(NSString *)sessionId completion:(TIOEnterConversationHandler)completion;

/// 将会话置顶
/// @param session 需要置顶的会话
/// @param completion 结果
/// @param top YES 置顶 NO 取消置顶
- (void)topSession:(TIOSession *)session isTop:(BOOL)top completon:(TIOConversationError)completion;

/// 删除会话
/// @param session 要删除的会话
/// @param clearMessage 删除同时清空会聊天消息
/// @param completion 网络回调
- (void)deleteSession:(TIOSession *)session isClearMessage:(BOOL)clearMessage completion:(TIOConversationError)completion;

/// 删除会话内的所有消息
/// @param session 目标会话
/// @param completion 网络回调
- (void)deleteAllMessagesInSession:(TIOSession *)session complrtion:(TIOConversationError)completion;

/// 投诉会话
/// @param sessionId 会话ID
- (void)tipoffSession:(NSString *)sessionId complrtion:(TIOConversationOperHandler)completion DEPRECATED_MSG_ATTRIBUTE("该方法已废弃，请使用[TIOChat.shareSDK report:completion:]");

/// 清空聊天记录
/// @param session 所在会话
- (void)clearAllMessagesInSession:(TIOSession *)session completion:(TIOConversationError)completion;

/// 接收消息提醒 / 消息免打扰
/// @param uid 接收/拒绝 来自uid的消息
/// @param teamid 接收/拒绝 来自teamid 的消息
/// @param flag 1:开启免打扰，2：不开启
- (void)answerMessageNotificationForUid:(NSString *__nullable)uid orTeamid:(NSString *__nullable)teamid flag:(NSInteger)flag completion:(TIOConversationOperHandler)completion;

- (void)handler:(TIOSocketPackage *)data;

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOConversationDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOConversationDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
