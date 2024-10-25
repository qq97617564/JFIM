//
//  TSearchAllViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchAllViewController.h"
#import "TSearchFriendCell.h"
#import "SearchAllResult.h"
/// common
#import "JXCategoryView.h"
#import "CTMediator+ModuleActions.h"
/// pods
#import "FrameAccessor.h"
#import <MJRefresh.h>
#import <YYModel/NSObject+YYModel.h>
/// SDK
#import "ImportSDK.h"


@interface TSearchAllViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<SearchAllResult *> *dataArray;
@end

@implementation TSearchAllViewController

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
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 12)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:TSearchFriendCell.class forCellReuseIdentifier:NSStringFromClass(TSearchFriendCell.class)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - overwrite

- (void)clearSearchResult {}

- (void)refreshWithData:(NSArray *)dataArray
{
    self.dataArray = dataArray;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SearchAllResult *result = self.dataArray[indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.dataArray[indexPath.section].identifier];
    NSString *methodString = @"refreshAvatar:nick:remark:key:";
    SEL refreshSelector = NSSelectorFromString(methodString);
    
    if ([result.childList.firstObject isKindOfClass:NSClassFromString(@"TIOUser")]) {
        TIOUser *model = result.childList[indexPath.row];
        ((void(*)(id,SEL,id,id,id,id))objc_msgSend)(cell, refreshSelector, model.avatar, model.nick, model.remarkname, self.searchKey);
    } else {
        TIOTeam *model = result.childList[indexPath.row];
        ((void(*)(id,SEL,id,id,id,id))objc_msgSend)(cell, refreshSelector, model.avatar, model.name, [NSString stringWithFormat:@"%zd",model.memberNumber], self.searchKey);
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray[section].childList.count <= self.dataArray[section].showNumber ? self.dataArray[section].childList.count : self.dataArray[section].showNumber;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 35)];
    view.backgroundColor = UIColor.whiteColor;
    UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(16, 12, 60, 20)];
    label.text = self.dataArray[section].title;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHex:0x999999];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.viewSize = CGSizeMake(70, 20);
    moreButton.centerY = label.centerY;
    moreButton.right = view.width - 16;
    moreButton.tag = self.dataArray[section].index + 1000;
    moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [moreButton setTitle:self.dataArray[section].moreTitle forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(toDetailResultVC:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:moreButton];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchAllResult *result = self.dataArray[indexPath.section];
    id model = result.childList[indexPath.row];
    
    if ([model isKindOfClass:TIOUser.class])
    {
        TIOUser *user = (TIOUser *)model;
        
        if (user.userId) {
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            params[@"user"] = user.yy_modelCopy;
            params[@"type"] = @(1); // 好友
            
            UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
            [self.navigationController pushViewController:homePageVC animated:YES];
        }
    }
    else
    {
        TIOTeam *team = (TIOTeam *)model;
        
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
}


- (void)toDetailResultVC:(UIButton *)button
{
    NSInteger index = button.tag - 1000;
    
    [NSNotificationCenter.defaultCenter postNotificationName:@"SearchToSelectedVC" object:nil userInfo:@{@"index":@(index)}];
}

@end
