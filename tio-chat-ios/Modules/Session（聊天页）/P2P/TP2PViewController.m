//
//  TP2PViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TP2PViewController.h"
#import "TSessionConfig.h"
#import "TMessageMaker.h"
#import "TTeamViewController.h"
#import "TCallViewController.h"
#import "TCallAudioViewController.h"
#import "TDownloadFileListViewController.h"
/// common
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"
#import "TIOChatKit.h"
#import "UIImage+T_gzip.h"
#import "CTMediator+ModuleActions.h"
#import "TSessionPhotoPreview.h"
#import "TPhotoPicker.h"
#import "TShareFriendCardListViewController.h"
#import "TShareTeamCardListViewController.h"
#import "TAlertController.h"
#import "TCardAlert.h"
#import "TDownloadTool.h"
#import "TInputAlertController.h"
#import "WKWebViewController.h"
#import "WalletKit.h"
#import "TBottomMessageHUD.h"
#import "UIImage+TColor.h"
#import "WaterMarkTool.h"
#import "UIImage+TColor.h"
#import "WaterMarkTool.h"
/// pods
#import <YYModel/YYModel.h>

@interface TP2PViewController () <TIOChatDelegate, TIOSystemDelegate, TIOAudioDelegate,TIOChatLinkDelegate, TIOConversationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) id<IMSessionConfig> config;
@property (nonatomic, strong) TIORecentSession *sessionInfo;
@property (nonatomic, strong) TIOUser   *friendInfo;
@property (nonatomic, strong) TSessionPhotoPreview *photoPreview;
@property (nonatomic, strong) TPhotoPicker  *photoPicker;

@property (nonatomic, assign) NSInteger activeStatus;

@end

@implementation TP2PViewController

- (void)dealloc
{
    [TIOChat.shareSDK.chatManager removeDelegate:self];
    [TIOChat.shareSDK.systemManager removeDelegate:self];
    [TIOChat.shareSDK.audioManager removeDelegate:self];
    [TIOChat.shareSDK.conversationManager removeDelegate:self];
    [TIOChat.shareSDK removeDelegate:self];
}

- (instancetype)initWithSession:(TIOSession *)session
{
    self = [super initWithSession:session];
    
    if (self) {
        _config = [TSessionConfig.alloc initWithSession:session];
        self.title = session.name;
        self.photoPreview = [TSessionPhotoPreview.alloc initWithSession:session onVC:self];
        self.photoPicker = [TPhotoPicker.alloc initWithSession:session controller:self];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.activeStatus = 1;

    
    // 如果会话是无效的：非好友、被踢出群等不在会话内
    if (self.session.linkStatus == TIOSessionLinkStatusValid) {
        [self setupNavRightItem];
    }
    
    // 配置聊天 需要在此之前将自己的用户ID放进session里，统一在这里处理，没有放到外面的入口处
    self.session.ownerId = [TIOChat.shareSDK.loginManager.userInfo userId];

    [self setupConfigurator];
    [self.view bringSubviewToFront:self.navigationBar];
    
    [self enter];
    [self fetchHistoryMessages];
    
    
    // 注册SDK监听
    [TIOChat.shareSDK.chatManager addDelegate:self];
    [TIOChat.shareSDK.systemManager addDelegate:self];
    [TIOChat.shareSDK.audioManager addDelegate:self];
    [TIOChat.shareSDK.conversationManager addDelegate:self];
    [TIOChat.shareSDK addDelegate:self];
    
    // 监听APP生命周期
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startSideBack];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TIOChat.shareSDK.audioManager stopPlay];
}

- (void)setupNavRightItem
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithImage:[[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(toMore:)];
}

- (void)toMore:(id)sender
{
//    [self jumpToUserhome:self.friendInfo.userId userInfo:self.friendInfo];
    NSDictionary *params = @{
        @"uid" : self.session.toUId?:@"",
        @"sessionId" : self.session.sessionId?:@""
    };
    [self.navigationController pushViewController:[CTMediator.sharedInstance T_P2pSessionSettingController:[NSMutableDictionary dictionaryWithDictionary:params]] animated:YES];
}

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 进入、离开会话

