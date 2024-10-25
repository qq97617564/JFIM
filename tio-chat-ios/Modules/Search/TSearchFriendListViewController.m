//
//  TSearchFriendListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchFriendListViewController.h"
#import "TSearchFriendCell.h"
#import "CTMediator+ModuleActions.h"
/// pods
#import "FrameAccessor.h"
#import <MJRefresh.h>
#import <YYModel/NSObject+YYModel.h>
/// SDK
#import "ImportSDK.h"

@interface TSearchFriendListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *friendsDataArray;
@end

@implementation TSearchFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
}

- (void)setupUI
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:TSearchFriendCell.class forCellReuseIdentifier:NSStringFromClass(TSearchFriendCell.class)];
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 12)];
    tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部搜索结果 —" forState:MJRefreshStateNoMoreData];
        [footer setRefreshingTarget:self refreshingAction:@selector(beginLoadingMore:)];
        
        footer;
    });
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)beginRefreshing:(id)sender
{
    CBWeakSelf
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.searchText = self.searchKey; // 搜索内容
    option.scope = TIOSearchContentScopeTeam;
    
    [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option
                                                 completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (!error) {
            self.friendsDataArray = users;
            
            self.tableView.mj_footer.hidden = users.count == 0;
            
            if (lastPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.tableView reloadData];
        } else {
            DDLogError(@"%@",error);
            self.searchKey = @"";
        }
    }];
}

- (void)beginLoadingMore:(id)sender
{
    CBWeakSelf
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.searchText = self.searchKey; // 搜索内容
    option.pageNumber = self.friendsDataArray.count/20+1;  // 查询的批次（页码）
    
    [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option
                                                 completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        [self.tableView.mj_footer endRefreshing];
        
        if (!error) {
            
            self.friendsDataArray = [self.friendsDataArray arrayByAddingObjectsFromArray:users];
            
            self.tableView.mj_footer.hidden = users.count == 0;
            
            if (lastPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.tableView reloadData];
            
        } else {
            DDLogError(@"%@",error);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.friendsDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    TSearchFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TSearchFriendCell.class)];
    
    TIOUser *user = self.friendsDataArray[indexPath.row];
    [cell refreshAvatar:user.avatar nick:user.nick remark:user.remarkname key:self.searchKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOUser *user = self.friendsDataArray[indexPath.row];
    
    if (user.userId) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        params[@"user"] = user.yy_modelCopy;
        params[@"type"] = @(1); // 好友
        
        UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
        [self.navigationController pushViewController:homePageVC animated:YES];
    }
}

#pragma mark - overwrite

- (void)clearSearchResult
{
    self.friendsDataArray = @[];
}

@end
