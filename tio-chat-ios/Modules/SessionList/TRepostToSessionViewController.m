//
//  TCardToRecentSessionViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TRepostToSessionViewController.h"
#import "TCardToSessionCell.h"
#import "TShareSearchView.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "TCardAlert.h"
#import "UIButton+Enlarge.h"

#import "ImportSDK.h"

@interface TRepostToSessionViewController () <UITableViewDelegate,UITableViewDataSource, TIOConversationDelegate, TIOTeamDelegate, UITextFieldDelegate, TShareSearchViewDelegate>
@property (weak, nonatomic) UITableView *tableView;

/// 数据源
@property (strong, nonatomic) NSMutableArray<TIORecentSession *> *allRecentSessions;

@property (weak,   nonatomic) UITextField *textfield;
/// 搜索视图
@property (strong, nonatomic) TShareSearchView *searchView;

@property (assign, nonatomic) BOOL isSearching;

@end

@implementation TRepostToSessionViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = @"选择";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self addSearchUI];
    [self addTableView];
    [self requestData];
}

- (void)addSearchUI
{
    UITextField *searchTF = [UITextField.alloc initWithFrame:CGRectMake(16, Height_NavBar + 10, self.view.width - 32, 36)];
    searchTF.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
    searchTF.layer.cornerRadius = 18;
    searchTF.layer.masksToBounds = YES;
    searchTF.delegate = self;
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
    searchTF.placeholder = @"搜索好友名称";
    searchTF.font = [UIFont systemFontOfSize:16];
    [searchTF addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:searchTF];
    self.textfield = searchTF;
}

/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 56, self.view.width, self.view.height - Height_NavBar - 56) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 75;
    tableView.separatorInset = UIEdgeInsetsMake(0, 81, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE9E9E9];
    [tableView registerClass:[TCardToSessionCell class] forCellReuseIdentifier:NSStringFromClass(TCardToSessionCell.class)];
    tableView.contentInsetTop = 12;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (TShareSearchView *)searchView
{
    if (!_searchView) {
        _searchView = [TShareSearchView.alloc initWithFrame:_tableView.frame];
        _searchView.delegate = self;
    }
    return _searchView;
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.conversationManager fetchServerSessions:^(NSArray<TIORecentSession *> * _Nullable recentSessions, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (!error) {
            
            self.allRecentSessions = [NSMutableArray arrayWithArray:recentSessions];
            [self.tableView reloadData];
        } else {
            DDLogError(@"%@",error);
            
        }
    }];

}

#pragma mark - Actions

- (void)searchWithText:(NSString *)text
{
    self.searchView.searchKey = text;
    
    __block SearchAllResult* friendResults   = nil;
    __block SearchAllResult* teamResults     = nil;
    
    CBWeakSelf
    
    dispatch_group_t group = dispatch_group_create();
    // 搜索好友
    dispatch_group_enter(group);
    
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.searchText = text; // 搜索内容
    option.scope = TIOSearchContentScopeFriend;
    
    [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (!error) {
            
            if (users.count == 0) {
                // 隐藏结果分页
                
            } else {
                // 显示结果分页
                
                // 构造好友分类的数据源
                SearchAllResult *result = [SearchAllResult resultWithChildList:users showNumber:3 index:1 title:@"好友" moreTitle:@"更多好友" identifier:@"TSearchFriendCell"];
                result.stateMoreTitle = @{@(UIControlStateNormal):@"更多好友",@(UIControlStateSelected):@"收起"};
                
                friendResults = result;
            }
            
        }
        
        dispatch_group_leave(group);
        
    }];
    // 搜索群聊
    dispatch_group_enter(group);
    
    [TIOChat.shareSDK.teamManager searchMyTeamsWithKey:text
                                            completion:^(NSArray<TIOTeam *> * _Nullable teams, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (!error)
        {
            
            if (teams.count == 0) {
                // 隐藏结果分页
            } else {
                // 显示结果分页
                
                // 构造群聊分类的数据源
                
                SearchAllResult *result = [SearchAllResult resultWithChildList:teams showNumber:4 index:2 title:@"群聊" moreTitle:@"查看全部" identifier:@"TSearchFriendCell"];
                result.stateMoreTitle = @{@(UIControlStateNormal):@"更多群聊",@(UIControlStateSelected):@"收起"};
                
                teamResults = result;
            }
            
        }
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray *array = [NSMutableArray array];
        if (friendResults) {
            [array addObject:friendResults];
        }
        if (teamResults) {
            [array addObject:teamResults];
        }
        
        if (!friendResults && !teamResults) {
            // 清空搜索结果
            [self.searchView clear];
        } else {
            // 显示
            [self.searchView refreshData:array];
        }
        
    });
}

- (void)textFieldEditing:(UITextField *)textField
{
    self.searchView.searchKey = textField.text;
    if (textField.text) {
        if (textField.markedTextRange == nil) {
            // 搜索
            [self searchWithText:textField.text];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showResultView];
    
    return YES;
}

- (void)showResultView
{
    if (_searchView) {
        return;
    }
    
    [UIView transitionWithView:self.searchView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.view addSubview:self.searchView];
    } completion:^(BOOL finished) {
        self.isSearching = YES;
    }];
}

- (void)hideResultView
{
    [UIView transitionWithView:self.searchView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.searchView removeFromSuperview];
    } completion:^(BOOL finished) {
        self.isSearching = NO;
    }];
}

- (void)tshare_didSelectedUserOrTeam:(id)data isTeam:(BOOL)team
{
    // 构造session
    NSString *uid = nil;
    NSString *avatar = nil;
    NSString *name = nil;
    if (team) {
        TIOTeam *team = data;
        uid = team.teamId;
        avatar = team.avatar;
        name = team.name;
    } else {
        TIOUser *user = data;
        uid = user.userId;
        avatar = user.avatar;
        name = user.remarkname;
    }
    TIOSession *session = [TIOSession session:@"" toUId:uid type:team?TIOSessionTypeTeam:TIOSessionTypeP2P];
    session.avatar = avatar;
    session.name = name;
    
    // 弹窗显示
    [self alertShare:session];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCardToSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TCardToSessionCell.class) forIndexPath:indexPath];
    
    cell.nickLabel.text = self.allRecentSessions[indexPath.row].session.name;

    NSString *avatar = self.allRecentSessions[indexPath.row].session.avatar;
    [cell setAvatarUrl:avatar];
    
    if (self.allRecentSessions[indexPath.row].session.sessionType != TIOSessionTypeP2P) {
        NSString *countStr = nil;
        if (self.allRecentSessions[indexPath.row].joinnum) {
            countStr = [self.allRecentSessions[indexPath.row].joinnum stringByAppendingString:@"人"];
        }
        cell.countLabel.text = countStr;
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allRecentSessions.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIORecentSession *recentsession = self.allRecentSessions[indexPath.row];
    
    [self alertShare:recentsession.session];
}

- (void)alertShare:(TIOSession *)session
{
    CBWeakSelf
    TCardAlert *alert = [TCardAlert alertWithAvatar:session.avatar nick:session.name title:self.type==1?@"发送给：":@"转发给："];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        CBStrongSelfElseReturn
    }]];
    [alert addAction:[TAlertAction actionWithTitle:self.type==1?@"发送名片":@"确定转发" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        if (self.t_callback) {
            self.t_callback(self, session);
        }
        CBStrongSelfElseReturn
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textfield resignFirstResponder];
}

@end