- (void)enter
{
    [TIOChat.shareSDK.conversationManager enterConversationWithSession:self.session
                                                                   uid:TIOChat.shareSDK.loginManager.userInfo.userId
                                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable session) {
        if (error) {
            DDLogError(@"进入会话失败:%@",error);
        } else {
            DDLogInfo(@"成功进入会话");
        }
    }];
    
    [TIOChat.shareSDK.friendManager fetchUserInfo:self.session.toUId completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
        self.friendInfo = user;
    }];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        // pop
        [self leave];
    }
}

- (void)leave
{
    [TIOChat.shareSDK.conversationManager leaveConversationWithSessionId:self.session.sessionId
                                                              completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        }
    }];
}

#pragma mark -监听

/// APP 已经进入后台
- (void)appDidEnterBack
{
    // 一定要执行super的此方法
    [super appDidEnterBack];
    
    self.activeStatus = 2;
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        [self leave];
    }
}

/// APP 将要恢复前台
- (void)appWillEnterForeground
{
    // 一定要执行super的此方法
//    [super appWillEnterForeground];
    
    self.activeStatus = 1;
}

/// 长链接重连
- (void)tio_linkConnected
{
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
        [self enter];
        // 获取后台期间未收到的消息
        [self loadNewMessgaes];
    }
}

#pragma mark - 获取历史消息

- (void)fetchHistoryMessages
{
    CBWeakSelf
    [TIOChat.shareSDK.conversationManager fetchMessagesHistory:self.session startMsgId:nil endMsgId:nil completion:^(NSError * _Nullable error, NSArray<TIOMessage *> * _Nullable messages) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            if (messages.count) {
                CBWeakSelf
                [self uiInsertMessages:messages callback:^(id  _Nonnull data) {
                    CBStrongSelfElseReturn
                    BOOL flag = [data boolValue];
                    if (!flag) {
                        // 全部不显示 继续获取历史数据
                        [self fetchHistoryMessages];
                    }
                }];
            }
        }
    }];
}

#pragma mark - overwrite IMKit

- (id<IMSessionConfig>)sessionConfig
{
    return self.config;
}

#pragma mark - IMKitSessionInteractorDelegate

- (void)didRecievedBottomNewMessage:(NSInteger)messagesCount
{
    DDLogVerbose(@"底部有新的消息数 %ld", (long)messagesCount);
    if (![TBottomMessageHUD HUDForView:self.view]) {
        TBottomMessageHUD *HUD = [TBottomMessageHUD showOnView:self.view callback:^(TBottomMessageHUD * _Nonnull HUD) {
            [self scrollToBottom:YES];
        }];
        HUD.centerX = self.view.middleX;
        HUD.bottom = self.view.bottom - safeBottomHeight - 57 - 10;
    }
}

/// 清空聊天消息
- (void)didClearAllMessagesInSession:(TIOSession *)session
{
    if ([session.sessionId isEqualToString:self.session.sessionId]) {
        [self uiClearAllMessages];
    }
}

- (void)didReadBottomMessage
{
    [TBottomMessageHUD hideForView:self.view];
}

