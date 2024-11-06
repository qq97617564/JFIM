//
//  TSessionListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSessionListViewController.h"
#import "TSessionListCell.h"
// common
#import "NSString+T_HTTP.h"
#import "NSString+T_Time.h"
#import "TAddPopupView.h"
#import "TAlertController.h"
#import "TCheckBoxController.h"
#import "TInputAlertController.h"
#import "UIButton+Enlarge.h"
#import "UIImage+TColor.h"
#import "FrameAccessor.h"
#import "TMessageMaker.h"
#import "TChatSound.h"
#import "MBProgressHUD+NJ.h"
#import "UIControl+T_LimitClickCount.h"
#import "PDCameraScanViewController.h"

// main
#import "CTMediator+ModuleActions.h"
/// SDK
#import "ImportSDK.h"

@interface TSessionListViewController () <UITableViewDelegate,UITableViewDataSource, TIOConversationDelegate, TIOTeamDelegate, TIOSystemDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *confirmDeleteLabel;
@property (assign, nonatomic) NSInteger rowCount;

@property(nonatomic, strong)UIView *searchView;

@property (strong,  nonatomic) dispatch_queue_t queue;

/// 数据源
@property (strong, nonatomic) NSMutableArray<TIORecentSession *> *allRecentSessions;

@end

@implementation TSessionListViewController

- (void)dealloc
{
    [TIOChat.shareSDK.conversationManager removeDelegate:self];
    [TIOChat.shareSDK.teamManager removeDelegate:self];
    [TIOChat.shareSDK.systemManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_queue_create("Dan-serial", DISPATCH_QUEUE_SERIAL);
    
    [self addNavigationBar];
    [self addTableView];
    
    [TIOChat.shareSDK.conversationManager addDelegate:self];
    [TIOChat.shareSDK.teamManager addDelegate:self];
    [TIOChat.shareSDK.systemManager addDelegate:self];
    
    [self requestData];
    
    self.rowCount = 20;
    
    // tab 预加载
    UINavigationController *nav = self.navigationController.tabBarController.viewControllers[1];
    if (nav.viewControllers.firstObject) {
        [nav.viewControllers.firstObject loadViewIfNeeded];
    }
}

/// 导航条
- (void)addNavigationBar
{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.viewSize = CGSizeMake(44, 44);
    moreBtn.top = Height_StatusBar;
    moreBtn.right = ScreenWidth() - 5;
    [moreBtn setImage:[UIImage imageNamed:@"ADD"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(addButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:moreBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.viewSize = CGSizeMake(44, 44);
    searchBtn.centerY = moreBtn.centerY;
    searchBtn.left = 15;
    [searchBtn setTitle:@"聊天" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    searchBtn.userInteractionEnabled = false;
//    [searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
//    [searchBtn addTarget:self action:@selector(toSearchMoudle:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:searchBtn];
    
//    self.title = @"聊天";
//    self.title = @"聊天";
}

- (void)addButtonItemClicked:(UIButton *)sender
{
    UIButton *button = sender;
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformRotate(button.transform, M_PI_4);
    }];
    
    TAddPopupView *popupView = [TAddPopupView menuWithItemTitles:@[@"创建群聊",@"添加好友",@"扫一扫"] itemImages:@[@"createGroup",@"addFriend",@"nav_scan"] itemHandler:^(TAddPopupView * _Nonnull popupView, NSInteger index, NSString * _Nonnull title) {
        DDLogInfo(@"%@",title);
        [UIView animateWithDuration:0.2 animations:^{
            button.transform = CGAffineTransformRotate(button.transform, -M_PI_4);
        }];
        
        if (index == 0)
        {
            [self toCreatTeamModuleVC];
        }
        else if (index == 1)
        {
            [self toSearchModuleUserVC];
        }
        else if (index == 2)
        {
            [self toScanQRVC];
        }
    }];
    
    CGPoint anchorPoint = [self.navigationBar convertPoint:sender.center toView:UIApplication.sharedApplication.keyWindow];
    anchorPoint.y = Height_NavBar;
    
    popupView.anchorPoint = anchorPoint;
    
    [popupView show];
}

/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar - Height_TabBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 75;
    tableView.tableHeaderView = self.searchView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor colorWithHex:0xE9E9E9];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [tableView registerClass:[TSessionListCell class] forCellReuseIdentifier:NSStringFromClass(TSessionListCell.class)];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}
-(UIView *)searchView{
    if (!_searchView) {
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        v.backgroundColor = [UIColor clearColor];
        UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(16, 5, self.view.width-32, 34)];
        bg.backgroundColor = [UIColor colorWithHex:0xE8EBF0];
        bg.layer.cornerRadius = 4;
        [v addSubview:bg];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 0, self.view.width-52, 34);
        [btn setTitle:@" 搜索" forState:UIControlStateNormal];

        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [btn setTitleColor:[UIColor colorWithHex:0x939BB2] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"searchbar"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toSearchMoudle:) forControlEvents:UIControlEventTouchUpInside];
        [bg addSubview:btn];
        _searchView = v;
    }
    return _searchView;
}

