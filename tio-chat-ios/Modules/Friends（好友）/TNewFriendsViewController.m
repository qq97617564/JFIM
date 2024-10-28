//
//  TNewFriendsViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/13.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TNewFriendsViewController.h"
#import "TNewFriendCell.h"
#import "TInputAlertController.h"
#import "GFUserInfoVC.h"
/// common
#import "MBProgressHUD+NJ.h"
/// sdk
#import "ImportSDK.h"
/// pods
#import "FrameAccessor.h"

@interface TNewFriendsViewController () <UITableViewDelegate, UITableViewDataSource, TNewFriendCellDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray<TIOApplyUser *> *dataArray;

@end

@implementation TNewFriendsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"新的朋友";
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

/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 72;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [tableView registerClass:[TNewFriendCell class] forCellReuseIdentifier:NSStringFromClass(TNewFriendCell.class)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 10)];
}

- (void)requestData
{
    [TIOChat.shareSDK.friendManager fetchApplyListWithCompletion:^(NSArray<TIOApplyUser *> * _Nullable users, NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            self.dataArray = users;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TNewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TNewFriendCell.class)
    forIndexPath:indexPath];
    
    cell.delegate = self;
    
    TIOApplyUser *user = self.dataArray[indexPath.row];
    
    [cell setAvatarUrl:user.avatar];
    cell.nickLabel.text = user.nick;
    cell.msgLabel.text = user.greet;
    
    if (user.status == TIOFriendReqStatusAdded) {
        cell.reqStatus = TIOFriendReqStatusAdded;
    } else if (user.status == TIOFriendReqStatusIgnored) {
        cell.reqStatus = TIOFriendReqStatusIgnored;
    } else {
        cell.reqStatus = TIOFriendReqStatusWaitting;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOApplyUser *user = self.dataArray[indexPath.row];
    
    if (user.status == 1) {
        [self.navigationController pushViewController:[GFUserInfoVC.alloc initWithUser:user type:TUserInfoVCTypeFriend] animated:YES];
    } else {
        [self.navigationController pushViewController:[GFUserInfoVC.alloc initWithUser:user type:TUserInfoVCTypeVerfiy] animated:YES];
    }
}

#pragma mark - UITableViewDelegate
#pragma mark - TNewFriendCellDelegate

- (void)onAddFriend:(TNewFriendCell *)cell
{
    // TODO: 发起同意添加好友请求
    
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    
    TIOApplyUser *user = self.dataArray[indexpath.row];
    
    NSString *title = [user.nick stringByAppendingString:@"\n\n设置备注"];
    
    TInputAlertController *alert = [TInputAlertController alertWithTitle:title placeholder:@"" inputHeight:44 inputStyle:TAlertInputStyleTextField];
    alert.text = user.nick;
    
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }];
        
        action;
    })];
    
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"同意" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            [self allowApply:[NSString stringWithFormat:@"%zd",user.applyId] remarkname:alert.text];
        }];
        
        action;
    })];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onRejectFriend:(TNewFriendCell *)cell
{
    // TODO: 发起拒绝好友请求
}

- (void)onIgnoreFriend:(TNewFriendCell *)cell
{
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    
    TIOApplyUser *user = self.dataArray[indexpath.row];
    
    [self ignoreApply:[NSString stringWithFormat:@"%zd",user.applyId]];
}

/// 同意好友申请
/// @param uid 申请人的ID
/// @param remarkname 备注
- (void)allowApply:(NSString *)uid remarkname:(NSString *)remarkname
{
    TIOFriendRequest *request = [TIOFriendRequest.alloc init];
    request.userId = uid;
    request.operation = TIOFriendOperationAdopt;
    request.message = remarkname;
    
    [TIOChat.shareSDK.friendManager handleApply:request completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            [MBProgressHUD showInfo:@"添加成功" toView:self.view];
            // 刷新数据
            [self requestData];
        }
    }];
}

- (void)ignoreApply:(NSString *)uid
{
    TIOFriendRequest *request = [TIOFriendRequest.alloc init];
    request.userId = uid;
    request.operation = TIOFriendOperationIgnore;
    
    [TIOChat.shareSDK.friendManager handleApply:request completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            [MBProgressHUD showInfo:@"添加成功" toView:self.view];
            // 刷新数据
            [self requestData];
        }
    }];
}

@end