- (NSArray *)menusItems:(TIOMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    
    BOOL deleteFlag = NO;   // 删除
    BOOL revokeFlag = NO;   // 撤回
    BOOL repostFlag = NO;   // 转发
    BOOL multiFlag = NO;    // 多选
    BOOL downloadFlag = NO; // 下载
    BOOL tipoffFlag = YES;  // 举报
    
    if (defaultItems)
    {
        [items addObjectsFromArray:defaultItems];
    }
    
    if (message.messageType != TIOMessageTypeTip) {
        deleteFlag = YES;
        repostFlag = YES;
        multiFlag = YES;
    }
    // 名片、音频通话、视频通话、语音消息不能转发
    if (message.messageType == TIOMessageTypeCard || message.messageType == TIOMessageTypeAudioChat || message.messageType == TIOMessageTypeVideoChat || message.messageType == TIOMessageTypeAudio || message.messageType == TIOMessageTypeRed) {
        repostFlag = NO;
    }
    
    if (message.messageType != TIOMessageTypeTip && message.isOutgoingMsg) {
        revokeFlag = YES;
    }
    
    if (message.messageType == TIOMessageTypeFile) {
        downloadFlag = YES;
    }
    
    if (message.messageType == TIOMessageTypeTip || message.messageType == TIOMessageTypeAudioChat || message.messageType == TIOMessageTypeVideoChat) {
        tipoffFlag = NO;
    }
    
    if (message.messageType == TIOMessageTypeRed) {
        repostFlag = NO;
        multiFlag = NO;
        revokeFlag = NO;
        tipoffFlag = NO;
    }
    
    if (repostFlag) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发"
                                                    action:@selector(reportMsg:)]];
    }
//
    if (deleteFlag) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                    action:@selector(deleteMsg:)]];
    }
//
//    if (multiFlag) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"多选"
//                                                    action:@selector(multiSelectMsgs:)]];
//    }
//
    if (revokeFlag) {
        [items addObject:[UIMenuItem.alloc initWithTitle:@"撤回"
                                                  action:@selector(revokeMsg:)]];
    }
    
    if (downloadFlag) {
        [items addObject:[UIMenuItem.alloc initWithTitle:@"下载"
                                                  action:@selector(downloadMsg:)]];
    }
    
    if (tipoffFlag) {
        [items addObject:[UIMenuItem.alloc initWithTitle:@"举报"
                                                  action:@selector(tipoffMsg:)]];
    }
//
//    [items addObject:[UIMenuItem.alloc initWithTitle:@"引用" action:@selector(revokeMsg:)]];
//    [items addObject:[UIMenuItem.alloc initWithTitle:@"编辑" action:@selector(revokeMsg:)]];
//    [items addObject:[UIMenuItem.alloc initWithTitle:@"收藏" action:@selector(revokeMsg:)]];
    
    return items;
    
}

- (void)deleteMsg:(id)sender
{
    TIOMessage *msg = [self messageForMenu];
    
    [TIOChat.shareSDK.chatManager deleteMessage:msg inSession:self.session completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
        }
    }];
}

- (void)revokeMsg:(id)sender
{
    TIOMessage *msg = [self messageForMenu];
    
    [TIOChat.shareSDK.chatManager revokeMessage:msg inSession:self.session completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
        }
    }];
}

