//
//  TTeamSearchViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamInviteViewController.h"
#import "TTeamSearchInviteViewController.h"
#import "FrameAccessor.h"
#import "TSortString.h"
#import "UITableView+SCIndexView.h"
#import "ImportSDK.h"
#import "TTeamInviteModel.h"
#import "TInviteUserCell.h"
#import "TInputAlertController.h"
#import "MBProgressHUD+NJ.h"
#import "UIImage+TColor.h"
#import "UIControl+T_LimitClickCount.h"
#import "LYGroupNode.h"

#import "CTMediator+ModuleActions.h"

@interface TTeamInviteViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) TTeamSearchType type;
@property (nonatomic, weak) UITableView *tableView;

@property (strong, nonatomic) NSArray<LYGroupNode<TTeamInviteModel *> *> *showUsersDataArray;//用于展示的数据源：默认获取的全部数据、搜索的数据。
//@property (strong, nonatomic) NSArray<LYGroupNode<TTeamInviteModel *> *> *allUsers;//用于最后根据selectedUsersCache的uid找到

@property (strong, nonatomic) NSArray   *titleOfIndexes;
@property (copy, nonatomic) NSString *loginUID;

@property (strong,  nonatomic) TIOTeam *team; // 群信息
@property (strong,  nonatomic) TIOTeamMember *teamMember; // 自己在群内的信息

@property (strong,  nonatomic) NSMutableDictionary<NSString *, TIOUser *> *selectedUsersCache;
@property (copy,    nonatomic) NSString *searchKey;
@property (assign,  nonatomic) BOOL isSearching; // 是否处在搜索模式中

@end

@implementation TTeamInviteViewController

- (instancetype)initWithTitle:(NSString *)title type:(TTeamSearchType)type
{
    self = [super init];
    
    if (self) {
//        self.title = title;
        self.title = title;
        self.type = type;
        self.loginUID = [TIOChat.shareSDK.loginManager userInfo].userId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selectedUsersCache = [NSMutableDictionary dictionary];
    [self setupNav];
    [self addTableView];
    [self requestData];
}

/// 获取数据
- (void)requestData
{
    if (self.type == TTeamSearchTypeCreate)
    {
        /// 获取创建群的可邀请名单
        
        CBWeakSelf
        [TIOChat.shareSDK.friendManager fetchMyFriends:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {

            CBStrongSelfElseReturn

            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                NSString *selfUid = TIOChat.shareSDK.loginManager.userInfo.userId;
                // 剔除自己
                NSMutableArray *tempUsers = [NSMutableArray arrayWithCapacity:users.count];
                for (TIOUser *user in users) {
                    if ([user.userId isEqualToString:selfUid]) continue;
                    [tempUsers addObject:user];
                }
                
                self->_showUsersDataArray = [self transferOriginData:tempUsers];
                [self refreshList];
            }

        }];
    }
    else
    {
        /// 获取该群的可邀请名单
        
        CBWeakSelf
        [TIOChat.shareSDK.teamManager searchFriends:@"" notInTeam:self.teamId completion:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self->_showUsersDataArray = [self transferOriginData:users];
                [self refreshList];
            }
        }];
    }
    
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchTeamInfoWithTeamId:self.teamId completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.team = team;
        self.teamMember = teamUser;
    }];
}


/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar - Height_TabBar) style:UITableViewStyleGrouped];
    tableView.sectionIndexColor = [UIColor colorWithHex:0x909090];
    tableView.backgroundColor = UIColor.clearColor;
    tableView.sectionIndexMinimumDisplayRowCount = 6;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TInviteUserCell class] forCellReuseIdentifier:NSStringFromClass(TInviteUserCell.class)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    tableView.tableHeaderView = ({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 44)];
        view.backgroundColor = UIColor.clearColor;
        
        UITextField *searchTF = [UITextField.alloc initWithFrame:CGRectMake(16, 5, view.width - 32, 36)];
        searchTF.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
        searchTF.layer.cornerRadius = 4;
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
        searchTF.placeholder = @"搜索";
        searchTF.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        searchTF.returnKeyType = UIReturnKeySearch;
        [searchTF resignFirstResponder];
        [searchTF addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
        [view addSubview:searchTF];

        view;
    });
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
    configuration.indexItemRightMargin = 16;
    configuration.indicatorRightMargin = 50;
    configuration.indexItemSelectedTextColor = [UIColor colorWithHex:0x0087FC];
    configuration.indexItemTextColor = [UIColor colorWithHex:0x909090];
    configuration.indexItemSelectedBackgroundColor = UIColor.clearColor;
    configuration.indicatorTextFont = [UIFont systemFontOfSize:12];
    configuration.indicatorTextFont = [UIFont systemFontOfSize:20];
    tableView.sc_indexViewConfiguration = configuration;
    tableView.sc_translucentForTableViewInNavigationBar = NO;
}

