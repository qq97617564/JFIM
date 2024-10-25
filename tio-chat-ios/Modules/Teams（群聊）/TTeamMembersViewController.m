//
//  TTeamMembersViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamMembersViewController.h"
#import "TMemberCell.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"
#import "TTeamDeleteModel.h"
#import <MJRefresh.h>
#import "CTMediator+ModuleActions.h"

@interface TTeamMembersViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) TIOTeamMember *teamUser;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *members;
@property (weak,   nonatomic) UIButton *batchDeleteButton; // 批量删除确认button
@property (strong, nonatomic) NSMutableDictionary<NSString *, TIOTeamMember *> *selectedCache;

/// 处在批量删除模式  禁止左滑删除
@property (assign, nonatomic) BOOL inBatchDeleteMode;

@property (copy,    nonatomic) NSString *searchKey;
@property (assign,  nonatomic) BOOL isSearching; // 是否处在搜索模式中

@end

@implementation TTeamMembersViewController

- (instancetype)initWithTeamUser:(TIOTeamMember *)teamUser
{
    self = [super init];
    if (self) {
        self.teamUser = teamUser;
        self.leftBarButtonText = @"群成员";
        self.selectedCache = [NSMutableDictionary dictionary];
    }
    return self;
}
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.teamUser.role == TIOTeamUserRoleOwner ) {
        if (!self.isOnlySee) {
            [self setupNav];
        }
    }
    [self setupTable];
    [self requestData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self cancelSideBack];
}

- (void)requestData
{
    [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.teamUser.groupId searchKey:nil pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last, NSInteger total,  NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:teamUsers.count];
        [teamUsers enumerateObjectsUsingBlock:^(TIOTeamMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTeamDeleteModel *model = [TTeamDeleteModel modelWithUser:obj];
            [array addObject:model];
        }];
        self.members = array;
        
        self.tableView.mj_footer.hidden = array.count == 0;
        
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
        
        if (self.teamUser.role == TIOTeamUserRoleOwner && self.isRemoveMember) {
            [self refrshNav:0];
        }
    }];
}

- (void)beginLoadingMore:(id)sender
{
    [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.teamUser.groupId searchKey:nil pageNumber:self.members.count/100+1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last,NSInteger total, NSError * _Nullable error) {
        [self.tableView.mj_footer endRefreshing];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:teamUsers.count];
        [teamUsers enumerateObjectsUsingBlock:^(TIOTeamMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTeamDeleteModel *model = [TTeamDeleteModel modelWithUser:obj];
            [array addObject:model];
        }];
        self.members = [self.members arrayByAddingObjectsFromArray:array];
        self.tableView.mj_footer.hidden = array.count == 0;
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    }];
}

- (void)setupTable
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar- safeBottomHeight) style:UITableViewStylePlain];
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.sectionHeaderHeight = 20;
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [tableView registerClass:TMemberCell.class forCellReuseIdentifier:NSStringFromClass(TMemberCell.class)];
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
    
    if (self.teamUser.role == TIOTeamUserRoleOwner) {
//        UIView *batchView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 60+safeBottomHeight)];
//        batchView.bottom = self.view.height;
//        batchView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
//
//        batchView.hidden = !self.isRemoveMember; // 批量功能隐藏
//
//        // 进入批量管理模式
//        UIButton *startBatchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [startBatchButton setTitle:@"批量管理" forState:UIControlStateNormal];
//        [startBatchButton setTitle:@"取消" forState:UIControlStateSelected];
//        [startBatchButton setTitleColor:[UIColor colorWithHex:0x4C94E8] forState:UIControlStateNormal];
//        startBatchButton.titleLabel.font = [UIFont systemFontOfSize:16];
//        [startBatchButton sizeToFit];
//        startBatchButton.height = 60;
//        startBatchButton.width += 60;
//        startBatchButton.viewOrigin = CGPointZero;
//        [startBatchButton addTarget:self action:@selector(startCancelBatchManage:) forControlEvents:UIControlEventTouchUpInside];
//        [batchView addSubview:startBatchButton];
//
//        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [deleteButton setTitle:@"批量删除" forState:UIControlStateNormal];
//        [deleteButton setTitleColor:[UIColor colorWithHex:0xFF754C] forState:UIControlStateNormal];
//        deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
//        [deleteButton sizeToFit];
//        deleteButton.height = 60;
//        deleteButton.width += 60;
//        deleteButton.top = 0;
//        deleteButton.right = batchView.width;
//        deleteButton.hidden = !self.isRemoveMember;
//        [deleteButton addTarget:self action:@selector(batchDeleteMembers) forControlEvents:UIControlEventTouchUpInside];
//        [batchView addSubview:deleteButton];
//        self.batchDeleteButton = deleteButton;
//
//        [self.view addSubview:batchView];
        
        self.inBatchDeleteMode = self.isRemoveMember;
        [self.tableView reloadData];
    }
}

