//
//  TTeamTransferViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamTransferViewController.h"
#import "TTeamTransferViewController.h"
#import "FrameAccessor.h"
#import "TSortString.h"
#import "UITableView+SCIndexView.h"
#import "ImportSDK.h"
#import "TTeamInviteModel.h"
#import "TTeamTransferCell.h"
#import "TInputAlertController.h"
#import "TAlertController.h"
#import "MBProgressHUD+NJ.h"
#import <MJRefresh.h>

@interface TTeamTransferViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation TTeamTransferViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.title = @"选择新群主";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self addTableView];
    [self requestData];
}

/// 获取数据
- (void)requestData
{
    [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.teamId searchKey:nil pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last, NSInteger total, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            NSString *selfUid = TIOChat.shareSDK.loginManager.userInfo.userId;
            // 剔除自己
            NSMutableArray *tempUsers = [NSMutableArray arrayWithCapacity:teamUsers.count];
            for (TIOTeamMember *user in teamUsers) {
                if ([user.uid isEqualToString:selfUid]) continue;
                [tempUsers addObject:user];
            }
            self.dataArray = tempUsers;
            self.tableView.mj_footer.hidden = tempUsers.count == 0;
            
            if (last) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)beginLoadingMore:(id)sender
{
    [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.teamId searchKey:nil pageNumber:self.dataArray.count/100+1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last, NSInteger total,  NSError * _Nullable error) {
        [self.tableView.mj_footer endRefreshing];
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            self.dataArray = [self.dataArray arrayByAddingObjectsFromArray:teamUsers];
            self.tableView.mj_footer.hidden = teamUsers.count == 0;
            
            if (last) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
        }
    }];
}


/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar - Height_TabBar) style:UITableViewStylePlain];
    tableView.sectionIndexColor = [UIColor colorWithHex:0x909090];
    tableView.sectionIndexMinimumDisplayRowCount = 6;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TTeamTransferCell class] forCellReuseIdentifier:NSStringFromClass(TTeamTransferCell.class)];
    tableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部成员 —" forState:MJRefreshStateNoMoreData];
        [footer setRefreshingTarget:self refreshingAction:@selector(beginLoadingMore:)];
        
        footer;
    });
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
//    UIView *tableHeaderView = ({
//        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 60)];
//        
//        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        searchButton.frame = CGRectMake(16, 10, view.width - 32, 36);
//        searchButton.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
//        searchButton.layer.cornerRadius = 18;
//        searchButton.layer.masksToBounds = YES;
//        searchButton.adjustsImageWhenHighlighted = NO;
//        searchButton.titleLabel.font = [UIFont systemFontOfSize:16];
//        [searchButton setTitle:@"  搜索" forState:UIControlStateNormal];
//        [searchButton setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
//        [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
//        [searchButton addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:searchButton];
//        
//        view;
//    });
//    tableView.tableHeaderView = tableHeaderView;
}

- (void)toSearch:(id)sender
{
   
}

- (void)refreshList
{
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTeamTransferCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TTeamTransferCell.class) forIndexPath:indexPath];
    
    TIOTeamMember *user = self.dataArray[indexPath.row];
    
//    if ([user.groupId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
//        [cell setNick:[NSString stringWithFormat:@"%@(自己) ",user.nick]];
//    } else {
        [cell setNick:user.nick];
//    }
    
    [cell setAvatarUrl:user.avatar];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOTeamMember *member = self.dataArray[indexPath.row];
    
    TIOLoginUser *selfUser = [TIOChat.shareSDK.loginManager userInfo];
    
    if ([member.uid isEqualToString:selfUser.userId]) {
        return;
    }
    
    NSString *msg = [NSString stringWithFormat:@"确定选择 %@ 为新群主？你将自动转为普通成员",member.nick];
    
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:msg preferredStyle:TAlertControllerStyleAlert];
    
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        
        [TIOChat.shareSDK.teamManager transferTeam:self.teamId toUser:member.uid completion:^(NSError * _Nullable error) {
            if (error)
            {
                [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
            }
            else
            {
                [MBProgressHUD showInfo:@"转让成功" toView:self.view];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
