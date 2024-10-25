//
//  TIOSessionViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/27.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOKitBaseViewController.h"
#import "IMInputViewProtocol.h"
#import "IMMessageCellProtocol.h"
#import "IMSessionConfig.h"

#import "TIOChatKit.h"
#import "IMKitAudioCenter.h"

#import "TIOMessage+RichTip.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOSessionViewController : TIOKitBaseViewController <IMKitInputViewActionDelegate, IMKitInputViewConfig, IMMessageCellProtocol, IMKitSessionInteractorDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) id<IMKitInputView> sessionInputView;

@property (strong, nonatomic) TIOSession *session;

@property (nonatomic, strong) TIOMessage *messageForMenu;

/// 会话页主标题 可以更改文字的大小，颜色等属性，文案内容请使用 - (NSString *)sessionTitle 接口
@property (nonatomic, strong, readonly)    UILabel *titleLabel;

/// 会话页子标题 可以更改文字的大小，颜色等属性，文案内容请使用 - (NSString *)sessionSubTitle 接口
@property (nonatomic, strong, readonly)    UILabel *subTitleLabel;

- (instancetype)initWithSession:(TIOSession *)session;

#pragma mark - 监听APP生命周期

/// APP 已经进入后台
- (void)appDidEnterBack;
/// APP 将要挂起
- (void)appWillResignActive;
/// APP 将要恢复前台活跃状态
- (void)appWillEnterForeground;

#pragma mark - 界面

/// 聊天背景图
@property (strong, nonatomic) UIImage *sessionBackgroundImage;
/// 聊天背景色
@property (strong, nonatomic) UIColor *sessionBackgroundColor;

/// 会话页导航栏标题
- (NSString *)sessionTitle;

/// 会话页导航栏子标题
- (NSString *)sessionSubTitle;

/// 刷新导航栏标题
/// @param title 新标题
- (void)refreshSessionTitle:(NSString *)title;

/// 刷新导航子栏标题
/// @param title 新的子标题
- (void)refreshSessionSubTitle:(NSString *)title;

/// 刷新消息
- (void)refreshMessages;
- (void)loadNewMessgaes;

/// 结束下拉刷新 获取历史消息的刷新
- (void)endRefresh;

- (void)markRead;

- (id<IMSessionConfig, IMKitInputViewConfig>)sessionConfig;
// 配置
- (void)setupConfigurator;

- (NSArray *)menusItems:(TIOMessage *)message;

- (void)refreshBackgroundImage:(UIImage *)image;

#pragma mark - 消息接口

/// 发送消息
/// @param message 消息
- (void)sendMessage:(id)message;

/// 异步发送消息
/// @param message 消息
/// @param completion 完成回调
- (void)sendMessage:(id)message completion:(void(^)(NSError * err))completion;

#pragma mark - 操作接口

/// 追加多条消息
/// 直接加在消息列表末尾
/// @param messages 消息集合
- (void)uiAddMessages:(NSArray *)messages;

/// 插入消息
- (void)uiInsertMessages:(NSArray *)messages callback:(void(^ _Nullable )(id data))callback;

- (void)uiClearAllMessages;

/// 删除一条消息
/// @return 被删除的 MessageModel
/// @param message 被删除的消息
- (IMKitMessageModel *)uiDeleteMessage:(TIOMessage *)message;

/// 更新消息
/// @param message 要更新的消息
- (IMKitMessageModel *)uiUpdateMessage:(TIOMessage *)message;

#pragma mark - 排版

- (void)scrollToBottom:(BOOL)animated;

@end

@interface TIOSessionViewController(Interactor)

- (void)setInteractor:(id<IMKitSessionInteractor>) interactor;

@end

NS_ASSUME_NONNULL_END