- (void)setupNav
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x0087FC]];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x0087FC]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x0087FC]] forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        button.viewSize = CGSizeMake(70, 30);
        button.acceptEventInterval = 0.5;

        
        [button addTarget:self action:@selector(createClickDone:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 6;
        button.layer.masksToBounds = true;
        button;
    })];
}

- (void)refrshNav:(NSInteger)total
{
    NSString *title = @"确定";
    if (total) {
        title = [title stringByAppendingFormat:@"(%zd)",total];
    }
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button sizeToFit];
        button.height = 30;
        button.width += 20;
        button.acceptEventInterval = 0.5;
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x0087FC]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xD4D4D4]] forState:UIControlStateDisabled];
        
        button.enabled = total != 0;

        [button addTarget:self action:@selector(createClickDone:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 6;
        button.layer.masksToBounds = true;
        button;
    })];
}

- (void)createClickDone:(id)sender
{
    NSMutableArray *uids = [NSMutableArray array];
    NSMutableString *defaultTeamName = [NSMutableString.alloc initWithString:TIOChat.shareSDK.loginManager.userInfo.nick];
    
    [self.selectedUsersCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TIOUser * _Nonnull obj, BOOL * _Nonnull stop) {
        [uids addObject:key];
        if (![key isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
            if (uids.count < 5)
            {   // 默认取自己再加五个人的昵称组成默认群名
                [defaultTeamName appendFormat:@",%@",obj.nick];
            }
        }
    }];
    
    if (uids.count) {
        
        if (self.type == TTeamSearchTypeCreate)
        {
            ///
            /// 创建群
            ///
            TInputAlertController *alert = [TInputAlertController alertWithTitle:@"群聊名称" placeholder:@"" inputHeight:70 inputStyle:TAlertControllerTextView];

            alert.text = defaultTeamName;
            
            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }]];
            
            [alert addAction:[TAlertAction actionWithTitle:@"确认" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                
                if (alert.text.length > 30) {
                    [MBProgressHUD showInfo:@"群名最多30个字" toView:UIApplication.sharedApplication.keyWindow];
                    return;
                }
                
//                TIOTeamName *nameObject = [TIOTeamName.alloc init];
//                nameObject.name = alert.text;
//                nameObject.allowServerToUpdateAutomatically = [alert.text componentsSeparatedByString:@","].count>1; // 若是“,”分割组成的昵称 允许服务端自动修改群昵称
                
                [TIOChat.shareSDK.teamManager createTeamName:alert.text introduction:@"" users:uids completion:^(NSError * _Nullable error, NSString * _Nullable teamId) {
                    
                    if (error)
                    {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    }
                    else
                    {
                        [MBProgressHUD showInfo:@"建群成功" toView:self.view];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            // 创建成功进群
                            
                            [self toTeamSessionVC:teamId];

                        });
                    }
                }];
                
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            ///
            /// 邀请入群
            ///
            
            
            /**
             * 先检查本群是否开启邀请审核
             */
            
            if (self.team.joinType == TIOTeamJoinTypeReview) {
                if (self.teamMember.role == TIOTeamUserRoleOwner || self.teamMember.role == TIOTeamUserRoleManager) {
                    [self inviteUers:uids toTeam:self.teamId isNeedReviewed:NO];
                } else {
                    [self inviteUers:uids toTeam:self.teamId isNeedReviewed:YES];
                }
            } else {
                [self inviteUers:uids toTeam:self.teamId isNeedReviewed:NO];
            }
        }
    }
}

