//
//  TTeamViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamViewController.h"
#import "TSessionConfig.h"
#import "TMessageMaker.h"
#import "TDownloadFileListViewController.h"
#import "TReviewInvitationViewController.h"
/// common
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"
#import "TIOChatKit.h"
#import "UIImage+T_gzip.h"
#import "TAlertController.h"
#import "CTMediator+ModuleActions.h"
#import "TSessionPhotoPreview.h"
#import "TPhotoPicker.h"
#import "TCardAlert.h"
#import "TShareFriendCardListViewController.h"
#import "TShareTeamCardListViewController.h"
#import <CoreText/CoreText.h>
#import "TDownloadTool.h"
#import "WKWebViewController.h"
#import "WalletKit.h"
#import "TBottomMessageHUD.h"
#import "UIImage+TColor.h"
#import "WaterMarkTool.h"
/// pods
#if __has_include(<YYModel/YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif

@interface TTeamViewController () <TIOChatDelegate, TIOSystemDelegate, TIOTeamDelegate,TIOChatLinkDelegate, TIOConversationDelegate,TIOAudioDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) id<IMSessionConfig> config;
@property (nonatomic, strong) TIORecentSession *sessionInfo;
@property (nonatomic, strong) TIOTeam *team;
@property (nonatomic, strong) TSessionPhotoPreview *photoPreview;
@property (nonatomic, strong) TPhotoPicker  *photoPicker;

@property (nonatomic, assign) NSInteger activeStatus;// 记录活跃状态

@end

@implementation TTeamViewController

- (void)dealloc
{
    [TIOChat.shareSDK.chatManager removeDelegate:self];
    [TIOChat.shareSDK.systemManager removeDelegate:self];
    [TIOChat.shareSDK.teamManager removeDelegate:self];
    [TIOChat.shareSDK.conversationManager removeDelegate:self];
    [TIOChat.shareSDK.audioManager removeDelegate:self];
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
    // 设置背景颜色
//    self.tableView.backgroundColor = [UIColor colorWithHex:0xF9F9F9];

    // 配置聊天 需要在此之前将自己的用户ID放进session里，统一在这里处理，没有放到外面的入口处
    self.session.ownerId = [TIOChat.shareSDK.loginManager.userInfo userId];
    [self setupConfigurator];
    [self.view bringSubviewToFront:self.navigationBar];

    [self enter];
    [self fetchHistoryMessages];
    
    [TIOChat.shareSDK.chatManager addDelegate:self];
    [TIOChat.shareSDK.systemManager addDelegate:self];
    [TIOChat.shareSDK.teamManager addDelegate:self];
    [TIOChat.shareSDK.conversationManager addDelegate:self];
    [TIOChat.shareSDK.audioManager addDelegate:self];
    [TIOChat.shareSDK addDelegate:self];
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
    if (!self.team || self.team.status == TIOTeamStatusDissolved)
    {
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"当前群已被群主解散，是否离开当前会话？" preferredStyle:TAlertControllerStyleAlert];
        [alert addAction:[TAlertAction actionWithTitle:@"不离开" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"离开" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        params[@"team"] = self.team.yy_modelCopy;
        params[@"sessionId"] = self.session.sessionId;
        params[@"topflag"] = @(self.sessionInfo.isTop);
        UIViewController *vc = [CTMediator.sharedInstance T_teamHomePageViewController:params];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 进入、离开会话

- (void)enter
{
    CBWeakSelf
    /// 激活焦点
    [TIOChat.shareSDK.conversationManager enterConversationWithSession:self.session
                                                                   uid:TIOChat.shareSDK.loginManager.userInfo.userId
                                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable session) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"进入会话失败:%@",error);
        } else {
            DDLogInfo(@"成功进入会话");
        }
    }];
    
    
    /// 获取群信息
    [TIOChat.shareSDK.teamManager fetchTeamInfoWithTeamId:self.session.toUId completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"%@",error);
        } else {
            self.team = team;
            // 群名最大显示160px
            NSString *countStr = [NSString stringWithFormat:@"(%zd)",team.memberNumber];
            [self setText:team.name count:countStr];
        }
    }];
    /// 获取会话信息
    [TIOChat.shareSDK.conversationManager fetchSessionInfoWithSessionId:self.session.sessionId completion:^(NSError * _Nullable error, TIORecentSession * _Nullable session) {
        CBStrongSelfElseReturn
        if (!error) {
            self.sessionInfo = session;
            // 如果会话是无效的：非好友、被踢出群等不在会话内
            if (session.linkStatus == TIOSessionLinkStatusValid) {
                [self setupNavRightItem];
            }
        }
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
    [TIOChat.shareSDK.conversationManager leaveConversationWithSessionId:self.session.sessionId completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        }
    }];
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