- (void)setupNav
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x4C94E8]];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button sizeToFit];
        button.width += 20;
        button.layer.cornerRadius = 14;
        button.layer.masksToBounds = YES;
        
        
        [button addTarget:self action:@selector(batchDeleteMembers) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)refrshNav:(NSInteger)total
{
    NSString *title = @"删除";
    if (total) {
        title = [title stringByAppendingFormat:@"(%zd)",total];
    }
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x4C94E8]];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button sizeToFit];
        button.width += 20;
        button.layer.cornerRadius = 14;
        button.layer.masksToBounds = YES;
        button.enabled = total>0;
        
        button.enabled = total != 0;
        
        [button addTarget:self action:@selector(batchDeleteMembers) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

#pragma mark - Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TMemberCell.class) forIndexPath:indexPath];
    TTeamDeleteModel *deleteModel = self.members[indexPath.row];
    TIOTeamMember *member = deleteModel.user;
    
    // 默认禁用多选功能
    TCellSelectedStatus status = TCellSelectedStatusDisabled;
    
    if (self.inBatchDeleteMode)
    {
        status = deleteModel.status;
    }
    
    [cell refreshData:member
               isSelf:[member.uid isEqualToString:self.teamUser.uid] status:status];
    
    cell.selectedCallback = ^(BOOL selected) {
        if (selected)
        {
            deleteModel.status = TCellSelectedStatusSelected;
        }
        else
        {
            deleteModel.status = TCellSelectedStatusNone;
        }
        [self refeshSelectData];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isForbiddenAddOther) {
        return;
    }
    
    TTeamDeleteModel *deleteModel = self.members[indexPath.row];
    [self jumpToUserhome:deleteModel.user.uid];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.teamUser.role == TIOTeamUserRoleMember) {
        return NO;
    }
    
    if (self.inBatchDeleteMode)
    {   // 批量删除时 不可进行左滑删除
        return NO;
    }
    TTeamDeleteModel *deleteModel = self.members[indexPath.row];
    TIOTeamMember *member = deleteModel.user;
    
    if (self.teamUser.role == TIOTeamUserRoleOwner && member.role == TIOTeamUserRoleOwner) {
        // 群主不能删除群主（就是自己）
        return NO;
    }
    
    if (self.teamUser.role == TIOTeamUserRoleManager && (member.role == TIOTeamUserRoleOwner || member.role == TIOTeamUserRoleManager)) {
        // 管理员不能删除群主 和 管理员（包括自己）
        return NO;
    }
    
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
    // 解除/禁言
    TTeamDeleteModel *deleteModel = self.members[indexPath.row];
    TIOTeamMember *user = deleteModel.user;
    NSString *forbidenMsg = user.forbiddenflag == 2?@"禁言":@"解除禁言";
    NSString *managerMsg = user.role == TIOTeamUserRoleMember ? @"设为管理员" : @"解除管理员";
    
    // 删除
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [TIOChat.shareSDK.teamManager checkStatusForUser:user.uid inTeam:user.groupId completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
            if (result) {
                NSInteger kickgrant = [result[@"kickgrant"] integerValue];
                if (kickgrant == 1) {
                    // SDK 删除
                    [self confirmDelete:indexPath];
                } else {
                    [MBProgressHUD showInfo:@"权限不足" toView:self.view];
                }
            } else {
                if (error) {
                    [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
                }
                
            }
        }];
    }];
    
    
    UIContextualAction *managerAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:managerMsg handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        // SDK 管理员
        TIOTeamUserRole toRole = user.role == TIOTeamUserRoleMember?TIOTeamUserRoleManager:TIOTeamUserRoleMember;
        [TIOChat.shareSDK.teamManager changeMemberRole:toRole uid:user.uid inTeam:user.groupId completion:^(NSError * _Nullable error) {
            if (!error) {
                [self requestData];
            } else {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
        
    }];
    
    UIContextualAction *forbiddenAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:forbidenMsg handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [TIOChat.shareSDK.teamManager checkStatusForUser:user.uid inTeam:user.groupId completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
            if (result) {
                NSInteger grant = [result[@"grant"] integerValue];
                if (grant == 1) {
                    // SDK 解除禁言
                    [self forbiddenWithIndexPath:indexPath user:user];
                } else {
                    [MBProgressHUD showInfo:@"权限不足" toView:self.view];
                }
            } else {
                if (error) {
                    [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
                }
                
            }
        }];
    }];

    NSArray *actions = nil;
    
    if (self.teamUser.role == TIOTeamUserRoleOwner) {
        actions = @[deleteAction, managerAction, forbiddenAction];
    } else {
        actions = @[deleteAction, forbiddenAction];
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
    
    // 只要在此设定颜色顺序即可
    NSArray *colors = nil;
    if (rowActionView.subviews.count == 3) {
        colors = @[[UIColor colorWithHex:0xFFA32A],UIColor.TDTheme_TabBarSelectedColor, UIColor.TDTheme_UnreadColor];
    } else {
        colors = @[UIColor.TDTheme_TabBarSelectedColor, UIColor.TDTheme_UnreadColor];
    }
    
    if (ios13) {
        if (rowActionView.subviews.count > 3) {
            return;
        }
        
        for (int i = 0; i < rowActionView.subviews.count; i++) {
            UIButton *button = rowActionView.subviews[i];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            
            for (id subView in button.subviews) {
                UIView *view = subView;
                view.backgroundColor = colors[i];
            }
            [button setBackgroundImage:[UIImage imageWithColor:colors[i]] forState:UIControlStateNormal];
        }
    } else {
        for (int i = 0; i < rowActionView.subviews.count; i++) {
            UIButton *button = rowActionView.subviews[i];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setBackgroundImage:[UIImage imageWithColor:colors[i]] forState:UIControlStateNormal];
        }
    }
}

