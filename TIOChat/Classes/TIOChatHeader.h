//
//  Header.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/18.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOCmdConfiguator;

@class TIOConfig;
@class TIOSocketPackage;
@class TIOSDKOption;
@class TIOChatManager;
@class TIOFriendManager;
@class TIOTeamManager;
@class TIOSystemManager;
@class TIOConversationManager;
@class TIOLoginManager;
@class TIOVideoChatManager;
@class TIOSingalManager;
@class TIOAudioManager;
@class TIOWalletManager;
@class GFWalletManager;

typedef NS_ENUM(NSUInteger, TIOSocketOfflineType) {
    TIOSocketOfflineByServer,   ///<  服务器掉线，默认为0
    TIOSocketOfflineByUser,     ///<  用户主动cut
    TIOSocketOfflineByNet,      ///< 断网原因
};

/// 举报选项
@interface TIOReportRequest : NSObject
/// 举报类型
@property (assign,  nonatomic) TIOReportType type;
/// 举报用户时，必填
@property (copy,    nonatomic) NSString *uid;
/// 举报群或群消息时，必填
@property (copy,    nonatomic) NSString *teamid;
/// 举报群聊消息时，必填
@property (copy,    nonatomic) NSString *messageid;
/// 举报原因，选填
@property (copy,    nonatomic) NSString *reason;

@end

/*
 监听长连接的连接状态
 请选择性使用
 TIOChat已经具备自动重连，不要在此进行额外的重连操作，比如调用lunch方法。
 */
@protocol TIOChatLinkDelegate <NSObject>
@optional
/// IM连接已建立
- (void)tio_linkConnected;

/// 连接断开
/// 重连期间失败的断开也会触发此方法
/// @param offlineType 断开原因
- (void)tio_linkDisconnected:(TIOSocketOfflineType)offlineType;
@end


@interface TIOChat : NSObject

+ (instancetype)shareSDK;
+ (void)setLogEnable:(BOOL)enable;
/// 务必调用此接口：网络配置
+ (void)requestNetConfig:(void(^)(NSDictionary *result))completion;

/// SDK 版本号
- (NSString *)SDKVersion;

- (void)registerWithOption:(TIOSDKOption *)option;

/// 启动服务
- (void)lunch;
/// 结束服务
- (void)finish;
/// 是否在运行
- (BOOL)isConnected;

/// 绑定推送的registrationID
- (void)bindRegistrationID:(NSString *)registrationID;

/// 上传错误日志
/// @param url 错误日志文件地址
- (void)uploadLog:(NSString *)url callback:(void(^)(NSError * __nullable error))callback;

#pragma mark - 下面两个方法暂不可用
/// 更新APNS Token
/// @param token APNS Token
- (void)updateApnsToken:(NSData *)token;
/// 更新PushKit的Token
/// @param token PushKit Token
- (void)updatePushKitToken:(NSData *)token;

/// 是否允许账号在Android、iOS、Web、H5等多端同时在线
/// 默认YES，允许多端同时登录；为NO时，仅允账号在当前该iOS设备登录
@property (assign, nonatomic) BOOL allowOnlineOnMultiTerminal;
/// 好友管理
@property (strong, nonatomic) GFWalletManager *gfHttpManager;
/// 好友管理
@property (strong, nonatomic) TIOFriendManager *friendManager;
/// 聊天管理
@property (strong, nonatomic) TIOChatManager *chatManager;
/// 群组管理
@property (strong, nonatomic) TIOTeamManager *teamManager;
/// 系统消息管理
@property (strong, nonatomic) TIOSystemManager *systemManager;
/// 会话管理
@property (strong, nonatomic) TIOConversationManager *conversationManager;
/// 登录注册管理
@property (strong, nonatomic) TIOLoginManager *loginManager;
/// 命令码管理
@property (strong, nonatomic, readonly) TIOCmdConfiguator *cmdManager;
@property (strong, nonatomic) TIOSingalManager *singalManager;
@property (strong, nonatomic) TIOVideoChatManager *videoChatManager;
/// 语音消息管理（非语音实时通话）
@property (strong, nonatomic) TIOAudioManager *audioManager;
/// 钱包红包管理
@property (strong, nonatomic) TIOWalletManager *walletManager;

@property (copy,    nonatomic) NSString *imei;

/// 一定要在 registerWithOption: 初始化之前配置
/// 注意：如果不配置IM服务器的地址以及端口，默认从服务器获取
@property (strong, nonatomic) TIOConfig *config;

/// 举报
/// @param request 请求参数：举报类型、举报人/群/消息的id、举报原因
/// @param completion 操作回调
- (void)report:(TIOReportRequest *)request completion:(void(^)(NSError * __nullable error, id result))completion;

/// 可以构造TIOSocketPackage发送自定义消息
/// @param message 自定义消息，只需
- (void)sendMessage:(TIOSocketPackage *)message;

/// 添加连接状态的监听
- (void)addDelegate:(id<TIOChatLinkDelegate>)delegate;

/// 移除连接状态的监听
- (void)removeDelegate:(id<TIOChatLinkDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
