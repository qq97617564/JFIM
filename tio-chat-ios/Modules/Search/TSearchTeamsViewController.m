//
//  TSearchTeamsViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchTeamsViewController.h"
#import "TSearchFriendCell.h"
#import "CTMediator+ModuleActions.h"
/// pods
#import "FrameAccessor.h"
#import <MJRefresh.h>
/// SDK
#import "ImportSDK.h"

@interface TSearchTeamsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *friendsDataArray;
@end

@implementation TSearchTeamsViewController

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
    [TIOChat.shareSDK.teamManager searchMyTeamsWithKey:self.searchKey
                                            completion:^(NSArray<TIOTeam *> * _Nullable users, NSError * _Nullable error) {
                                                CBStrongSelfElseReturn
                                                
                                                if (!error) {
                                                    self.friendsDataArray = users;
                                                    
                                                    self.tableView.mj_footer.hidden = users.count == 0;
                                                    
                                                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                                    
                                                    [self.tableView reloadData];
                                                } else {
                                                    DDLogError(@"%@",error);
                                                    self.searchKey = @"";
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
    
    TIOTeam *user = self.friendsDataArray[indexPath.row];
    [cell refreshAvatar:user.avatar nick:user.name remark:[NSString stringWithFormat:@"%zd",user.memberNumber] key:self.searchKey];
    cell.flag.hidden = true;
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOTeam *team = self.friendsDataArray[indexPath.row];
    
    if (team.teamId) {
        CBWeakSelf
        // 获取会话ID
        [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeTeam
                                                  friendId:team.teamId
                                                completion:^(NSError * _Nullable error, TIORecentSession * _Nullable recentSession) {
            CBStrongSelfElseReturn
            if (error) {
            } else {
                // 跳转聊天
                TIOSession *session = recentSession.session;
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:session forKey:@"session"];
                UIViewController *vc = [CTMediator.sharedInstance T_TeamViewController:params];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

#pragma mark - overwrite

- (void)clearSearchResult
{
    self.friendsDataArray = @[];
}

@end