- (void)requestData
{
    // 从数据库读取最新的数据
    [TIOChat.shareSDK.conversationManager fetchAllRecentSessions:^(NSArray<TIORecentSession *> * _Nullable recentSessions, NSError * _Nullable error) {
        self.allRecentSessions = [NSMutableArray arrayWithArray:recentSessions];
        [self sortAllRecentSessions];
        if (recentSessions.count) {
            
        } else {
            DDLogVerbose(@"获取本地会话为空");
        }
        
        [self refreshTable];
    }];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSessionListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TSessionListCell.class) forIndexPath:indexPath];
    if (self.allRecentSessions.count) {
        TIORecentSession *session = self.allRecentSessions[indexPath.row];
        cell.nickLabel.text = session.session.name;

        NSString *avatar = session.session.avatar;
        [cell setAvatarUrl:avatar];
         
        cell.timeLabel.text = session.lastMessage.msgTime.timeOfsessionList;
        
        cell.isTop = session.isTop;

        if (session.officialflag == 1 || session.xx == 3) {
            cell.isGF = true;
        }else{
            cell.isGF = false;
        }

        NSInteger unreadStatus = 0; // 自己的消息有么有被度，默认是0，表示对方发的消息
        
        if (session.session.sessionType == TIOSessionTypeP2P) {
            // toReadFlag是消息发送者的消息有么有被对方度
            // 因为要现实的是自己的消息有么有被对方对
            // 只有自己发的消息，toReadFlag才有效
            if ([session.lastMessage.fromUId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
                unreadStatus = session.toReadFlag; // 别人有没有读你的消息
            }
        }
        
        BOOL isAt = session.atreadflag == 2;
        [cell setShowDoNotDisturbIcon:session.msgfreeflag==1 unreadCount:session.unReadCount];
        cell.messageLabel.attributedText = [TMessageMaker messageForMessage:session.lastMessage isAt:isAt beread:unreadStatus unreadCount:session.msgfreeflag==1?session.unReadCount:0];
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allRecentSessions.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!TIOChat.shareSDK.isConnected) {
        [MBProgressHUD showInfo:@"当前网络异常" toView:self.view];
//        [MBProgressHUD showBlackInfo:@"当前网络异常" toView:self.view];
        return;
    }
    
    TIORecentSession *recentSession = self.allRecentSessions[indexPath.row];
    TIOSession *session = recentSession.session;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:session forKey:@"session"];
    
    if (session.sessionType == TIOSessionTypeP2P)
    {
        UIViewController *vc = [CTMediator.sharedInstance T_P2PViewController:params];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIViewController *vc = [CTMediator.sharedInstance T_TeamViewController:params];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//    BOOL isSelf = [self.allRecentSessions[indexPath.row].toUId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId];
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
{
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
{
    // 置顶
    
    BOOL top = self.allRecentSessions[indexPath.row].isTop;
    NSInteger msgfreeflag = self.allRecentSessions[indexPath.row].msgfreeflag;
    NSString *topText = top ? @"取消置顶" : @"置顶";
    NSString *msgfreeText = msgfreeflag==1?@"取消免打扰":@"消息免打扰";
    
    CBWeakSelf
    UIContextualAction *topAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:topText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CBStrongSelfElseReturn


        
        TIOSession *session = self.allRecentSessions[indexPath.row].session;
        
        [TIOChat.shareSDK.conversationManager topSession:session isTop:!top completon:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"error:%@",error);
            } else {
                NSLog(@"操作成功");
            }
        }];
    }];
    // 删除
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        CBStrongSelfElseReturn
        CBWeakSelf
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        TCheckBoxController *alert = [TCheckBoxController alertWithTitle:@"确定删除会话吗" items:@[@"同时删除聊天记录"]];
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            CBStrongSelfElseReturn
            [self confirmDelete:indexPath isClearMessage:alert.t_selected];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    // 投诉
    UIContextualAction *tipoffAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"投诉" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CBStrongSelfElseReturn
        [self tipoff:indexPath];
    }];
    
    UIContextualAction *msgfreeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:msgfreeText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CBStrongSelfElseReturn
        [self doNotDisturbtion:indexPath];
    }];

    BOOL isSelf = [self.allRecentSessions[indexPath.row].toUId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId];
    NSArray *items = isSelf ? @[deleteAction, msgfreeAction, topAction] : @[deleteAction, msgfreeAction, topAction, tipoffAction];
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:items];
    configuration.performsFirstActionWithFullSwipe = NO;

    return configuration;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    dispatch_async(dispatch_get_main_queue(), ^{

        // 如果confirmDeleteLabel存在 移除
//        if (self.confirmDeleteLabel) [self.confirmDeleteLabel removeFromSuperview];

        // 判断系统是否是 iOS13 及以上版本
        if (@available(iOS 13.0, *)) {
            for (UIView *subView in self.tableView.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] && [subView.subviews count] >= 1) {
                    // 修改图片
                    UIView *remarkContentView = subView.subviews.firstObject;
                    [self setupRowActionView:remarkContentView indexpath:indexPath iOS13:YES];
                }
            }
            return;
        }

        // 判断系统是否是 iOS11 及以上版本
        if (@available(iOS 11.0, *)) {
            for (UIView *subView in self.tableView.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subView.subviews count] >= 1) {
                    // 修改图片
                    UIView *remarkContentView = subView;
                    [self setupRowActionView:remarkContentView indexpath:indexPath iOS13:NO];
                }
            }
            return;
        }
    });

}

