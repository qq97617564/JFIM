//
//  TShareTeamCardListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TShareTeamCardListViewController.h"
#import "TTeamCell.h"

#import "TAddPopupView.h"
#import "TCardAlert.h"
#import "FrameAccessor.h"
#import "MBProgressHUD+NJ.h"
#import "UIButton+Enlarge.h"

#import "CTMediator+ModuleActions.h"

#import "ImportSDK.h"

@interface TShareTeamCardListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *teams;
@property (strong, nonatomic) NSArray *search_teams;
@property (copy,    nonatomic) NSString *searchKey;

@property (assign, nonatomic) BOOL isSearching; // 是否处在搜索模式中
@end

@implementation TShareTeamCardListViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.title = @"选择群聊";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTableView];
    [self requestData];
}

/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.sectionIndexColor = [UIColor colorWithHex:0x909090];
    tableView.sectionIndexMinimumDisplayRowCount = 6;
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 60;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [tableView registerClass:[TTeamCell class] forCellReuseIdentifier:NSStringFromClass(TTeamCell.class)];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    // 搜索。暂时未开启
    UIView *tableHeaderView = ({
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
        searchTF.placeholder = @"搜索群聊名称";
        searchTF.font = [UIFont systemFontOfSize:16];
        searchTF.returnKeyType = UIReturnKeySearch;
        [searchTF addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [searchTF addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
        [view addSubview:searchTF];

        view;
    });
    tableView.tableHeaderView = tableHeaderView;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchAllTeams:^(NSArray<TIOTeam *> * _Nullable teams, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"%@",error);
        }
        else
        {
            self.teams = teams;
            [self.tableView reloadData];
        }
    }];
}

- (void)toSearch:(id)sender
{
    [self searchWithKey:self.searchKey];
}

- (void)searchWithKey:(NSString *)key
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager searchMyTeamsWithKey:self.searchKey
                                            completion:^(NSArray<TIOTeam *> * _Nullable users, NSError * _Nullable error) {
                                                CBStrongSelfElseReturn
                                                
                                                if (!error) {
                                                    self.search_teams = users;
                                                    self.isSearching = YES;
                                                    [self.tableView reloadData];
                                                } else {
                                                    DDLogError(@"%@",error);
                                                    self.searchKey = @"";
                                                }
                                            }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TTeamCell.class)
    forIndexPath:indexPath];
    
    TIOTeam *team = self.isSearching ? self.search_teams[indexPath.row] : self.teams[indexPath.row];

    cell.nickLabel.text = team.name;
    [cell setAvatarUrl:team.avatar];
    // 增加这一行
    cell.role = team.grouprole;
    
    cell.countLabel.text = [NSString stringWithFormat:@"%zd人", team.memberNumber];

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isSearching ? self.search_teams.count : self.teams.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TIOTeam *team = self.isSearching ? self.search_teams[indexPath.row] : self.teams[indexPath.row];
    
    // SDK
    [TIOChat.shareSDK.teamManager checkTeam:team.teamId canSendCardWithCompletion:^(NSError * _Nullable error) {
        if (error)
        {
            [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
        }
        else
        {
            [self alertShare:team];
        }
    }];
    
}

- (void)alertShare:(TIOTeam *)team
{
    TCardAlert *alert = [TCardAlert alertWithAvatar:team.avatar nick:team.name title:@"群聊邀请"];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"发送名片" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        self.t_callback(self, team);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)textFieldEditing:(UITextField *)textField
{
    self.searchKey = textField.text;
    if (textField.text.length == 0) {
        self.isSearching = NO;
        [self.tableView reloadData];
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