- (void)reportMsg:(id)sender
{
    TIOMessage *msg = [self messageForMenu];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @(2);
    UIViewController *vc = [CTMediator.sharedInstance T_CardToSessionViewController:params];
    CBWeakSelf
    vc.t_callback = ^(UIViewController * _Nonnull viewController, id  _Nullable data) {
        CBStrongSelfElseReturn
        
        TIOSession *session = data;
        
        NSArray *toUids = nil;
        NSArray *toTeamIds = nil;
        
        if (session.sessionType == TIOSessionTypeP2P)
        {
            toUids = @[session.toUId];
        } else {
            toTeamIds = @[session.toUId];
        }
        
        [TIOChat.shareSDK.chatManager repostMessages:@[msg.messageId] toUsers:toUids teams:toTeamIds inSession:self.session completionHandler:^(NSError * _Nullable error) {
            if (error) {
                [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
            } else {
                [MBProgressHUD showInfo:@"已转发" toView:self.view];
            }
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)multiSelectMsgs:(id)sender
{
    
}

- (void)downloadMsg:(id)sender
{
    TIOMessage *msg = [self messageForMenu];
    TIOMessageAttachmnet *file = msg.attachmentObjects.firstObject;
    
    [MBProgressHUD showProgress:0 toView:self.view];
    
    [TDownloadTool t_download:file.url name:@"" ext:file.ext progress:^(CGFloat p) {
//        progressView.progress = p;
    } completion:^(NSError * _Nullable error, NSString * _Nullable filePath) {
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            DDLogVerbose(@"存储地址：%@",filePath);
        }
    }];
}

- (void)tipoffMsg:(id)sender
{
    TIOMessage *msg = [self messageForMenu];
    [TIOChat.shareSDK.chatManager tipoffMessage:msg inSession:self.session completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
        } else {
            [MBProgressHUD showInfo:@"举报成功，等待后台审核" toView:self.view];
        }
    }];
}

- (void)recordBeginTouch
{
    // 调用SDK开始录音API
    DDLogVerbose(@"调用SDK开始录音API");
    [TIOChat.shareSDK.audioManager recordWithDuration:60];
}

- (void)recordFinishInButton
{
    // 调用SDK结束录音API
    DDLogVerbose(@"调用SDK结束录音API");
    [TIOChat.shareSDK.audioManager stopRecord];
}

- (void)recordDragToOut {}

- (void)recordDragBackToButton {}

- (void)recordFinishOutButton
{
    // 调用SDK取消录音API
    NSLog(@"调用SDK取消录音API");
    [TIOChat.shareSDK.audioManager cancelRecord];
}

#pragma mark - 标题

- (NSString *)sessionTitle {
    return self.title;
}

- (void)onSendText:(NSString *)text atUsers:(NSArray *)atUsers
{
    void(^block)(NSString *) = ^(NSString *c){
        c = [TMessageMaker htmlEncode:c];
        
        TIOMessage *message = [TMessageMaker messageForTextWithText:c session:self.session];
        
        DDLogDebug(@"发送消息\n");
        DDLogDebug(@"会话ID:%@\n",self.session.sessionId);
        DDLogDebug(@"消息内容:%@\n\n",text);
        
        [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
            if (error) {
                // 1、以弱提示提示
                [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
                // 2、以提示的消息类型展示

            }
        }];
    };
    
    block(text);
}

- (void)onRecvMessages:(NSArray<TIOMessage *> *)messages
{
    NSLog(@"onRecvMessages:");
    [self uiAddMessages:messages];
}

- (void)didSendMessage:(nonnull TIOMessage *)message completion:(NSError * _Nullable)error
{
}

- (void)didUploadFile:(TIOMessage *)message completion:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error)
    {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
    }
}

#pragma mark - TIOChatDelegate

- (void)onRecieveSystemNotification:(TIOSystemNotification *)notification
{
    if (notification.type == TIOSystemNotificationTypeFriendUpdate) {
        // 好友信息变更，更新昵称
        NSString *name = notification.chatItems[@"name"];
        [self refreshSessionTitle:name];
    } else {
        if (notification.code >1000 ) {
            TIOMessage *message = [TIOMessage.alloc init];
            message.toUId = self.session.toUId;
            message.timestamp = notification.t;
            message.text = notification.msg;
            message.messageId = [NSString stringWithFormat:@"%zd",notification.mid];
            message.messageType = TIOMessageTypeTip;
            if (notification.code == 20003) {
                message.t_linkString = @"申请添加为好友";
                message.t_color = [UIColor colorWithHex:0x4C94FF];
                message.t_selctorName = @"add";
            }
            [self uiAddMessages:@[message]];
        }
    }
}

- (void)didDeleteMessage:(TIOMessage *)message
{
    [self uiDeleteMessage:message];
}

- (void)didRevokeMessage:(TIOMessage *)message
{
    [self uiDeleteMessage:message];
}

- (void)didReadedAllMessage
{
    // 好友已读消息
    [self markRead];
}

#pragma mark - TIOAudioDelegate

