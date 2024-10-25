//
//  TNoTalkingListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TNoTalkingListViewController.h"
#import "TNoTalkingCell.h"

#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "TAlertController.h"
#import "MBProgressHUD+NJ.h"

#import "ImportSDK.h"
#import <MJRefresh/MJRefresh.h>

@interface TNoTalkingListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray *dataArray;

@property (copy,    nonatomic) NSString *searchKey;
@property (assign,  nonatomic) BOOL isSearching; // 是否处在搜索模式中

@end

@implementation TNoTalkingListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"禁言名单";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self requestData];
}

- (void)setupUI
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.sectionHeaderHeight = 20;
    tableView.separatorInset = UIEdgeInsetsMake(17, 0, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    tableView.allowsSelection = NO;
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [tableView registerClass:TNoTalkingCell.class forCellReuseIdentifier:NSStringFromClass(TNoTalkingCell.class)];
    tableView.tableHeaderView = ({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 60)];
        view.backgroundColor = UIColor.whiteColor;
        
        UITextField *searchTF = [UITextField.alloc initWithFrame:CGRectMake(16, 10, view.width - 32, 36)];
        searchTF.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
        searchTF.layer.cornerRadius = 18;
        searchTF.layer.masksToBounds = YES;
        searchTF.leftViewMode = UITextFieldViewModeAlways;
        searchTF.leftView = ({
            UIView *left = [UIView.alloc initWithFrame:CGRectMake(0, 0, 38, searchTF.height)];
            UIImageView *icon = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"searchbar"]];
            [icon sizeToFit];
            icon.left = 14;
            icon.centerY = left.middleY;
            [left addSubview:icon];
            
            left;
        });
        searchTF.rightViewMode = UITextFieldViewModeWhileEditing;
        searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchTF.placeholder = @"搜索群成员";
        searchTF.font = [UIFont systemFontOfSize:16];
        searchTF.returnKeyType = UIReturnKeySearch;
        [searchTF resignFirstResponder];
        [searchTF addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
        [view addSubview:searchTF];

        view;
    });
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
}

#pragma mark - 请求

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchForbiddenUserListInTeamId:self.teamid searchKey:nil pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [self.tableView.mj_header endRefreshing];
        self.dataArray = teamUsers;
        
        self.tableView.mj_footer.hidden = teamUsers.count == 0;
        
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    }];
}

- (void)beginLoadingMore:(id)sender
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.teamid searchKey:nil pageNumber:self.dataArray.count/100+1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last,NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [self.tableView.mj_footer endRefreshing];

        self.dataArray = [self.dataArray arrayByAddingObjectsFromArray:teamUsers];
        self.tableView.mj_footer.hidden = teamUsers.count == 0;
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - 普通的UITableView代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TNoTalkingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TNoTalkingCell.class)];
    
    TIOTeamMember *user = self.dataArray[indexPath.row];
    [cell updateAvatar:user.avatar nick:user.srcnick remark:user.nick time:user.forbiddenduration forever:user.forbiddenflag==3];
    
    return cell;
}

#pragma mark - 策划删除

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

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
{
    // 解除禁言
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"解除禁言" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        // SDK 解除禁言
        [self confirmDelete:indexPath];
    }];

    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    configuration.performsFirstActionWithFullSwipe = NO;

    return configuration;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    return;
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
//    UIButton *topButton = rowActionView.subviews[0];
    UIButton *deleteButton = rowActionView.subviews[0];
    
//    topButton.titleLabel.font = [UIFont systemFontOfSize:16];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    if (ios13) {
//        for (id subView in topButton.subviews) {
//            if ([subView isMemberOfClass:[UIView class]]) {
//                UIView *view = subView;
//                view.backgroundColor = UIColor.TDTheme_TabBarSelectedColor;
//            }
//        }
//        [topButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_TabBarSelectedColor] forState:UIControlStateNormal];
        
        for (id subView in deleteButton.subviews) {
            if ([subView isMemberOfClass:[UIView class]]) {
                UIView *view = subView;
                view.backgroundColor = UIColor.TDTheme_UnreadColor;
            }
        }
        [deleteButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_UnreadColor] forState:UIControlStateNormal];
    } else {
//        [topButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_TabBarSelectedColor] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageWithColor:UIColor.TDTheme_UnreadColor] forState:UIControlStateNormal];
    }
}

- (void)confirmDelete:(NSIndexPath *)indexPath
{
    TIOTeamMember *user = self.dataArray[indexPath.row];
    
    TAlertController *alert = [TAlertController alertControllerWithTitle:@""
                                                                 message:[NSString stringWithFormat:@"确认将 %@ 移除禁言名单？",user.nick]
                                                          preferredStyle:TAlertControllerStyleAlert];
    
    [alert addAction:[TAlertAction actionWithTitle:@"取消"
                                             style:TAlertActionStyleCancel
                                           handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[TAlertAction actionWithTitle:@"确定"
                                             style:TAlertActionStyleDone
                                           handler:^(TAlertAction * _Nonnull action) {
        // SDK 删除API
        
        [TIOChat.shareSDK.teamManager forbiddenSpeakInTeam:self.teamid oper:2 mode:user.forbiddenflag duration:0 uid:user.uid completion:^(NSError * _Nullable error) {
            if (!error) {
                [MBProgressHUD showInfo:@"操作成功" toView:self.view];
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataArray];
                [array removeObjectAtIndex:indexPath.row];
                self.dataArray = array;
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            } else {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 搜索

- (void)textFieldEditing:(UITextField *)textField
{
    self.searchKey = textField.text;
    if (textField.text.length == 0) {
        
        self.isSearching = NO;
        [self requestData];
    } else {
        if (textField.markedTextRange == nil) {
            // 搜索
            [self searchWithKey:textField.text];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isSearching = YES;
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.isSearching = NO;
    [self.view endEditing:YES];
}

- (void)searchWithKey:(NSString *)key
{
    [TIOChat.shareSDK.teamManager fetchForbiddenUserListInTeamId:self.teamid searchKey:key pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last, NSInteger total, NSError * _Nullable error) {
        self.dataArray = teamUsers;
        
        self.tableView.mj_footer.hidden = teamUsers.count == 0;
        
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    }];
}


@end
