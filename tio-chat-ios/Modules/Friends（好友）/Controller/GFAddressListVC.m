//
//  GFAddressListVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFAddressListVC.h"
#import "TFriendListViewController.h"
#import "GFAddressListCell.h"

#import "TNewFriendsViewController.h"
#import "TTeamListViewController.h"

#import "GFUserInfoVC.h"
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

@interface GFAddressListVC () <UITableViewDelegate,UITableViewDataSource, TIOFriendDelegate, TIOSystemDelegate>
@property (weak,   nonatomic) UITableView   *tableView;
@property (weak,   nonatomic) UILabel *totalFriendsLabel;
@property (strong, nonatomic) NSMutableArray    *allFriends;     // 排序前的数据源
@property (strong, nonatomic) NSDictionary  *sortedfriends;  // 排序后的数据源
@property (strong, nonatomic) NSArray   *titleOfIndexes;
@property (copy,   nonatomic) NSString  *applyMsg;

@property (strong, nonatomic) NSArray   *icons;
@property (strong, nonatomic) NSArray   *titles;

@property (assign, nonatomic) NSInteger applyCount; // 新增的好友申请，调用fetchNewApply自己记录

@end

@implementation GFAddressListVC

- (void)dealloc
{
    [TIOChat.shareSDK.friendManager removeDelegate:self];
    [TIOChat.shareSDK.systemManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.icons = @[@[@"Group 1321315351",@"Group 1321315492"],@[@"Group 1321315359",@"Group 1321315493"]];
    self.titles = @[@[@"好友申请",@"群通知"],@[@"我的好友",@"我的群组"]];
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
    searchBtn.right = ScreenWidth() - 50;
    [searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toSearchMoudle:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:searchBtn];
    
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectZero];
    titleLabel.text = @"好友";
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    [titleLabel sizeToFit];
    titleLabel.left = 15;
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
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar - Height_TabBar) style:UITableViewStyleGrouped];
    tableView.sectionIndexColor = [UIColor colorWithHex:0x909090];
    tableView.sectionIndexMinimumDisplayRowCount = 6;
    tableView.backgroundColor = [UIColor colorWithHex:0xF2F2F2];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorInset = UIEdgeInsetsMake(0, 77, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE9E9E9];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];

    [tableView registerNib:[UINib nibWithNibName:@"GFAddressListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GFAddressListCell"];
    [self.view addSubview:tableView];
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView = tableView;
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
    configuration.indexItemRightMargin = 16;
    configuration.indicatorRightMargin = 50;
    configuration.indicatorHeight = 65;
    configuration.indexItemSelectedTextColor = [UIColor colorWithHex:0x0087FC];
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
    NSArray *titls = self.titles[indexPath.section];
    NSArray *icons = self.icons[indexPath.section];
    GFAddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFAddressListCell" forIndexPath:indexPath];
    cell.titleL.text = titls[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:icons[indexPath.row]];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.num = self.applyCount;
    }else{
        cell.num = 0;
    }
    

    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.titles.count;

}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.titles[section];
    return arr.count;

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView.alloc init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TNewFriendsViewController *vc = [TNewFriendsViewController.alloc init];
            [self.navigationController pushViewController:vc animated:YES];
            self.applyCount = 0;
            [self refreshNewApplyMsg:nil];
            self.tabBarController.viewControllers[1].tabBarItem.badgeValue = nil;
        }else{
            
        }

    }else if (indexPath.section == 1){
        if (indexPath.row == 0 ) {
            TFriendListViewController *vc = [[TFriendListViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            TTeamListViewController *vc = [[TTeamListViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