- (void)recordAudio:(nullable NSString *)audioSavePath didBeganWithError:(nullable NSError *)error {
    if (error) {
        // 如果出现error，结束录音
        self.sessionInputView.recordStatus = AudioRecordStatusEnd;
    }
}

- (void)recordAudio:(nullable NSString *)audioSavePath didFinishedWithMaxDuration:(BOOL)maxDuration error:(nullable NSError *)error
{
    if (!error) {
        if (!maxDuration) {
            [MBProgressHUD showLoading:@"正在发送" toView:self.view];
            TIOMessage *message = [TMessageMaker messageForAudioFileURL:[NSURL URLWithString:audioSavePath] session:self.session];
            [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
            }];
        } else {
            // 因为触发最大录音时长而结束
            TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"您已经达到最大录音时长60秒，是否选择发送？" preferredStyle:TAlertControllerStyleAlert];
            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[TAlertAction actionWithTitle:@"发送" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                [MBProgressHUD showLoading:@"正在发送" toView:self.view];
                TIOMessage *message = [TMessageMaker messageForAudioFileURL:[NSURL URLWithString:audioSavePath] session:self.session];
                [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
                }];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
    }
}

- (void)recordAudioDidCancel {
    
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    self.sessionInputView.recordTime = currentTime;
}

- (void)playAudio:(NSString *)audioUrl didBeganWithError:(NSError *)error
{
    DDLogVerbose(@"开始播放语音");
}

- (void)playAudio:(NSString *)audioUrl didFinishedWithError:(NSError *)error
{
    DDLogVerbose(@"语音播放完成");
}

#pragma mark - 点击头像

- (BOOL)onTapAvatar:(TIOMessage *)message
{
    [self jumpToUserhome:message.fromUId userInfo:nil];
    return YES;
}

#pragma mark - 点击气泡