- (void)setupRowActionView:(UIView *)rowActionView indexpath:(NSIndexPath *)indexPath iOS13:(BOOL)ios13 {
    // 拿到按钮,设置图片
    
    if (rowActionView.subviews.count < 1) {
        return;
    }
    
//    BOOL isSelf = [self.allRecentSessions[indexPath.row].toUId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId];
    
    // 只要在此设定颜色顺序即可
    NSArray *colors = nil;
    if (rowActionView.subviews.count == 4) {
        colors = @[[UIColor colorWithHex:0xC7C7C7],UIColor.TDTheme_TabBarSelectedColor, [UIColor colorWithHex:0xFFA32A],UIColor.TDTheme_UnreadColor];
    } else {
        colors = @[UIColor.TDTheme_TabBarSelectedColor, [UIColor colorWithHex:0xFFA32A],UIColor.TDTheme_UnreadColor];
    }
    
    if (ios13) {
        if (rowActionView.subviews.count > 4) {
            return;
        }
        
        for (int i = 0; i < rowActionView.subviews.count; i++) {
            UIButton *button = rowActionView.subviews[i];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            
            for (id subView in button.subviews) {
                UIView *view = subView;
                view.backgroundColor = colors[i];
            }
            [button setBackgroundImage:[UIImage imageWithColor:colors[i]] forState:UIControlStateNormal];
        }
    } else {
        for (int i = 0; i < rowActionView.subviews.count; i++) {
            UIButton *button = rowActionView.subviews[i];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setBackgroundImage:[UIImage imageWithColor:colors[i]] forState:UIControlStateNormal];
        }
    }
}

- (UILabel *)confirmDeleteLabel
{
    if (!_confirmDeleteLabel) {
        _confirmDeleteLabel = [UILabel.alloc init];
        _confirmDeleteLabel.text = @"确认删除";
        _confirmDeleteLabel.font = [UIFont systemFontOfSize:16];
        _confirmDeleteLabel.textColor = UIColor.whiteColor;
        _confirmDeleteLabel.backgroundColor = UIColor.TDTheme_UnreadColor;
        _confirmDeleteLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _confirmDeleteLabel;
}


#pragma mark - actions

- (void)confirmDelete:(NSIndexPath *)indexPath isClearMessage:(BOOL)isClearMsg
{
    TIORecentSession *session = self.allRecentSessions[indexPath.row];
    
    [TIOChat.shareSDK.conversationManager deleteSession:session.session
                                         isClearMessage:isClearMsg
                                             completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            // 从数据源删除会话
            [self.allRecentSessions removeObjectAtIndex:indexPath.row];
            // 刷新
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }];
}

