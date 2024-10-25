//
//  AtListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "AtListViewController.h"
#import "TMemberCell.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "UIImageView+Web.h"
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"
#import "TTeamDeleteModel.h"
#import <MJRefresh.h>
#import "CTMediator+ModuleActions.h"

@interface AtListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray *members;
@property (strong,  nonatomic) TIOTeamMember *teamUser;
@property (strong,  nonatomic) UITableViewCell *allCell;

@property (copy,    nonatomic) NSString *searchKey;
@property (assign,  nonatomic) BOOL isSearching; // 是否处在搜索模式中
@end

@implementation AtListViewController

- (instancetype)initWithTeamUser:(TIOTeamMember *)teamUser
{
    self = [super init];
    if (self) {
        self.teamUser = teamUser;
        self.leftBarButtonText = @"选择提醒的人";
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
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [tableView registerClass:[TMemberCell class] forCellReuseIdentifier:NSStringFromClass(TMemberCell.class)];
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
        searchTF.placeholder = @"搜索好友名称";
        searchTF.font = [UIFont systemFontOfSize:16];
        searchTF.returnKeyType = UIReturnKeySearch;
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
    [TIOChat.shareSDK.teamManager searchMember:nil inTeam:self.teamUser.groupId completion:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
        self.members = users;
        [self.tableView reloadData];
    }];
}

#pragma mark - get

- (UITableViewCell *)allCell
{
    if (!_allCell) {
        _allCell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _allCell.imageView.image = [UIImage imageNamed:@"at_all"];
        _allCell.textLabel.text = @"提醒所有人";
    }
    return _allCell;
}

#pragma mark - Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.allCell;
    }
    
    TMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TMemberCell.class) forIndexPath:indexPath];
    TIOTeamMember *member = self.members[indexPath.row];
    
    // 默认禁用多选功能
    TCellSelectedStatus status = TCellSelectedStatusDisabled;
    [cell refreshData:member isSelf:NO status:status];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0 ? 12 : 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 24)];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    if (section == 1) {
        [view addSubview:({
            UILabel *label = [UILabel.alloc init];
            label.text = @"全部成员";
            label.textColor = [UIColor colorWithHex:0x999999];
            label.font = [UIFont systemFontOfSize:13];
            [label sizeToFit];
            label.left = 16;
            label.centerY = view.centerY;
            label;
        })];
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        self.t_callback(self, @"all");
        return;
    }
    
    if (self.t_callback) {
        TIOTeamMember *member = self.members[indexPath.row];
        self.t_callback(self, member);
    }
}

- (void)toSearch:(id)sender
{
    [self searchWithKey:self.searchKey];
}

- (void)searchWithKey:(NSString *)key
{
    [TIOChat.shareSDK.teamManager searchMember:key inTeam:self.teamUser.groupId completion:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
        self.members = users;
        [self.tableView reloadData];
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