- (BOOL)onTapCell:(IMKitEvent *)event
{
    if ([event.eventName isEqualToString:IMKitEventTouchUpInside]) {
        if (event.messageModel.message.messageType == TIOMessageTypeImage)
        {   // 图片
            TPhotoPreviewModel *model = [TPhotoPreviewModel customAssetModelWithMessage:event.messageModel.message];
            if (model)
            {
                [self.photoPreview addModel:model];
                [self.photoPreview alertWithCurrentMediaModel:model];
            }
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeVideo)
        {   // 视频
            TPhotoPreviewModel *model = [TPhotoPreviewModel customAssetModelWithMessage:event.messageModel.message];
            if (model)
            {
                [self.photoPreview addModel:model];
                [self.photoPreview alertWithCurrentMediaModel:model];
            }
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeText)
        {   // 文本 （主要是超链接）
            NSString *str = event.data;
            
            if (![str compare:@"http" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)] || ![str compare:@"www." options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)])
            {   // 超链接
                WKWebViewController *webVC = [WKWebViewController.alloc init];
                webVC.urlString = str;
                [self.navigationController pushViewController:webVC animated:YES];
            } else {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",str]]];
            }
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeTip)
        {
            // 带富文本的提示,目前只有加好友
            if ([event.data isEqualToString:@"add"]) {
                [self requestToAddUser:0 uid:event.messageModel.message.toUId];
            }
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeFile)
        {   // 文件
            
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeSuperLink)
        {   // 分享的超链接
            NSString *str = event.messageModel.message.superlinkItem[@"url"];
            if (![str compare:@"http" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)] || ![str compare:@"www." options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)])
            {   // 超链接
                WKWebViewController *webVC = [WKWebViewController.alloc init];
                webVC.urlString = str;
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeCard)
        {   // 名片
            TIOMessageAttachmnet *cardInfo = event.messageModel.message.attachmentObjects.firstObject;
            if (!cardInfo) return YES;
            
            if (cardInfo.cardtype == 1)
            {
                // 个人名片
                [self jumpToUserhome:cardInfo.bizid userInfo:nil];
            }
            else
            {
                // 群名片
                // 检查群名片是否可点
                [TIOChat.shareSDK.teamManager checkTeamShareCard:cardInfo.bizid
                                                        fromUser:cardInfo.shareFromUid
                                                      completion:^(NSError * _Nullable error, TIOTeamCardStatus status) {
                    if (!error)
                    {
                        if (status == TIOTeamCardStatusAvailable)
                        {
                            // 已加入此群
                            // 直接进群
                            [self jumpToTeamSessionVC:cardInfo.bizid];
                        }
                        else
                        {
                            // 未加入群
                            TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"是否接受邀请加入群聊？" preferredStyle:TAlertControllerStyleAlert];
                            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                                
                            }]];
                            [alert addAction:[TAlertAction actionWithTitle:@"加入群聊" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                                // 加入群聊
                                TIOLoginUser *userInfo = [TIOChat.shareSDK.loginManager userInfo]; // 找到自己的信息
                                [TIOChat.shareSDK.teamManager addUser:@[userInfo.userId] toTeam:cardInfo.bizid sharerUid:cardInfo.shareFromUid completion:^(NSError * _Nullable error) {
                                    if (!error) {
                                        // 加群成功 进群
                                        [self jumpToTeamSessionVC:cardInfo.bizid];
                                    }
                                }];
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }
                    else
                    {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    }
                }];
            }
        }
        else if (event.messageModel.message.messageType == TIOMessageTypeAudio)
        {   // 音频
            if (TIOChat.shareSDK.audioManager.isPlaying) {
                
                BOOL isCurrentMessagePlaying = [IMKitAudioCenter.sharedCenter isPlayingMessage:event.messageModel.message];
                
                [TIOChat.shareSDK.audioManager stopPlay];
                
                if (!isCurrentMessagePlaying) {
                    // 如果不是重复点击正在播放的语音
                    // 当前点击的event.messageModel.message是一条新语音，则播放
                    [IMKitAudioCenter.sharedCenter play:event.messageModel.message];
                }
                
            } else {
                [IMKitAudioCenter.sharedCenter play:event.messageModel.message];
            }
        } else if (event.messageModel.message.messageType == TIOMessageTypeRed) {
            NSDictionary *params = @{
                @"model" : event.messageModel.message.copy,
                @"sessionId" : self.session.sessionId?:@""
            };
            CBWeakSelf
            [WalletManager.shareInstance openRedPackage:params callback:^(id  _Nonnull data) {
                CBStrongSelfElseReturn
                TIOMessage *nMessage = data;
                [self uiAddMessages:@[nMessage]];
            }];
        }
    }
    
    return YES;
}


#pragma mark - 更多面板

- (void)onTapMoreItem:(IMKitInputMoreItem *)moreItem
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:moreItem.selector];
#pragma clang diagnostic pop
}


