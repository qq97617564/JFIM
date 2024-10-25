//
//  TDTeamListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamListViewController.h"
#import "TTeamCell.h"

#import "TAddPopupView.h"
#import "FrameAccessor.h"
#import "MBProgressHUD+NJ.h"
#import "UIButton+Enlarge.h"
#import "UIImage+TColor.h"
#import "TInputAlertController.h"

#import "CTMediator+ModuleActions.h"
#import "PDCameraScanViewController.h"

#import "ImportSDK.h"

@interface TTeamListViewController () <UITableViewDelegate,UITableViewDataSource, TIOTeamDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *teams;
@property (strong, nonatomic) TIOLoginUser *myUserInfor;
@end

@implementation TTeamListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBar];
    [self addTableView];
    
    [self addDelegate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)dealloc
{
    [self removeDelegate];
}

- (void)addDelegate
{
    [TIOChat.shareSDK.teamManager addDelegate:self];
}

- (void)removeDelegate
{
    [TIOChat.shareSDK.teamManager removeDelegate:self];
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
    searchBtn.left = 5;
    [searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toSearchMoudle:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:searchBtn];
    
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectZero];
    titleLabel.text = @"群聊";
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    [titleLabel sizeToFit];
    titleLabel.centerX = ScreenWidth()*0.5;
    titleLabel.centerY = Height_StatusBar + 44*0.5;
    [self.navigationBar addSubview:titleLabel];
    
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
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 60;
    tableView.separatorInset = UIEdgeInsetsMake(0, 81, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE9E9E9];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [tableView registerClass:[TTeamCell class] forCellReuseIdentifier:NSStringFromClass(TTeamCell.class)];
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectZero];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];

    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchAllTeams:^(NSArray<TIOTeam *> * _Nullable teams, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"群聊列表错误信息:%@",error.localizedDescription);
        }
        else
        {
            self.teams = teams;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TTeamCell.class)
    forIndexPath:indexPath];
    
    TIOTeam *team = self.teams[indexPath.row];

    cell.nickLabel.text = team.name;
    [cell setAvatarUrl:team.avatar];
    cell.countLabel.text = [NSString stringWithFormat:@"%zd人", team.memberNumber];
    cell.role = team.grouprole;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teams.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOTeam *team = self.teams[indexPath.row];
    
    // 获取会话ID
    [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeTeam
                                              friendId:team.teamId
                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable recentSession) {
        if (error) {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            // 跳转聊天
            TIOSession *session = recentSession.session;
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:session forKey:@"session"];
//            [CTMediator.sharedInstance T_remoteToTeamSessionVC:params fromVC:self];
            UIViewController *vc = [CTMediator.sharedInstance T_TeamViewController:params];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 44)];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    UILabel *label = [UILabel.alloc initWithFrame:view.bounds];
    label.textColor = [UIColor colorWithHex:0xBEBEBE];
    label.font = [UIFont systemFontOfSize:12];
    label.text = [NSString stringWithFormat:@"%zd个群聊",self.teams.count];
    [label sizeToFit];
    label.center = view.middlePoint;
    [view addSubview:label];
    
    UIView *line1 = [UIView.alloc initWithFrame:CGRectMake(0, 0, 48, 1)];
    line1.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
    line1.centerY = view.middleY;
    line1.right = label.left - 8;
    [view addSubview:line1];
    
    UIView *line2 = [UIView.alloc initWithFrame:CGRectMake(0, 0, 48, 1)];
    line2.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
    line2.centerY = view.middleY;
    line2.left = label.right + 8;
    [view addSubview:line2];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