#pragma mark - 网络变化

/// 拼接群名：这是学习交...(1003) 格式，群名后面省略，括号不省略
/// @param text 完整的  这是学习交流欢乐群哈哈哈哈(1003)
/// @param expandString ...(1003)
- (void)setText:(NSString *)text count:(NSString *)expandString
{
    if (!text) return;
    
    CGSize nSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]} context:nil].size;
    CGFloat cWidth = [expandString boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]} context:nil].size.width;
    CGFloat symbolWidth = [@"..." boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]} context:nil].size.width;
    
    CGFloat maxWidth = self.view.width - 160;
    
    NSString *result;
    
    if (nSize.width + cWidth > maxWidth) {
        nSize.width = maxWidth - cWidth - symbolWidth;
        
        NSArray *arr = [self splitWithString:text size:nSize];
        
        result = arr.firstObject;
        result = [result stringByAppendingString:@"..."];
    } else {
        result = text;
    }
    
    result = [result stringByAppendingString:expandString];
    
    [self refreshSessionTitle:result];
}

- (NSArray *)splitWithString:(NSString *)string size:(CGSize)size
{
    if (!string || string.length == 0) {
        return nil;
    }
    
    size.height += 5;
    
    NSMutableAttributedString *attriStringM = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]}];
    
    NSMutableArray *textLines = @[].mutableCopy;
    
    NSString *textLine = [NSString string];
    
    CTFramesetterRef frameSetter;
    CFRange fitRange;
    
    while (attriStringM.length) {
        frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attriStringM);
        
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, size, &fitRange);
        CFRelease(frameSetter);
        
        /**
         * Note:
         * 处理emoji表情，字符串的长度会被识别为0
         * 特别是文本只有一个emoji时，需做以下处理
         */
        if (fitRange.length == 0) {
            return nil;
        }
        
        textLine = [[attriStringM attributedSubstringFromRange:NSMakeRange(0, fitRange.length)] string];
        
        [textLines addObject:textLine];
        
        [attriStringM setAttributedString:[attriStringM attributedSubstringFromRange:NSMakeRange(fitRange.length, attriStringM.string.length - fitRange.length)]];
    }
    
    return textLines;
}

#pragma mark - 获取历史消息