#pragma mark - 发送图片
- (void)onTapPicture
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    [self.photoPicker fetchPhotosAndVideosWithView:self.view];
}
#pragma mark - 拍照
- (void)onTapCamera
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    [self.photoPicker fetchCameraWithView:self.view];
}
#pragma mark - 视频聊天
- (void)onTapVideoChat
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
    // 检测摄像头和麦克风授权
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus cameraAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    __block BOOL flag = NO;
    
    if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:^(BOOL granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                                 flag = YES;
                                             } else {
                                                 flag = NO;
                                                 [self showMicroAlert];
                                             }
                                         });
                                     }];
        
    } else if (audioAuthStatus == AVAuthorizationStatusDenied || audioAuthStatus == AVAuthorizationStatusRestricted) {
        [self showMicroAlert];
        flag = NO;
    } else if (audioAuthStatus == AVAuthorizationStatusAuthorized) {
        flag = YES;
    }
    
    if (cameraAuthStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                                 flag = YES;
                                             } else {
                                                 [self showCameraAlert];
                                                 flag = NO;
                                             }
                                         });
                                     }];
        
    } else if (cameraAuthStatus == AVAuthorizationStatusDenied || cameraAuthStatus == AVAuthorizationStatusRestricted) {
        [self showCameraAlert];
        flag = NO;
    } else if (cameraAuthStatus == AVAuthorizationStatusAuthorized) {
        flag = YES;
    }
    
    if (flag) {
        TCallViewController *videoVC = [TCallViewController.alloc initWithCallee:self.friendInfo];
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

#pragma mark - 语音聊天
- (void)onTapAudioChat
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
    // 检测摄像头和麦克风授权
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    __block BOOL flag = NO;
    
    if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:^(BOOL granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                                 flag = YES;
                                             } else {
                                                 [self showMicroAlert];
                                             }
                                         });
                                     }];
        
    } else if (audioAuthStatus == AVAuthorizationStatusDenied || audioAuthStatus == AVAuthorizationStatusRestricted) {
        [self showMicroAlert];
    } else if (audioAuthStatus == AVAuthorizationStatusAuthorized) {
        flag = YES;
    }
    
    if (flag) {
        TCallAudioViewController *audioVC = [TCallAudioViewController.alloc initWithCallee:self.friendInfo];
        [self.navigationController pushViewController:audioVC animated:YES];
    }
}
#pragma mark - 发送文件

- (void)onTapFile
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
   
    
    TDownloadFileListViewController *vc = [TDownloadFileListViewController.alloc init];
    CBWeakSelf
    vc.t_callback = ^(UIViewController * _Nonnull viewController, id  _Nullable data) {
        CBStrongSelfElseReturn
        
        [viewController.navigationController popViewControllerAnimated:YES];
        
        NSString *url = data;
        
        TIOMessage *message = [TMessageMaker messageForFileURL:[NSURL URLWithString:url] session:self.session];
        
        [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 发送个人名片
- (void)onTapCard
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
    TShareFriendCardListViewController *selectdListVC = [TShareFriendCardListViewController.alloc init];
    
    selectdListVC.t_callback = ^(UIViewController * _Nonnull viewController, id  _Nullable data) {
        TIOUser *user = (TIOUser *)data;
        
        [viewController.navigationController popViewControllerAnimated:YES];
        TIOMessage *message = [TMessageMaker messageForFriendCard:user.userId type:NO session:self.session];
        [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
            
        }];
    };
    
    [self.navigationController pushViewController:selectdListVC animated:YES];
}

- (void)onTapGroupCard
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
    TShareTeamCardListViewController *selectdListVC = [TShareTeamCardListViewController.alloc init];
    
    selectdListVC.t_callback = ^(UIViewController * _Nonnull viewController, id  _Nullable data) {
        [viewController.navigationController popViewControllerAnimated:YES];
        TIOTeam *team = (TIOTeam *)data;
        TIOMessage *message = [TMessageMaker messageForFriendCard:team.teamId type:YES session:self.session];
        [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
            
        }];
    };
    
    [self.navigationController pushViewController:selectdListVC animated:YES];
}

- (void)onTapRed
{
    NSDictionary *params = @{
        @"currentVC" : self,
        @"user" : self.friendInfo,
        @"sessionId" : self.session.sessionId
    };
    [WalletManager.shareInstance evokeSendRedViewController:params];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    
    BOOL canAccessingResource = [urls.firstObject startAccessingSecurityScopedResource];
    if(canAccessingResource) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            
            [MBProgressHUD showMessage:@"正在上传文件" toView:self.view];
            
            AVAsset *asset = [AVURLAsset URLAssetWithURL:newURL options:nil];
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            
            TIOMessage *message = nil;
            
            if (tracks.count > 0)
            {
                message = [TMessageMaker messageForVideoURL:newURL session:self.session];
            }
            else
            {
                message = [TMessageMaker messageForFileURL:newURL session:self.session];
            }
            
            [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }];
            
        }];
        if (error) {
            // error handing
        }
    } else {
        // startAccessingSecurityScopedResource fail
    }
    [urls.firstObject stopAccessingSecurityScopedResource];
}