#pragma mark 左滑手势

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
API_AVAILABLE(ios(11.0)){
    
    TIOTeam *team = self.teams[indexPath.row];
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"退出群聊" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定退出群聊？" preferredStyle:TAlertControllerStyleAlert];
        [alert addAction:[TAlertAction actionWithTitle:@"不退出" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"退出" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            // 退群操作API
            [TIOChat.shareSDK.teamManager exitFromTeam:team.teamId completion:^(NSError * _Nullable error) {
            }];
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    
    UIContextualAction *changeNameAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"修改群名" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        TInputAlertController *alert = [TInputAlertController alertWithTitle:@"新群名" placeholder:@"新群名" inputHeight:40 inputStyle:TAlertInputStyleTextField];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {

            }];

            action;
        })];

        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                // SDK 修改群名API
                [TIOChat.shareSDK.teamManager updateTeamName:alert.text inTeam:team.teamId completion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"error:%@",error);
                    }
                }];
            }];

            action;
        })];
        [self presentViewController:alert animated:YES completion:nil];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    
    UIContextualAction *shareAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"分享群聊" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        // SDK 检查名片是否可以分享
        [TIOChat.shareSDK.teamManager checkTeam:team.teamId canSendCardWithCompletion:^(NSError * _Nullable error) {
            if (error)
            {
                [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
            }
            else
            {
                // 可以分享
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                params[@"type"] = @(1);
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
                    [TIOChat.shareSDK.teamManager shareTeam:team.teamId toUids:toUids toTeamIds:toTeamIds completion:^(NSError * _Nullable error) {
                        if (error) {
                            [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
                        }
                    }];
                    
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    
    NSArray *actions ;
    
    if (team.grouprole == TIOTeamUserRoleManager || team.grouprole == TIOTeamUserRoleManager) {
        actions = @[changeNameAction, shareAction];
    } else {
        actions = @[deleteAction, shareAction];
    }
    
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:actions];
    configuration.performsFirstActionWithFullSwipe = NO;

    return configuration;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    dispatch_async(dispatch_get_main_queue(), ^{

        // 判断系统是否是 iOS13 及以上版本
        if (@available(iOS 13.0, *)) {
            for (UIView *subView in self.tableView.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] && [subView.subviews count] >= 1) {
                    // 修改图片
                    UIView *remarkContentView = subView.subviews.firstObject;
                    [self setupRowActionView:remarkContentView iOS13:YES];
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
                    [self setupRowActionView:remarkContentView iOS13:NO];
                }
            }
            return;
        }
    });

}

- (void)setupRowActionView:(UIView *)rowActionView iOS13:(BOOL)ios13 {
    // 拿到按钮,设置图片
    UIButton *topButton = rowActionView.subviews[0];
    UIButton *deleteButton = rowActionView.subviews[1];
    
    topButton.titleLabel.font = [UIFont systemFontOfSize:16];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    if (ios13) {
        for (id subView in topButton.subviews) {
            if ([subView isMemberOfClass:[UIView class]]) {
                UIView *view = subView;
                view.backgroundColor = UIColor.TDTheme_TabBarSelectedColor;
            }
        }
        [topButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_TabBarSelectedColor] forState:UIControlStateNormal];
        
        for (id subView in deleteButton.subviews) {
            if ([subView isMemberOfClass:[UIView class]]) {
                UIView *view = subView;
                view.backgroundColor = UIColor.TDTheme_UnreadColor;
            }
        }
        [deleteButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_UnreadColor] forState:UIControlStateNormal];
    } else {
        [topButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_TabBarSelectedColor] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_UnreadColor] forState:UIControlStateNormal];
    }
}

#pragma mark -

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

- (TIOLoginUser *)myUserInfor
{
    if (!_myUserInfor) {
        _myUserInfor = [TIOChat.shareSDK.loginManager userInfo];
    }
    return _myUserInfor;
}

#pragma mark - TIOTeamDelegate

/// 已删除解散群
- (void)didDeleteTeam:(TIOTeam  * _Nullable )team
{
    // 不建议直接刷新网络接口，因为team里一定有teamId
//    [self requestData];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.teams];
    
    NSInteger index = -1;
    
    for (int i = 0; i<self.teams.count; i++) {
        TIOTeam *t = _teams[i];

        if ([t.teamId isEqualToString:team.teamId]) {
            [array removeObjectAtIndex:i];
            index = i;
        }
    }

    self.teams = array;

    if (index> -1) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
/// 已退群
- (void)didExitFromTeam:(TIOTeam  * _Nullable )team
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.teams];
    
    NSInteger index = -1;
    
    for (int i = 0; i<self.teams.count; i++) {
        TIOTeam *t = _teams[i];

        if ([t.teamId isEqualToString:team.teamId]) {
            [array removeObjectAtIndex:i];
            index = i;
        }
    }

    self.teams = array;

    if (index> -1) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
/// 被踢出群
- (void)didKickedOut:(TIOSystemNotification *)notification
{
    [self requestData];
}
/// 群新发生变动
- (void)didUpdateTeamInfo:(TIOTeam *)team
{
//    NSMutableArray *array = [NSMutableArray arrayWithArray:self.teams];
//    for (int i = 0; i<self.teams.count; i++) {
//        TIOTeam *t = _teams[i];
//
//        if ([t.teamId isEqualToString:team.teamId]) {
//            t.name = team.name;
//        }
//    }
//
//    self.teams = array;
//
//    [self.tableView reloadData];
    
    // 上面处理更高效，但是群信息不止群名一项，所以建议直接重新刷新,以为群信息变更不是一个频率很高的操作
    [self requestData];
}

@end