- (void)fetchHistoryMessages
{
    CBWeakSelf
    [TIOChat.shareSDK.conversationManager fetchMessagesHistory:self.session startMsgId:nil endMsgId:nil completion:^(NSError * _Nullable error, NSArray<TIOMessage *> * _Nullable messages) {
        CBStrongSelfElseReturn
        if (error) {
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

- (void)didReadBottomMessage
{
    [TBottomMessageHUD hideForView:self.view];
}

#pragma mark - 标题

- (NSString *)sessionTitle {
    return self.title;
}

- (void)onSendText:(NSString *)text atUsers:(NSArray *)atUsers
{
    if (self.team.status == TIOTeamStatusDissolved) {
        [MBProgressHUD showInfo:@"当前群已被群主解散" toView:self.view];
        return;
    }
    
    
    // 构造消息时一定要给消息指定当前session
    TIOMessage *message = [TMessageMaker messageForTextWithText:text session:self.session];
    
    if (atUsers.count) {
        NSMutableString *uidsString = [NSMutableString.alloc init];
        [atUsers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == atUsers.count-1) {
                [uidsString appendFormat:@"%@",obj];
            } else {
                [uidsString appendFormat:@"%@,",obj];
            }
        }];
        message.at = uidsString;
    }
    
    
    [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
        if (error) {
            
            // 1、以弱提示提示
            [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
            // 2、以提示的消息类型展示
            NSInteger msgId = 10000+arc4random()%10*1000+arc4random()%10*100+arc4random()%10*10+arc4random()%10;

            TIOMessage *message = [TIOMessage.alloc init];
            message.toUId = self.session.toUId;
            message.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
            message.text = error.localizedDescription;
            message.messageId = [NSString stringWithFormat:@"%zd",msgId];
            message.messageType = TIOMessageTypeTip;
            [self uiAddMessages:@[message]];
        }
    }];
}

- (void)beginAt:(id<IMKitInputView>)inputView
{
    DDLogVerbose(@"输入@");
    TIOTeamMember *user = [TIOTeamMember.alloc init];
    user.groupId = self.team.teamId;
    user.uid = self.session.ownerId;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:user forKey:@"user"];
    
    UIViewController *vc = [CTMediator.sharedInstance T_AtListViewController:params];
    CBWeakSelf
    vc.t_callback = ^(UIViewController * _Nonnull viewController, id  _Nullable data) {
        CBStrongSelfElseReturn
        if ([data isKindOfClass:NSString.class]) {
            [inputView insertAtUser:@"所有人" uid:@"all" hasAtChar:NO];
        } else {
            TIOTeamMember *user = data;
            [inputView insertAtUser:user.nick uid:user.uid hasAtChar:NO];
        }
        [viewController.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TIOChatDelegate

- (void)onRecvMessages:(NSArray<TIOMessage *> *)messages
{
    DDLogVerbose(@"onRecvMessages");
    
    [self uiAddMessages:messages];
}

- (void)didDeleteMessage:(TIOMessage *)message
{
    [self uiDeleteMessage:message];
}

- (void)didRevokeMessage:(TIOMessage *)message
{
    [self uiDeleteMessage:message];
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

- (void)onRecieveSystemNotification:(TIOSystemNotification *)notification
{
    if (notification.code > 1000) {
        TIOMessage *message = [TIOMessage.alloc init];
        message.toUId = self.session.toUId;
        message.timestamp = notification.t;
        message.text = notification.msg;
        message.messageId = [NSString stringWithFormat:@"%zd",notification.mid];
        message.messageType = TIOMessageTypeTip;
        [self uiAddMessages:@[message]];
    }
}

- (void)didKickedOut:(TIOSystemNotification *)notification
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didRejoin:(TIOSystemNotification *)notification
{
    [self setupNavRightItem];
}

- (void)didClearAllMessagesInSession:(TIOSession *)session
{
    if ([session.sessionId isEqualToString:self.session.sessionId]) {
        [self uiClearAllMessages];
    }
}

#pragma mark - TIOTeamDelegate

/// 群信息发生变更
- (void)didUpdateTeamInfo:(TIOTeam *)team
{
    NSString *countStr = [NSString stringWithFormat:@"(%zd)",team.memberNumber];
    [self setText:team.name count:countStr];
}

- (BOOL)onTapAvatar:(TIOMessage *)message
{
    if (self.team.friendflag == 1) {
        // 允许查看群成员信息
        [self jumpToUserhome:message.fromUId userInfo:nil];
    } else {
        if (self.team.grouprole == TIOTeamUserRoleOwner || self.team.grouprole == TIOTeamUserRoleManager) {
            // 群主 管理员 不受开关限制，可以查看群成员信息
            [self jumpToUserhome:message.fromUId userInfo:nil];
        } else {
            // 非群管/普通成员 只能查看和自己好友关系的群成员信息
            [TIOChat.shareSDK.friendManager isMyFriend:message.fromUId completion:^(BOOL isFriend, NSError * _Nullable error) {
                if (isFriend) {
                    [self jumpToUserhome:message.fromUId userInfo:nil];
                }
            }];
        }
    }
    
    return YES;
}

- (BOOL)onLongPressCell:(TIOMessage *)message inView:(UIView *)view
{
    [self menusItems:message completion:^(NSArray *items) {
        if ([items count] ) {
            UIMenuController *controller = [UIMenuController sharedMenuController];
            controller.menuItems = items;
            self.messageForMenu = message;
            [controller setTargetRect:view.bounds inView:view];
            [controller setMenuVisible:YES animated:YES];
        }
    }];
    
    return YES;
}

- (BOOL)menusItems:(TIOMessage *)message completion:(void(^)(NSArray *items))completion
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    
    BOOL deleteFlag = NO;
    BOOL revokeFlag = NO;
    BOOL repostFlag = NO;
    BOOL multiFlag = NO;
    BOOL downloadFlag = NO;
    BOOL tipoffFlag = YES;
    
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
    if (message.messageType == TIOMessageTypeCard || message.messageType == TIOMessageTypeAudioChat || message.messageType == TIOMessageTypeVideoChat  || message.messageType == TIOMessageTypeAudio) {
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
    
    if (downloadFlag) {
        [items addObject:[UIMenuItem.alloc initWithTitle:@"下载"
                                                  action:@selector(downloadMsg:)]];
    }
    
    if (tipoffFlag) {
        [items addObject:[UIMenuItem.alloc initWithTitle:@"举报"
                                                  action:@selector(tipoffMsg:)]];
    }
    
    [TIOChat.shareSDK.conversationManager findSession:self.session.sessionId complete:^(TIORecentSession * _Nullable session) {
        if (session) {
            if (session.bizrole == TIOTeamUserRoleOwner || session.bizrole == TIOTeamUserRoleManager) {
                [items addObject:[UIMenuItem.alloc initWithTitle:@"撤回消息"
                                                          action:@selector(revokeMsg:)]];
            } else {
                // 撤回自己的消息
                NSString *selfUid = TIOChat.shareSDK.loginManager.userInfo.userId;
                if ([selfUid isEqualToString:message.fromUId]) {
                    [items addObject:[UIMenuItem.alloc initWithTitle:@"撤回"
                                                              action:@selector(revokeMsg:)]];
                }
            }
        }
        completion(items);
    }];
    
    
//
//    [items addObject:[UIMenuItem.alloc initWithTitle:@"引用" action:@selector(revokeMsg:)]];
//    [items addObject:[UIMenuItem.alloc initWithTitle:@"编辑" action:@selector(revokeMsg:)]];
//    [items addObject:[UIMenuItem.alloc initWithTitle:@"收藏" action:@selector(revokeMsg:)]];
    
    return items.count>0?YES:NO;
    
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
    
    if (![msg.fromUId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定撤回该群聊消息？" preferredStyle:TAlertControllerStyleAlert];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }];
            action;
        })];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                [TIOChat.shareSDK.chatManager revokeMessage:msg inSession:self.session completionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
                    }
                }];
            }];
            action;
        })];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [TIOChat.shareSDK.chatManager revokeMessage:msg inSession:self.session completionHandler:^(NSError * _Nullable error) {
            if (error) {
                [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
            }
        }];
    }
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
    
    MBProgressHUD *progressView = [MBProgressHUD showProgress:0 toView:self.view];
    
    [TDownloadTool t_download:file.url name:@"" ext:file.ext progress:^(CGFloat p) {
        progressView.progress = p;
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
    TIOReportRequest *request = [TIOReportRequest.alloc init];
    request.type = TIOReportTypeMessage;
    request.teamid = self.team.teamId;
    request.messageid = msg.messageId;
    [TIOChat.shareSDK report:request completion:^(NSError * _Nullable error, id  _Nonnull result) {
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
    DDLogVerbose(@"调用SDK取消录音API");
    [TIOChat.shareSDK.audioManager cancelRecord];
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
            TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"您已经静达到最大录音时长60秒，是否选择发送？" preferredStyle:TAlertControllerStyleAlert];
            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[TAlertAction actionWithTitle:@"发送" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                TIOMessage *message = [TMessageMaker messageForAudioFileURL:[NSURL URLWithString:audioSavePath] session:self.session];
                [MBProgressHUD showLoading:@"正在发送" toView:self.view];
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
    NSLog(@"开始播放语音");
}

- (void)playAudio:(NSString *)audioUrl didFinishedWithError:(NSError *)error
{
    NSLog(@"语音播放完成");
}


#pragma mark - 点击气泡

- (BOOL)onTapCell:(IMKitEvent *)event
{
    if ([event.eventName isEqualToString:IMKitEventTouchUpInside]) {
        if (event.messageModel.message.messageType == TIOMessageTypeImage)
        {   // 点击图片
            // 将图片消息转成预览model
            TPhotoPreviewModel *model = [TPhotoPreviewModel customAssetModelWithMessage:event.messageModel.message];
            if (model)
            {   // 向图片视频预览器添加预览内容
                [self.photoPreview addModel:model];
                // 开始预览
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
            [WalletManager.shareInstance openRedPackage:params callback:^(id  _Nonnull data) {
                TIOMessage *nMessage = data;
                [self uiAddMessages:@[nMessage]];
            }];
        } else if (event.messageModel.message.messageType == TIOMessageTypeRichTip) {
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:event.messageModel.message.apply];
            TReviewInvitationViewController *vc = [TReviewInvitationViewController.alloc init];
            vc.applyId = tempDict[@"id"];
            vc.message = event.messageModel.message;
            vc.onClick = ^(TIOMessage * _Nonnull msg) {
                [self uiUpdateMessage:msg];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    return YES;
}

- (BOOL)onLongPressAvatar:(TIOMessage *)message
{
    [self showActionSheetForMessage:message];
    
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
    
    [MBProgressHUD showInfo:@"视频聊天" toView:self.view];
}
#pragma mark - 语音聊天
- (void)onTapAudioChat
{
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
    [MBProgressHUD showInfo:@"语音聊天" toView:self.view];
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
        @"user" : self.team,
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
            
            TIOMessage *message = [TMessageMaker messageForFileURL:newURL session:self.session];

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
    // 预处理Block
    void (^jumpToUserInfoVCBlock)(TIOUser *userInfo, NSInteger type, BOOL isFriend) = ^(TIOUser *userInfo, NSInteger type, BOOL isFriend) {
        
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
    
    // 可能已经解除好友关系 但是会话还在，查看的对方信息主页就会不一样
    // 先验证是不是进入自己的主页，如果不是自己再去验证好友关系
    if ([targetUserId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
        // 0 是自己，请查看 TUserHomePageType
        preUserInfo = TIOChat.shareSDK.loginManager.userInfo;
        jumpToUserInfoVCBlock(preUserInfo, 0, YES);
        return;
    }
    
    // 验证是不是好友
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
            if (preUserInfo)
            {
                // 有用户信息，直接执行block跳转
                jumpToUserInfoVCBlock(preUserInfo, isFriend?1:3, isFriend);
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
                        jumpToUserInfoVCBlock(user, isFriend?1:3, isFriend);
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

- (void)showActionSheetForMessage:(TIOMessage *)message
{
    [TIOChat.shareSDK.teamManager checkStatusForUser:message.fromUId inTeam:self.team.teamId completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
        NSLog(@"[调用] result = %@",result);
        NSInteger userstatus = [result[@"userstatus"] integerValue]; //1:被长安的用户是群内有效用户  2:被长安的用户不在群内
        NSInteger grant = [result[@"grant"] integerValue]; // 1：有权限禁言；2：无权限禁言
        NSInteger flag = [result[@"flag"] integerValue]; // 禁言标识：1：时长禁言；2：否；3：长久禁用
        NSInteger rolegrant = [result[@"rolegrant"] integerValue]; // 有么有角色管理权限
//        NSInteger kickgrant = [result[@"kickgrant"] integerValue]; // 有么有踢人权限
        NSInteger grouprole = [result[@"grouprole"] integerValue]; // 该用户的群角色
        
        if (userstatus == 1) {
            TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
            CBWeakSelf
            [alert addAction:({
                CBStrongSelfElseReturn
                TAlertAction *action = [TAlertAction actionWithTitle:@"@TA" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                    // 长按时，强制改为文字输入
                    [self.sessionInputView refreshStatus:IMInputStatusText];
                    [self.sessionInputView endEditing:NO];
                    CBWeakSelf
                    [TIOChat.shareSDK.teamManager checkMember:message.fromUId isInTeam:self.session.toUId completion:^(NSError * _Nullable error, BOOL isInTeam) {
                        CBStrongSelfElseReturn
                        if (!error) {
                            if (isInTeam) {
                                [self.sessionInputView insertAtUser:message.from uid:message.fromUId hasAtChar:YES];
                            }
                        }
                    }];
                }];
                
                action;
            })];
            
            if (grant == 1) {
                NSString *msg = flag == 2? @"禁言" : @"解除禁言";
                [alert addAction:({
                    TAlertAction *action = [TAlertAction actionWithTitle:msg style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                        if (flag != 2) {
                            // 进行解除禁言操作
                            [TIOChat.shareSDK.teamManager forbiddenSpeakInTeam:self.team.teamId oper:2 mode:flag duration:0 uid:message.fromUId completion:^(NSError * _Nullable error) {
                                if (!error) {
                                    [MBProgressHUD showInfo:@"操作成功" toView:self.view];
                                } else {
                                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                                }
                            }];
                        } else {
                            // 进行禁言操作
                            [self alertNoTalkingForUid:message.fromUId];
                        }
                    }];
                    
                    action;
                })];
            }
            
            if (rolegrant == 1) {
                // 可以设置/取消管理员
                if (grouprole != TIOTeamUserRoleOwner) {
                    [alert addAction:({
                        NSString *msg = grouprole == TIOTeamUserRoleMember?@"设置管理员":@"取消管理员";
                        TAlertAction *action = [TAlertAction actionWithTitle:msg style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                            TIOTeamUserRole toRole = grouprole == TIOTeamUserRoleMember?TIOTeamUserRoleManager:TIOTeamUserRoleMember;
                            [TIOChat.shareSDK.teamManager changeMemberRole:toRole uid:message.fromUId inTeam:self.team.teamId completion:^(NSError * _Nullable error) {
                                if (!error) {
                                    
                                } else {
                                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                                }
                            }];
                        }];
                        action;
                    })];
                }
            }
            
            [alert addAction:({
                TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                }];
                action;
            })];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [MBProgressHUD showInfo:@"该成员不在群内" toView:self.view];
        }
    }];
}

- (void)alertNoTalkingForUid:(NSString *)uid
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"禁言10分钟" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self requestNoTalking:10*60 uid:uid mode:1];
        }];
        action;
    })];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"禁言1小时" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self requestNoTalking:60*60 uid:uid mode:1];
        }];
        action;
    })];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"禁言6小时" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self requestNoTalking:6*60*60 uid:uid mode:1];
        }];
        action;
    })];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"禁言24小时" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self requestNoTalking:24*60*60 uid:uid mode:1];
        }];
        action;
    })];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"长期禁言" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self requestNoTalking:0 uid:uid mode:3];
        }];
        action;
    })];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        }];
        action;
    })];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)requestNoTalking:(NSTimeInterval)seconds uid:(NSString *)uid mode:(NSInteger)mode
{
    // 发起禁言请求
    [TIOChat.shareSDK.teamManager forbiddenSpeakInTeam:self.team.teamId oper:1 mode:mode duration:seconds uid:uid completion:^(NSError * _Nullable error) {
        if (!error) {
            [MBProgressHUD showInfo:@"操作成功" toView:self.view];
        } else {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
}

@end