- (void)confirmDelete:(NSIndexPath *)indexPath
{
    
    TAlertController *alert = [TAlertController alertControllerWithTitle:@""
                                                                 message:@"确定删除该成员？"
                                                          preferredStyle:TAlertControllerStyleAlert];
    
    [alert addAction:[TAlertAction actionWithTitle:@"取消"
                                             style:TAlertActionStyleCancel
                                           handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[TAlertAction actionWithTitle:@"删除"
                                             style:TAlertActionStyleDone
                                           handler:^(TAlertAction * _Nonnull action) {
        // SDK 删除API
        TTeamDeleteModel *deleteModel = self.members[indexPath.row];
        TIOTeamMember *member = deleteModel.user;
        
        [TIOChat.shareSDK.teamManager removeUser:@[member.uid] fromTeam:self.teamUser.groupId completion:^(NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.members];
                [array removeObjectAtIndex:indexPath.row];
                self.members = array;
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
        }];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)forbiddenWithIndexPath:(NSIndexPath *)indexPath user:(TIOTeamMember *)user
{
    [self alertNoTalkingForUid:user];
}

- (void)alertNoTalkingForUid:(TIOTeamMember *)user
{
    if (user.forbiddenflag == 2) {
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"禁言10分钟" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                [self requestNoTalking:10*60 user:user mode:1];
            }];
            action;
        })];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"禁言1小时" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                [self requestNoTalking:60*60 user:user mode:1];
            }];
            action;
        })];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"禁言6小时" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                [self requestNoTalking:6*60*60 user:user mode:1];
            }];
            action;
        })];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"禁言24小时" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                [self requestNoTalking:24*60*60 user:user mode:1];
            }];
            action;
        })];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"长期禁言" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
                [self requestNoTalking:0 user:user mode:3];
            }];
            action;
        })];
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            }];
            action;
        })];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // 解除禁言
        [TIOChat.shareSDK.teamManager forbiddenSpeakInTeam:self.teamUser.groupId oper:2 mode:user.forbiddenflag duration:0 uid:user.uid completion:^(NSError * _Nullable error) {
            if (!error) {
                [MBProgressHUD showInfo:@"已解除禁言" toView:self.view];
                user.forbiddenflag = 2;
                [self.tableView reloadData];
            } else {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
    }
    
}

- (void)requestNoTalking:(NSTimeInterval)seconds user:(TIOTeamMember *)user mode:(NSInteger)mode
{
    // 发起禁言请求
    [TIOChat.shareSDK.teamManager forbiddenSpeakInTeam:user.groupId oper:1 mode:mode duration:seconds uid:user.uid completion:^(NSError * _Nullable error) {
        if (!error) {
            [MBProgressHUD showInfo:@"操作成功" toView:self.view];
            // 注意，一定要更改这条用户的model状态 成已被禁言的类型
            user.forbiddenflag = mode;
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
}

/// 开启批量删除
- (void)startCancelBatchManage:(UIButton *)button
{
    button.selected = !button.selected;
    
    // 更新按钮的布局
    [button sizeToFit];
    button.height = 60;
    button.width += 60;
    button.viewOrigin = CGPointZero;
    // 批量删除button的显示隐藏
    self.batchDeleteButton.hidden = !button.selected;
    self.inBatchDeleteMode = button.selected;
    [self.tableView reloadData];
}

- (void)refreshDeleteButtonTitle:(NSInteger)total
{
    NSString *title = @"批量删除";
    if (total) {
        title = [title stringByAppendingFormat:@"(%zd)",total];
    }
    [self.batchDeleteButton setTitle:title forState:UIControlStateNormal];
    [self.batchDeleteButton sizeToFit];
    self.batchDeleteButton.height = 60;
    self.batchDeleteButton.width += 60;
    self.batchDeleteButton.top = 0;
    self.batchDeleteButton.right = self.view.width;
}

/// 批量删除
- (void)batchDeleteMembers
{
    /// 构造批量删除的用户ID数组
    
    NSMutableArray *uids = [NSMutableArray arrayWithCapacity:self.selectedCache.allValues.count];
    
    [self.members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTeamDeleteModel *deleteModel = obj;
        if (deleteModel.status == TCellSelectedStatusSelected) {
            [uids addObject:deleteModel.user.uid];
        }
    }];
    
    /// 确认删除弹窗
    
    TAlertController *alert = [TAlertController alertControllerWithTitle:@""
                                                                 message:[NSString stringWithFormat:@"确定删除已选的%zd位成员？",uids.count]
                                                          preferredStyle:TAlertControllerStyleAlert];
    
    [alert addAction:[TAlertAction actionWithTitle:@"取消"
                                             style:TAlertActionStyleCancel
                                           handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[TAlertAction actionWithTitle:@"删除"
                                             style:TAlertActionStyleDone
                                           handler:^(TAlertAction * _Nonnull action) {
        // SDK 删除API
        [TIOChat.shareSDK.teamManager removeUser:uids
                                        fromTeam:self.teamUser.groupId
                                      completion:^(NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                [self requestData];
            }
        }];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refeshSelectData
{
    __block NSInteger total = 0;
    [self.members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTeamDeleteModel *deleteModel = obj;
        
        if (deleteModel.status == TCellSelectedStatusSelected) {
            total++;
        }
        
    }];
    
    [self refrshNav:total];
}

#pragma mark - 跳转到用户主页

/// 跳转指定用户的主页
/// @param targetUserId 目标用户ID
- (void)jumpToUserhome:(NSString *)targetUserId
{
    // 可能已经解除好友关系 但是会话还在，查看的对方信息主页就会不一样
    // 所以 先验证是不是好友
    CBWeakSelf
    [TIOChat.shareSDK.friendManager isMyFriend:targetUserId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else
        {
            // 预处理Block
            void (^jumpToUserInfoVCBlock)(TIOUser *userInfo, NSInteger type) = ^(TIOUser *userInfo, NSInteger type) {
                
                  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
                    
                    params[@"user"] = userInfo;
                    params[@"type"] = @(type); // 好友
                    
                    UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                    [self.navigationController pushViewController:homePageVC animated:YES];
            };
            

            // 获取用户信息，再执行block跳转
            [TIOChat.shareSDK.friendManager fetchUserInfo:targetUserId completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                if (error)
                {
                    DDLogError(@"%@",error);
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                }
                else
                {
                    jumpToUserInfoVCBlock(user, isFriend?1:3);
                }
            }];
        }
    }];
}

#pragma mark - Search

- (void)toSearch:(id)sender
{
    [self searchWithKey:self.searchKey];
}

- (void)searchWithKey:(NSString *)key
{
    [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.teamUser.groupId searchKey:key pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last,NSInteger total, NSError * _Nullable error) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:teamUsers.count];
        [teamUsers enumerateObjectsUsingBlock:^(TIOTeamMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTeamDeleteModel *model = [TTeamDeleteModel modelWithUser:obj];
            [array addObject:model];
        }];
        self.members = array;
        
        self.tableView.mj_footer.hidden = array.count == 0;
        
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
        
        if (self.teamUser.role == TIOTeamUserRoleOwner && self.isRemoveMember) {
            [self refrshNav:0];
        }
    }];
}

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


@end
