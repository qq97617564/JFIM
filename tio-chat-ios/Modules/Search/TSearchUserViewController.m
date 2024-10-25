//
//  TSearchUserViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchUserViewController.h"
#import "TSearchUserCell.h"
/// Common
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"
#import "TInputAlertController.h"
#import "CTMediator+ModuleActions.h"
/// SDK
#import "ImportSDK.h"
/// PODS
#import "FrameAccessor.h"
#import <MJRefresh.h>
#import <YYModel/NSObject+YYModel.h>

@interface TSearchUserViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray<TIOUser *> *resultDatas;
@property (weak, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSString *searchKey;
@end

@implementation TSearchUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self addNaivigationBar];
}

- (void)addNaivigationBar
{
    UITextField *searchField = [UITextField.alloc initWithFrame:CGRectMake(16, Height_StatusBar + 4, self.view.width - 16 - 60, 36)];
    searchField.placeholder = @"搜索用户昵称";
    searchField.leftViewMode = UITextFieldViewModeAlways;
    searchField.leftView = ({
        UIView *leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 38, searchField.height)];
        
        UIImageView *icon = [UIImageView.alloc initWithFrame:CGRectZero];
        icon.image = [UIImage imageNamed:@"searchbar"];
        [icon sizeToFit];
        icon.right = leftView.width;
        icon.centerY = leftView.middleY;
        [leftView addSubview:icon];
        
        leftView;
    });
    searchField.rightViewMode = UITextFieldViewModeWhileEditing;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
    searchField.layer.cornerRadius = searchField.height * 0.5;
    searchField.layer.masksToBounds = YES;
    searchField.textColor = [UIColor blackColor];
    searchField.font = [UIFont systemFontOfSize:16];
    searchField.returnKeyType = UIReturnKeySearch;
    [searchField addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.navigationBar addSubview:searchField];
    [searchField becomeFirstResponder];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(searchField.right, Height_StatusBar, 60, 44);
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(toCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:cancelButton];
}

- (void)setupUI
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar - 20) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:TSearchUserCell.class forCellReuseIdentifier:NSStringFromClass(TSearchUserCell.class)];
    tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部搜索结果 —" forState:MJRefreshStateNoMoreData];
        [footer setRefreshingTarget:self refreshingAction:@selector(beginLoadingMore:)];
        
        footer;
    });
    tableView.mj_footer.hidden = YES;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)toSearch:(UITextField *)textfield
{
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.pageNumber = 1;
    option.searchText = textfield.text;
    
    CBWeakSelf
    [TIOChat.shareSDK.friendManager searchUserWithOption:option completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"%@",error);
        } else {
            // 记录当前搜索的内容
            self.searchKey = textfield.text;
            self.resultDatas = users;
            
            self.tableView.mj_footer.hidden = lastPage;
            
            if (lastPage) {
                [self.tableView.mj_footer resetNoMoreData];
            } else {
                self.tableView.mj_footer.hidden = NO;
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)toCancel:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)beginLoadingMore:(id)sender
{
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.pageNumber = self.resultDatas.count/20+1;
    option.searchText = self.searchKey;
    
    CBWeakSelf
    [TIOChat.shareSDK.friendManager searchUserWithOption:option completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [self.tableView.mj_footer endRefreshing];
        if (error) {
            DDLogError(@"%@",error);
        } else {
            self.resultDatas = [self.resultDatas arrayByAddingObjectsFromArray:users];
            self.tableView.mj_footer.hidden = lastPage;
            if (lastPage) {
                [self.tableView.mj_footer resetNoMoreData];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIOUser *user = self.resultDatas[indexPath.row];
    
    TSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TSearchUserCell.class)];
    
    [cell refreshAvatar:user.avatar sex:1 nick:user.nick relation:0 key:self.searchKey];
    CBWeakSelf
    cell.addCallback = ^{
        CBStrongSelfElseReturn
        [self addUser:user];
    };
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultDatas.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOUser *user = self.resultDatas[indexPath.row];
    
    // 此时不知道是不是自己的好友
    // 先验证是不是好友
    CBWeakSelf
    [TIOChat.shareSDK.friendManager isMyFriend:user.userId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            
            if (isFriend)
            {
                params[@"user"] = user.yy_modelCopy;
                params[@"type"] = @(1); // 好友
                
                UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                [self.navigationController pushViewController:homePageVC animated:YES];
            }
            else
            {
                params[@"user"] = user.yy_modelCopy;
                params[@"type"] = @(3); // 需要审核
                
                UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                [self.navigationController pushViewController:homePageVC animated:YES];
            }
        }
    }];
}

#pragma mark - Actions


#pragma mark - 添加好友的步骤和流程

#pragma mark - 第一步 ： 先判断检测对方是不是已经是好友
/// 检测是否可以添加
/// @param user 对方
- (void)addUser:(TIOUser *)user
{
    [TIOChat.shareSDK.friendManager isMyFriend:user.userId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            if (isFriend) {
                [MBProgressHUD showInfo:@"对方已经是你的好友了" toView:self.view];
            } else {
                [self checkUserCondition:user.userId];
            }
        }
    }];
}

#pragma mark - 第二步 : 检查对方的加好友权限：无条件加好友还是需要验证信息

/// 检查对方设置的添加条件
/// @param uid 对方UID
- (void)checkUserCondition:(NSString *)uid
{
    [TIOChat.shareSDK.friendManager checkAddConditionWithUid:uid
                                                  completion:^(NSInteger condition, NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            [self requestToAddUser:condition uid:uid];
        }
    }];
}

#pragma mark - 第三步 : 发起加好友的操作

/// SDK添加API
/// @param condition 添加条件
- (void)requestToAddUser:(NSInteger)condition uid:(NSString *)uid
{
    if (condition == 1) {
        // 需申请
        NSString *nick = [TIOChat.shareSDK.loginManager userInfo].nick;
        NSString *text = [NSString stringWithFormat:@"我是 %@",nick];
        
        TInputAlertController *alert = [TInputAlertController alertWithTitle:@"添加好友" placeholder:@"请输入验证信息" inputHeight:84 inputStyle:TAlertControllerTextView];
        alert.text = text;  // 默认验证消息（我是 XXX）
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {

            }];

            action;
        })];

        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"申请" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                // SDK API
                TIOFriendRequest *request = [TIOFriendRequest.alloc init];
                request.message = alert.text;
                request.operation = TIOFriendOperationRequest;
                request.userId = uid;
                
                [TIOChat.shareSDK.friendManager addFrinend:request
                                                completion:^(NSError * _Nullable error) {
                    if (error) {
                        DDLogError(@"%@",error);
                    } else {
                        [MBProgressHUD showInfo:@"已发送申请，等待对方同意" toView:self.view];
                    }
                }];
            }];

            action;
        })];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        // 无条件添加
        TIOFriendRequest *request = [TIOFriendRequest.alloc init];
        request.operation = TIOFriendOperationAdd;
        request.userId = uid;
        
        [TIOChat.shareSDK.friendManager addFrinend:request
                                        completion:^(NSError * _Nullable error) {
            if (error) {
                DDLogError(@"%@",error);
            } else {
                [MBProgressHUD showInfo:@"成功添加好友" toView:self.view];
            }
        }];
    }
}

@end