- (void)tipoff:(NSIndexPath *)indexPath
{
    TIORecentSession *session = self.allRecentSessions[indexPath.row];
    [TIOChat.shareSDK.conversationManager tipoffSession:session.sessionId complrtion:^(NSError * _Nullable error, id  _Nonnull data) {
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            [MBProgressHUD showInfo:@"投诉成功，等待后台审核" toView:self.view];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)doNotDisturbtion:(NSIndexPath *)indexPath
{
    NSString *uid, *teamid;
    NSInteger flag ;
    
    TIORecentSession *session = self.allRecentSessions[indexPath.row];
    flag = session.msgfreeflag==1?2:1;
    
    if (session.session.sessionType == TIOSessionTypeP2P) {
        uid = session.toUId;
    } else {
        teamid = session.toUId;
    }
    [TIOChat.shareSDK.conversationManager answerMessageNotificationForUid:uid orTeamid:teamid flag:flag completion:^(NSError * _Nullable error, id  _Nonnull data) {
        
    }];
}

- (void)toSearchMoudle:(id)sender
{
    [self.navigationController pushViewController:[CTMediator.sharedInstance T_searchViewController:nil] animated:YES];
}

- (void)toSearchModuleUserVC
{
    [self.navigationController pushViewController:[CTMediator.sharedInstance T_searchUserViewController:nil] animated:YES];
}

- (void)toCreatTeamModuleVC
{
    [self.navigationController pushViewController:[CTMediator.sharedInstance T_CreateTeam] animated:YES];
}

- (void)toScanQRVC
{
    PDCameraScanViewController *vc = [PDCameraScanViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 私有

- (NSMutableArray<TIORecentSession *> *)sortAllRecentSessions
{
    NSArray *array = [self.allRecentSessions sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TIORecentSession *item1 = obj1;
        TIORecentSession *item2 = obj2;
        
        //------- 优先处理置顶排序
        if (item2.isTop) {
            if (item1.isTop) {
                // 对置顶的消息再最新消息的时间排序
                if (item1.lastMessage.timestamp < item2.lastMessage.timestamp) {
                    return NSOrderedDescending;
                }
                if (item1.lastMessage.timestamp > item2.lastMessage.timestamp) {
                    return NSOrderedAscending;
                }
            }
            return NSOrderedDescending;
        }
        if (item1.isTop) {
            return NSOrderedAscending;
        }
        //-------!>
        
        // 再最新消息的时间排序
        if (item1.lastMessage.timestamp < item2.lastMessage.timestamp) {
            
            return NSOrderedDescending;
        }
        if (item1.lastMessage.timestamp > item2.lastMessage.timestamp) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    [self.allRecentSessions setArray:array];
    
    return [NSMutableArray arrayWithArray:array];
}

- (NSInteger)findInsertPlace:(TIORecentSession *)recentSession{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.allRecentSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TIORecentSession *item = obj;
        if (item.lastMessage.timestamp <= recentSession.lastMessage.timestamp) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.allRecentSessions.count;
    }
}

- (void)refreshTable
{
    [self.tableView reloadData];
}

#pragma mark- TIOConversationDelegate

/// 新增会话
- (void)didAddSession:(TIORecentSession *)recentSession
{
    /*
     此处代码采用刷新列表数据的d方法，对网络开销比较大，不建议使用，以上方代码的处理为准
     */
    /// 全局静音标志
    BOOL global_mutx = TIOChat.shareSDK.loginManager.userInfo.msgremindflag == 1;
    
    if (![TIOSessionActiveCenter.shareInstance isActive:recentSession.sessionId]) {
        if (recentSession.lastMessage.session.sessionType == TIOSessionTypeP2P) {
            
            if (global_mutx) {
                [TChatSound.shareInstance playPrivateMessageSound];
            }
        } else {
            if (global_mutx) {
                [TChatSound.shareInstance playTeamMessageSound];
            }
        }
    }
    
    [self.allRecentSessions addObject:recentSession];
    [self sortAllRecentSessions];
    [self refreshTable];
}

/// 更新会话
- (void)didUpdateSession:(TIORecentSession *)session
{
    dispatch_async(self.queue, ^{
//        NSLog(@"当前线程 ------> %d name: %@", NSThread.isMainThread, NSThread.callStackSymbols);
        __block NSInteger index = -1;
        
        [self.allRecentSessions enumerateObjectsUsingBlock:^(TIORecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.session.sessionId isEqualToString:session.session.sessionId]) {
                index = idx;
                *stop = YES;
            }
        }];
        
        if (index!= -1) {
            [self.allRecentSessions replaceObjectAtIndex:index withObject:session];
            [self sortAllRecentSessions];
            
            T_Dispatch_Async_Main(^{
//                [self refreshTable];
                
                if (![TIOSessionActiveCenter.shareInstance isActive:session.sessionId]) {
                    
                    /// 全局静音标识
                    BOOL global_mutx = TIOChat.shareSDK.loginManager.userInfo.msgremindflag == 1;
                    
                    // 未激活的会话 （非当前聊天的会话）收到新消息/更新消息
                    if (session.lastMessage.session.sessionType == TIOSessionTypeP2P) {

                        if (session.isUnread && session.msgfreeflag != 1 && global_mutx) {
                            // 消息是正常的未读状态 -> 响
                            [TChatSound.shareInstance playPrivateMessageSound];
                        }
                    } else {
                        if (session.msgfreeflag != 1 && global_mutx) {
                            [TChatSound.shareInstance playTeamMessageSound];
                        }
                    }
                }
            })
        }
    });
}

- (void)didDeleteSession:(NSString *)sessionId
{
    __block NSInteger index = -1;
    [self.allRecentSessions enumerateObjectsUsingBlock:^(TIORecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.session.sessionId isEqualToString:sessionId]) {
            index = idx;
            *stop = YES;
        }
    }];

    if (index != -1) {
        [self.allRecentSessions removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

// 被踢出群
- (void)didKickedOut:(TIOSystemNotification *)notification
{
    // 刷新数据
    [self requestData];
}
// 被重新拉进群
- (void)didRejoin:(TIOSystemNotification *)notification
{
    [self requestData];
}

- (void)didTopSession:(TIOSession *)session
{
    [self.allRecentSessions enumerateObjectsUsingBlock:^(TIORecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.session.sessionId isEqualToString:session.sessionId]) {
            obj.isTop = YES;
        }
    }];
    [self sortAllRecentSessions];   // 排序
    [self refreshTable];    // 刷新
}

- (void)didCancelTopSession:(TIOSession *)session
{
    [self.allRecentSessions enumerateObjectsUsingBlock:^(TIORecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.session.sessionId isEqualToString:session.sessionId]) {
            obj.isTop = NO;
        }
    }];
    [self sortAllRecentSessions];   // 排序
    [self refreshTable];    // 刷新
}