/// 拉好友进群
/// @param uids 好友
/// @param teamid 群
/// @param needReviewed 拉好友是否需要被审核
- (void)inviteUers:(NSArray *)uids toTeam:(NSString *)teamid isNeedReviewed:(BOOL)needReviewed
{
    if (!needReviewed) {
        [TIOChat.shareSDK.teamManager addUser:uids
                                       toTeam:self.teamId
                                    sharerUid:nil
                                   completion:^(NSError * _Nullable error) {
            if (error)
            {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
            else
            {
                [MBProgressHUD showInfo:@"已邀请好友入群" toView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    } else {
        TInputAlertController *alert = [TInputAlertController alertWithTitle:@"群主已开启邀请审核，\n邀请好友进群可说明邀请理由" placeholder:@"邀请理由(最多30个字)" inputHeight:40 inputStyle:TAlertInputStyleTextField];
        alert.titleLabel.font = [UIFont systemFontOfSize:16];
        alert.maxCharCount = 30;
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"发送" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            
            NSString *text = [alert.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (text.length == 0) {
                [MBProgressHUD showInfo:@"请输入邀请理由" toView:self.view];
            } else {
                
                if (text.length > 30) {
                    [MBProgressHUD showInfo:@"最多输入30个字" toView:self.view];
                } else {
                    [TIOChat.shareSDK.teamManager applyToAddUsers:uids toTeam:teamid msg:alert.text completion:^(NSError * _Nullable error) {
                        if (error)
                        {
                            [MBProgressHUD showError:error.localizedDescription toView:self.view];
                        }
                        else
                        {
                            [MBProgressHUD showSuccess:@"已提交申请，等待审核通过" toView:self.view];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self.navigationController popViewControllerAnimated:YES];
                            });
                        }
                    }];
                }
            }
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)toSearch:(id)sender
{
    [self searchWithKey:self.searchKey];
}

- (void)refreshList
{
    self.titleOfIndexes = [self.showUsersDataArray valueForKeyPath:@"group"];
    self.tableView.sc_indexViewDataSource = self.titleOfIndexes;
    
    [self.tableView reloadData];
}

- (void)toTeamSessionVC:(NSString *)groupId
{
    if (!groupId)
    {
        [MBProgressHUD showError:@"群ID为空" toView:self.view];
        return;
    }
    
    CBWeakSelf
    [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeTeam
                                              friendId:groupId
                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable recentSession) {
        CBStrongSelfElseReturn
        
        if (error) {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            // 跳转聊天
            TIOSession *session = recentSession.session;
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:session forKey:@"session"];
            [CTMediator.sharedInstance T_remoteToTeamSessionVC:params fromVC:self];
        }
        
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TInviteUserCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TInviteUserCell.class) forIndexPath:indexPath];
    
    TTeamInviteModel *userModel = nil;
    userModel = self.showUsersDataArray[indexPath.section].list[indexPath.row];
    if ([self.selectedUsersCache.allKeys containsObject:userModel.user.userId]) {
        userModel.status = TCellSelectedStatusSelected;
    } else {
        userModel.status = TCellSelectedStatusNone;
    }
    
    [cell refreshData:userModel];
    
    CBWeakSelf
    cell.selectedCallback = ^(BOOL selected) {
        CBStrongSelfElseReturn
        if (selected) {
            [self.selectedUsersCache setObject:[userModel.user copy] forKey:userModel.user.userId];
        } else {
            [self.selectedUsersCache removeObjectForKey:userModel.user.userId];
        }
        [self refreshData];
    };
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleOfIndexes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = nil;
    array = self.showUsersDataArray[section].list;
    
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView.alloc init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 29;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 24)];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    UILabel *label = [UILabel.alloc init];
    label.text = self.titleOfIndexes[section];
    label.textColor = [UIColor colorWithHex:0x999999];
    label.font = [UIFont systemFontOfSize:11.f];
    [label sizeToFit];
    label.left = 16;
    label.centerY = view.middleY;
    [view addSubview:label];
    
    return view;
}

- (void)refreshData
{
    [self refrshNav:self.selectedUsersCache.count];
}

#pragma mark - 搜索

- (void)searchWithKey:(NSString *)key
{
    if (self.type == TTeamSearchTypeCreate) {
        
        TIOSearchOption *option = [TIOSearchOption.alloc init];
        option.searchText = key; // 搜索内容
        option.scope = TIOSearchContentScopeFriend;
        
        [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self->_showUsersDataArray = [self transferOriginData:users];
                [self refreshList];
            }
        }];
    }
    else if (self.type == TTeamSearchTypeInvite)
    {
        [TIOChat.shareSDK.teamManager searchFriends:key notInTeam:self.teamId completion:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self->_showUsersDataArray = [self transferOriginData:users];
                [self refreshList];
            }
        }];
    }
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

#pragma mark - 处理请求的原始数据 -> 目标数据

/// 将原始数据封装成UI使用的数据
/// @param users 原始数据
- (NSArray *)transferOriginData:(NSArray<TIOUser *> *)users
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSString *currentChatIndex = @"";
    /// 处理数据：原始数据  -> 可以直接使用的数据
    for (TIOUser *user in users) {
        if (![user.chatindex isEqualToString:currentChatIndex]) {
            NSString *tempChatIndex = [user.chatindex isEqualToString:@""]?@"*":user.chatindex;
            LYGroupNode *group = [LYGroupNode createNodeWithGroup:tempChatIndex];
            TTeamInviteModel *model = [TTeamInviteModel modelWithUser:user];
            [group.list addObject:model];
            [tempArray addObject:group];
        } else {
            if ([user.chatindex isEqualToString:@""]) {
                
                LYGroupNode *group = nil;
                if (tempArray.count == 0) {
                    group = [LYGroupNode createNodeWithGroup:@"*"];
                    [tempArray addObject:group];
                } else {
                    group = tempArray.lastObject;
                }
                TTeamInviteModel *model = [TTeamInviteModel modelWithUser:user];
                [group.list addObject:model];
            } else {
                LYGroupNode *group = tempArray.lastObject;
                TTeamInviteModel *model = [TTeamInviteModel modelWithUser:user];
                [group.list addObject:model];
            }
        }
        
        currentChatIndex = user.chatindex;
    }
    
    return tempArray;
}

@end
