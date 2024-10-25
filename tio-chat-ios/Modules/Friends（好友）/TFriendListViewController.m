//
//  TDFriendListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TFriendListViewController.h"
#import "TFriendCell.h"
#import "TNewFriendsViewController.h"
#import "TUserHomePageViewController.h"
#import "TShareFriendCardListViewController.h"

#import "TAddPopupView.h"
#import "TSortString.h"
#import "NSString+T_HTTP.h"
#import "UITableView+SCIndexView.h"
#import "FrameAccessor.h"
#import "UIButton+Enlarge.h"
#import "UIImage+TColor.h"
#import "TAlertController.h"
#import "PDCameraScanViewController.h"
/// SDK
#import "ImportSDK.h"

#import "CTMediator+ModuleActions.h"

// 两种排序方式 1拼音 0系统
#define Sort1 1

@interface TFriendListViewController () <UITableViewDelegate,UITableViewDataSource, TIOFriendDelegate, TIOSystemDelegate>
@property (weak,   nonatomic) UITableView   *tableView;
@property (weak,   nonatomic) UILabel *totalFriendsLabel;
@property (strong, nonatomic) NSMutableArray    *allFriends;     // 排序前的数据源
@property (strong, nonatomic) NSDictionary  *sortedfriends;  // 排序后的数据源
@property (strong, nonatomic) NSArray   *titleOfIndexes;
@property (copy,   nonatomic) NSString  *applyMsg;

@property (assign, nonatomic) NSInteger applyCount; // 新增的好友申请，调用fetchNewApply自己记录

@end

@implementation TFriendListViewController

- (void)dealloc
{
    [TIOChat.shareSDK.friendManager removeDelegate:self];
    [TIOChat.shareSDK.systemManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBar];
    [self addTableView];
    
    [self requestData];
    [TIOChat.shareSDK.friendManager addDelegate:self];
    [TIOChat.shareSDK.systemManager addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CBWeakSelf
    // 获取好友请求数量
    [TIOChat.shareSDK.friendManager fetchNewApplyListWithCompletion:^(NSInteger newApplyCount, NSError * _Nullable error) {
        
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            if (newApplyCount != 0) {
                self.applyCount = newApplyCount;
                [self refreshNewApplyMsg:[NSString stringWithFormat:@"%zd", newApplyCount]];
            }
        }
        
    }];
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
    titleLabel.text = @"好友";
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
    tableView.sectionIndexColor = [UIColor colorWithHex:0x909090];
    tableView.sectionIndexMinimumDisplayRowCount = 6;
    tableView.backgroundColor = [UIColor colorWithHex:0xF2F2F2];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 77, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE9E9E9];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [tableView registerClass:[TFriendCell class] forCellReuseIdentifier:NSStringFromClass(TFriendCell.class)];
    [self.view addSubview:tableView];
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView = tableView;
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
    configuration.indexItemRightMargin = 16;
    configuration.indicatorRightMargin = 50;
    configuration.indicatorHeight = 65;
    configuration.indexItemSelectedTextColor = [UIColor colorWithHex:0x4C94E8];
    configuration.indexItemTextColor = [UIColor colorWithHex:0x909090];
    configuration.indexItemSelectedBackgroundColor = UIColor.clearColor;
    configuration.indicatorTextFont = [UIFont systemFontOfSize:12];
    configuration.indicatorTextFont = [UIFont systemFontOfSize:20];
    tableView.sc_indexViewConfiguration = configuration;
    tableView.sc_translucentForTableViewInNavigationBar = NO;
    tableView.sc_startSection = 1;
}

/// 获取数据
- (void)requestData
{
    CBWeakSelf
    NSLog(@"---------------开始获取好友列表");
    [TIOChat.shareSDK.friendManager fetchMyFriends:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
        NSLog(@"---------------已经获取好友列表,开始排序");
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            
            self.allFriends = [NSMutableArray arrayWithArray:users];
            
#ifdef Sort1
            [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick" callback:^(NSMutableDictionary * _Nonnull sortDic) {
                self.sortedfriends = sortDic;
                NSLog(@"排序完成,开始刷新列表显示");
                [self refreshList];
            }];
#else
            [TSortString sortObjectsAccordingToInitialWith:users SortKey:@"nick" callback:^(NSDictionary * _Nonnull sortDic) {
                self.sortedfriends = sortDic;
                [self refreshList];
            }];
            
#endif
            
//            self.sortedfriends = [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick"];
        }
        
    }];
    
    // 获取好友请求数量
    [TIOChat.shareSDK.friendManager fetchNewApplyListWithCompletion:^(NSInteger newApplyCount, NSError * _Nullable error) {
        
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            if (newApplyCount != 0) {
                self.applyCount = newApplyCount;
                [self refreshNewApplyMsg:[NSString stringWithFormat:@"%zd", newApplyCount]];
            }
        }
        
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TFriendCell.class)
                                                            forIndexPath:indexPath];
        [cell setNick:@"新的朋友"];
        [cell setDetail:self.applyMsg];
        cell.imageView.image = [UIImage imageNamed:@"newlyFriend"];
        return cell;
    }
    
