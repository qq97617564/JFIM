//
//  TTeamSearchInviteViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamSearchInviteViewController.h"
#import "TInputAlertController.h"
#import "TInviteSearchUserCell.h"
#import "MBProgressHUD+NJ.h"
#import "FrameAccessor.h"
#import <MJRefresh.h>
#import "ImportSDK.h"
#import "CTMediator+ModuleActions.h"

@interface TTeamSearchInviteViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) TTeamSearchType type;
@property (strong, nonatomic) NSArray<TIOUser *> *resultDatas;
@property (strong, nonatomic) NSArray<TIOTeamMember *> *memberResultData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, TIOUser *> *selectedCache;
@property (weak, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSString *searchKey;
@end

@implementation TTeamSearchInviteViewController

- (instancetype)initWithTitle:(NSString *)title type:(TTeamSearchType)type
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = title;
        self.type = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedCache = [NSMutableDictionary dictionary];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self setupUI];
    
    if (self.type != TTeamSearchTypeTransfer) {
        [self setupNav];
    }
    [self addNaivigationBar];
}

- (void)setupNav
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x4C94E8]];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.viewSize = CGSizeMake(60, 28);
        button.layer.cornerRadius = 14;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self action:@selector(didClickDone:) forControlEvents:UIControlEventTouchUpInside];
        
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
        [button setBackgroundColor:[UIColor colorWithHex:0x4C94E8]];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button sizeToFit];
        button.width += 20;
        button.layer.cornerRadius = 14;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self action:@selector(didClickDone:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)didClickDone:(id)sender
{
    if (!self.selectedCache.allValues.count) {
        [MBProgressHUD showInfo:@"请选择好友入群" toView:self.view];
        return;
    }
    
    NSMutableArray *uids = [NSMutableArray arrayWithCapacity:self.selectedCache.allValues.count];
    
    [self.selectedCache.allValues enumerateObjectsUsingBlock:^(TIOUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids addObject:obj.userId];
    }];
    
    if (uids.count) {
        
        if (self.type == TTeamSearchTypeCreate)
        {
            ///
            /// 创建群
            ///
            TInputAlertController *alert = [TInputAlertController alertWithTitle:@"群聊名称" placeholder:@"" inputHeight:70 inputStyle:TAlertControllerTextView];
            
            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }]];
            
            [alert addAction:[TAlertAction actionWithTitle:@"确认" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                
                if (alert.text.length > 30) {
                    [MBProgressHUD showInfo:@"群名最多30个字" toView:UIApplication.sharedApplication.keyWindow];
                    return;
                }
                
//                TIOTeamName *nameObject = [TIOTeamName.alloc init];
//                nameObject.name = alert.text;
//                nameObject.allowServerToUpdateAutomatically = [alert.text componentsSeparatedByString:@","].count>1;
                
                [TIOChat.shareSDK.teamManager createTeamName:alert.text introduction:@"" users:uids completion:^(NSError * _Nullable error, NSString * _Nullable teamId) {
                    if (error)
                    {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    }
                    else
                    {
                        [MBProgressHUD showInfo:@"建群成功" toView:self.view];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
                        [self toCancel:nil];
                    });
                }
            }];
        }
    }
}

- (void)addNaivigationBar
{
    UITextField *searchField = [UITextField.alloc initWithFrame:CGRectMake(16, Height_NavBar + 10, self.view.width - 16 - 16, 36)];
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
    [self.view addSubview:searchField];
    [searchField becomeFirstResponder];
}

- (void)setupUI
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 60, self.view.width, self.view.height - Height_NavBar - 60) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:TInviteSearchUserCell.class forCellReuseIdentifier:NSStringFromClass(TInviteSearchUserCell.class)];
    tableView.mj_footer.hidden = YES;
    tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部搜索结果 —" forState:MJRefreshStateNoMoreData];
        
        footer;
    });
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)toSearch:(UITextField *)textfield
{
    if (!textfield.text) {
        [MBProgressHUD showInfo:@"请输入搜索内容" toView:self.view];
        return;
    }
    
    if (self.type == TTeamSearchTypeCreate) {
        
        TIOSearchOption *option = [TIOSearchOption.alloc init];
        option.searchText = textfield.text; // 搜索内容
        option.scope = TIOSearchContentScopeFriend;
        
        [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self.searchKey = textfield.text;
                
                self.resultDatas = users;
                self.tableView.mj_footer.hidden = users.count == 0;
                if (lastPage) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                [self.tableView reloadData];
            }
        }];
    }
    else if (self.type == TTeamSearchTypeInvite)
    {
        [TIOChat.shareSDK.teamManager searchFriends:textfield.text notInTeam:self.teamId completion:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                self.searchKey = textfield.text;
                
                self.resultDatas = users;
                self.tableView.mj_footer.hidden = users.count == 0;
                [self.tableView reloadData];
            }
        }];
    }
    else
    {
        // TODO: 转让群时，搜索群成员待实现
    }
}

- (void)toCancel:(id)sender
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSArray *vcs = [[viewControllers subarrayWithRange:NSMakeRange(0, viewControllers.count - 3)] arrayByAddingObject:self];
    [self.navigationController setViewControllers:vcs];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toTeamSessionVC:(NSString *)groupId
{
    if (!groupId)
    {
        [MBProgressHUD showError:@"群ID为空" toView:self.view];
        return;
    }
    
    [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeTeam
                                              friendId:groupId
                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable recentSession) {
        
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
    TIOUser *user = self.resultDatas[indexPath.row];
    
    
    TInviteSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TInviteSearchUserCell.class)];
    
    // 默认禁用多选功能
    TCellSelectedStatus status = TCellSelectedStatusDisabled;
    
    if (self.type != TTeamSearchTypeTransfer)
    {   // 不是转让群类型 显示复选按钮
        if (self.selectedCache[[NSString stringWithFormat:@"%zd",indexPath.row]])
        {   // 已选中
            status = TCellSelectedStatusSelected;
        }
        else
        {   // 未选中
            status = TCellSelectedStatusNone;
        }
    }
    
    [cell refreshAvatar:user.avatar sex:1 nick:user.nick relation:0 key:self.searchKey status:status];
    cell.selectedCallback = ^(BOOL selected) {
        if (selected) {
            [self.selectedCache setObject:user forKey:[NSString stringWithFormat:@"%zd",indexPath.row]];
        } else {
            [self.selectedCache removeObjectForKey:[NSString stringWithFormat:@"%zd",indexPath.row]];
        }
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
}

- (void)refreshData
{
    NSInteger total = self.selectedCache.allValues.count;
    [self refrshNav:total];
}

@end