- (void)shouldUpdateLocalFromRemote
{
    self.title = @"接收中...";
}

- (void)didUpdateLocalFromRemote:(BOOL)isUpdate
{
    self.title = @"";
    if (isUpdate) {
        //在这写入要计算时间的代码
        [self requestData];
    }
}

- (void)didChangeUnreadCount:(NSInteger)total inSession:(nonnull TIORecentSession *)session
{
    dispatch_async(self.queue, ^{
        __block NSInteger index = -1;
        
        [self.allRecentSessions enumerateObjectsUsingBlock:^(TIORecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.session.sessionId isEqualToString:session.sessionId]) {
                index = idx;
                *stop = YES;
            }
        }];
        
    //    NSLog(@"更改会话小红点   %@，  红点数%zd",session.session.name,session.unReadCount);
        
        if (index!= -1) {
            [self.allRecentSessions replaceObjectAtIndex:index withObject:session];
            [self sortAllRecentSessions];
            T_Dispatch_Async_Main(^{
                [self refreshTable];
            })
        }
    });
}

- (void)didClearAllMessagesInSession:(TIOSession *)session
{
    dispatch_async(self.queue, ^{
//        NSLog(@"当前线程 ------> %d name: %@", NSThread.isMainThread, NSThread.callStackSymbols);
        __block NSInteger index = -1;
        
        [self.allRecentSessions enumerateObjectsUsingBlock:^(TIORecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.session.sessionId isEqualToString:session.sessionId]) {
                index = idx;
                obj.lastMessage.text = @"你清空了所有聊天消息";
                obj.lastMessage.messageType = TIOMessageTypeTip;
                obj.toReadFlag = 1;
                obj.atreadflag = 1;
                obj.isUnread = NO;
                obj.unReadCount = 0;
                *stop = YES;
            }
        }];
        
        if (index!= -1) {
            T_Dispatch_Async_Main(^{
                [self refreshTable];
            })
        }
    });
}

#pragma mark - TIOSystemNotification

- (void)onServerConnectChanged:(BOOL)connected
{
    if (connected) {
        self.title = @"";
    } else {
        self.title = @"（未连接）";
    }
}

#pragma mark - TIOTeamDelegate

- (void)didDeleteTeam:(TIOTeam *)team
{
    [self requestData];
}

- (void)didTransferedTeam:(TIOTeam *)team
{
    // TODO: 转让群通知待实现
}

- (void)didExitFromTeam:(TIOTeam *)team
{
    [self requestData];
}


@end