#ifdef  Sort1
    TIOUser *user = self.sortedfriends[self.titleOfIndexes[indexPath.section-1]][indexPath.row];
#else
    NSArray *arr = self.sortedfriends[CYPinyinGroupResultArray];
    TIOUser *user = arr[indexPath.section-1][indexPath.row];
#endif
    
    TFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TFriendCell.class)
                                                        forIndexPath:indexPath];
//    if ([user.userId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
//        [cell setNick:[NSString stringWithFormat:@"%@(自己) ",user.nick]];
//    } else {
        if (user.remarkname.length) {
            [cell setNick:user.remarkname];
        } else {
            [cell setNick:user.nick];
        }
//    }
    
    [cell setDetail:nil];
    
    [cell setAvatarUrl:user.avatar.resourceURLString];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleOfIndexes.count + 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    
#ifdef Sort1
    NSArray *array = self.sortedfriends[self.titleOfIndexes[section-1]];
#else
    NSArray *arr = self.sortedfriends[CYPinyinGroupResultArray];
    NSArray *array = arr[section-1];
    
#endif
    return array.count;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 30)];
    view.backgroundColor = tableView.backgroundColor;
    UILabel *label = [UILabel.alloc init];
    label.text = self.titleOfIndexes[section-1];
    label.textColor = [UIColor colorWithHex:0xC1C1C1];
    label.font = [UIFont systemFontOfSize:14.f];
    [label sizeToFit];
    label.left = 16;
    label.centerY = view.middleY;
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 44)];
        view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        UILabel *label = [UILabel.alloc initWithFrame:view.bounds];
        label.textColor = [UIColor colorWithHex:0xBEBEBE];
        label.font = [UIFont systemFontOfSize:12];
        label.text = [NSString stringWithFormat:@"%zd位联系人",self.allFriends.count];
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
    return [UIView.alloc init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0.01 : 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 0 ? 44 : 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        TNewFriendsViewController *vc = [TNewFriendsViewController.alloc init];
        [self.navigationController pushViewController:vc animated:YES];
        self.applyCount = 0;
        [self refreshNewApplyMsg:nil];
        self.tabBarController.viewControllers[1].tabBarItem.badgeValue = nil;
    } else {
        
#ifdef Sort1
        TIOUser *user = self.sortedfriends[self.titleOfIndexes[indexPath.section-1]][indexPath.row];
#else
        NSArray *arr = self.sortedfriends[CYPinyinGroupResultArray];
        TIOUser *user = arr[indexPath.section-1][indexPath.row];
#endif
        
        BOOL isSelf = [user.userId isEqualToString:[TIOChat.shareSDK.loginManager userInfo].userId];
        
        TUserHomePageViewController *vc = [TUserHomePageViewController.alloc initWithUser:user type:isSelf?TUserInfoVCTypeSelf:TUserInfoVCTypeFriend];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 左滑手势

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
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
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        
#ifdef Sort1
        TIOUser *user = self.sortedfriends[self.titleOfIndexes[indexPath.section-1]][indexPath.row];
#else
        NSArray *arr = self.sortedfriends[CYPinyinGroupResultArray];
        TIOUser *user = arr[indexPath.section-1][indexPath.row];
#endif
        
        [self alertDeleteUser:user];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    
    UIContextualAction *cardAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"推给别人" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
#ifdef Sort1
        TIOUser *user = self.sortedfriends[self.titleOfIndexes[indexPath.section-1]][indexPath.row];
#else
        NSArray *arr = self.sortedfriends[CYPinyinGroupResultArray];
        TIOUser *user = arr[indexPath.section-1][indexPath.row];
#endif
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
            
            [TIOChat.shareSDK.friendManager shareUser:user.userId toUids:toUids toTeamIds:toTeamIds completion:^(NSError * _Nullable error) {
                if (error)
                {
                    NSLog(@"error:%@",error);
                    [viewController.navigationController popViewControllerAnimated:YES];
                } else {
                    NSLog(@"发送成功");
                }
            }];
        };
        [self.navigationController pushViewController:vc animated:YES];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction , cardAction]];
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