#pragma mark - 跳转到用户主页

/// 跳转指定用户的主页
/// @param targetUserId 目标用户ID
/// @param preUserInfo 有值直接传到下一页，不用获取用户信息
- (void)jumpToUserhome:(NSString *)targetUserId userInfo:(TIOUser *)preUserInfo
{
    // 可能已经解除好友关系 但是会话还在，查看的对方信息主页就会不一样
    // 所以 先验证是不是好友
    CBWeakSelf
    [TIOChat.shareSDK.friendManager isMyFriend:targetUserId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else
        {
            // 预处理Block
            void (^jumpToUserInfoVCBlock)(TIOUser *userInfo, NSInteger type) = ^(TIOUser *userInfo, NSInteger type) {
                
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
                
                if (isFriend)
                {
                    params[@"user"] = userInfo;
                    params[@"type"] = @(type); // 好友
                    
                    UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                    [self.navigationController pushViewController:homePageVC animated:YES];
                }
                else
                {
                    params[@"user"] = userInfo;
                    params[@"type"] = @(type); // 需要审核
                    
                    UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                    [self.navigationController pushViewController:homePageVC animated:YES];
                }
            };
            
            
            if (preUserInfo)
            {
                // 有用户信息，直接执行block跳转
                jumpToUserInfoVCBlock(preUserInfo, isFriend?1:3);
            }
            else
            {
                // 获取用户信息，再执行block跳转
                [TIOChat.shareSDK.friendManager fetchUserInfo:targetUserId completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                    if (error)
                    {
                        DDLogError(@"%@",error);
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    }
                    else
                    {
                        jumpToUserInfoVCBlock(user, isFriend?1:3);
                    }
                }];
            }
        }
    }];
}

- (void)jumpToTeamSessionVC:(NSString *)teamId
{
    // 获取会话ID，进群
    [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeTeam
                                                friendId:teamId
                                              completion:^(NSError * _Nullable error, TIORecentSession * _Nullable session) {
        if (!error) {
            TTeamViewController *vc = [TTeamViewController.alloc initWithSession:session.session];
            [self.navigationController pushViewController:vc animated:YES];
            // 从群聊页返回一级页面
            UIViewController *firstVC = self.navigationController.viewControllers.firstObject;
            [vc.navigationController setViewControllers:@[firstVC,vc]];
        }
    }];
}

#pragma mark - 添加好友

#pragma mark - 第三步 : 发起加好友的操作

/// SDK添加API
/// @param condition 添加条件
- (void)requestToAddUser:(NSInteger)condition uid:(NSString *)uid
{
    NSString *nick = [TIOChat.shareSDK.loginManager userInfo].nick;
    
    NSString *text = [NSString stringWithFormat:@"我是 %@",nick];
    
    TInputAlertController *alert = [TInputAlertController alertWithTitle:@"添加好友" placeholder:@"请输入验证信息" inputHeight:84 inputStyle:TAlertControllerTextView];
    alert.text = text; // 默认文本
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {

        }];

        action;
    })];

    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"申请" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            // SDK API
            TIOFriendRequest *request = [TIOFriendRequest.alloc init];
            request.message = alert.text;
            request.operation = TIOFriendOperationRequest;
            request.userId = uid;
            
            [TIOChat.shareSDK.friendManager addFrinend:request
                                            completion:^(NSError * _Nullable error) {
                if (error) {
                    DDLogError(@"%@",error);
                } else {
                    [MBProgressHUD showInfo:@"已发送申请，等待对方同意" toView:self.view];
                }
            }];
        }];

        action;
    })];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 音视频授权检测

- (void)showMicroAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有开启\"麦克风\"权限\n 无法进行通话。\n 请在设置中开启麦克风权限。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有开启\"摄像头\"权限\n 无法进行通话。\n 请在设置中开启摄像头权限。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