- (void)alertDeleteUser:(TIOUser *)user
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定要删除该好友？" preferredStyle:TAlertControllerStyleAlert];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"删除" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        CBWeakSelf
        [TIOChat.shareSDK.friendManager deleteFriend:user.userId completion:^(NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error) {
                NSLog(@"error:%@",error);
            } else {
                NSLog(@"成功删除 %@",user.remarkname?:user.nick);
            }
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TIOFriendDelegate

- (void)onRecieveSystemNotification:(TIOSystemNotification *)notification
{
    /*
     1⃣️ 收到新增好友申请
     2⃣️ 新增好友、好友信息变更：刷新通讯录并重新排序
     */
    if (notification.type == TIOSystemNotificationTypeFriendApply) {
        self.applyCount++;
        [self refreshNewApplyMsg:[NSString stringWithFormat:@"%zd", self.applyCount]];
    } else if (notification.type == TIOSystemNotificationTypeFriendAdd || notification.type == TIOSystemNotificationTypeFriendUpdate) {
        CBWeakSelf
        [TIOChat.shareSDK.friendManager fetchMyFriends:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self.allFriends = [NSMutableArray arrayWithArray:users];
//                self.sortedfriends = [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick"];
#ifdef Sort1
                [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick" callback:^(NSMutableDictionary * _Nonnull sortDic) {
                    self.sortedfriends = sortDic;
                    NSLog(@"排序完成,开始刷新列表显示");
                    [self refreshList];
                }];
#else
                [TSortString sortObjectsAccordingToInitialWith:users SortKey:@"nick" callback:^(NSDictionary * _Nonnull sortDic) {
                    self.sortedfriends = sortDic;
                    [self refreshList];
                }];
#endif
            }
        }];
    } else if (notification.type == TIOSystemNotificationTypeFriendDelete) {
        
        CBWeakSelf
        [TIOChat.shareSDK.friendManager fetchMyFriends:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self.allFriends = [NSMutableArray arrayWithArray:users];
//                self.sortedfriends = [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick"];
#ifdef Sort1
                [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick" callback:^(NSMutableDictionary * _Nonnull sortDic) {
                    self.sortedfriends = sortDic;
                    NSLog(@"排序完成,开始刷新列表显示");
                    [self refreshList];
                }];
#else
                [TSortString sortObjectsAccordingToInitialWith:users SortKey:@"nick" callback:^(NSDictionary * _Nonnull sortDic) {
                    self.sortedfriends = sortDic;
                    [self refreshList];
                }];
#endif
            }
        }];
    }
}

/// 好友被删除
- (void)didDeleteFriend:(TIOUser *)user
{
    // TODO: 更新本地通讯录
    for (TIOUser *localUser in self.allFriends) {
        if ([user.userId isEqualToString:localUser.userId]) {
            [self.allFriends removeObject:localUser];
            break;
        }
    }

//    self.sortedfriends = [TSortString sortAndGroupForArray:self.allFriends PropertyName:@"remarkname" nextPropertyName:@"nick"];
    
#ifdef Sort1
    [TSortString sortAndGroupForArray:self.allFriends PropertyName:@"remarkname" nextPropertyName:@"nick" callback:^(NSMutableDictionary * _Nonnull sortDic) {
        self.sortedfriends = sortDic;
        NSLog(@"排序完成,开始刷新列表显示");
        [self refreshList];
    }];
#else
    [TSortString sortObjectsAccordingToInitialWith:self.allFriends SortKey:@"nick" callback:^(NSDictionary * _Nonnull sortDic) {
        self.sortedfriends = sortDic;
        [self refreshList];
    }];
#endif
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

- (void)refreshNewApplyMsg:(NSString  * _Nullable)msg
{
    // tabbar 显示好友
    self.tabBarController.viewControllers[1].tabBarItem.badgeValue = self.applyCount ? @(self.applyCount).stringValue : nil;
    
    self.applyMsg = msg;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshList
{

#ifdef Sort1
    self.titleOfIndexes = [TSortString sortForStringAry:self.sortedfriends.allKeys];
#else
    self.titleOfIndexes = self.sortedfriends[CYPinyinGroupCharArray];
#endif
    self.tableView.sc_indexViewDataSource = self.titleOfIndexes;
    
    [self.tableView reloadData];
}

@end
