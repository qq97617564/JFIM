//
//  TShareFriendCardListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TShareFriendCardListViewController.h"
#import "TFriendCell.h"
#import "TSortString.h"
#import "UITableView+SCIndexView.h"
#import "FrameAccessor.h"
#import "TCardAlert.h"

/// SDK
#import "ImportSDK.h"

@interface TShareFriendCardListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak,   nonatomic) UITableView   *tableView;
@property (strong, nonatomic) NSMutableArray    *allFriends;     // 排序前的数据源
@property (strong, nonatomic) NSDictionary  *sortedfriends;  // 排序后的数据源
@property (strong, nonatomic) NSArray   *titleOfIndexes;

@property (strong, nonatomic) NSMutableArray    *search_allFriends;
@property (strong, nonatomic) NSDictionary  *search_sortedfriends;
@property (copy,    nonatomic) NSString *searchKey;

@property (assign, nonatomic) BOOL isSearching; // 是否处在搜索模式中

@end

@implementation TShareFriendCardListViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = @"选择好友";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.leftBarButtonText = self.toSelected ? @"选择" : @"选择好友";
    [self addTableView];
    [self requestData];
}

/// TableView
- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.sectionIndexColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.sectionIndexMinimumDisplayRowCount = 6;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TFriendCell class] forCellReuseIdentifier:NSStringFromClass(TFriendCell.class)];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
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
        [searchTF addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [searchTF addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
        [view addSubview:searchTF];

        view;
    });
    tableView.tableHeaderView = tableHeaderView;
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
    configuration.indexItemRightMargin = 16;
    configuration.indicatorRightMargin = 50;
    configuration.indexItemSelectedTextColor = [UIColor colorWithHex:0x4C94E8];
    configuration.indexItemTextColor = [UIColor colorWithHex:0x909090];
    configuration.indexItemSelectedBackgroundColor = UIColor.clearColor;
    configuration.indicatorTextFont = [UIFont systemFontOfSize:12];
    configuration.indicatorTextFont = [UIFont systemFontOfSize:20];
    tableView.sc_indexViewConfiguration = configuration;
    tableView.sc_translucentForTableViewInNavigationBar = NO;
}

- (void)toSearch:(id)sender
{
    [self searchWithKey:self.searchKey];
}

/// 获取数据
- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.friendManager fetchMyFriends:^(NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
        
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            self.allFriends = [NSMutableArray arrayWithArray:users];
            [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick" callback:^(NSMutableDictionary * _Nonnull sortDic) {
                self.sortedfriends = sortDic;
                [self refreshList];
            }];
        }
        
    }];
}

- (void)searchWithKey:(NSString *)key
{
    CBWeakSelf
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.searchText = key;
    
    [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option
                                                 completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        
        if (error) {
            
            DDLogError(@"%@",error);
        } else {
            self.search_allFriends = [NSMutableArray arrayWithArray:users];
            [TSortString sortAndGroupForArray:users PropertyName:@"remarkname" nextPropertyName:@"nick" callback:^(NSMutableDictionary * _Nonnull sortDic) {
                self.search_sortedfriends = sortDic;
                [self refreshList];
                self.isSearching = YES;
                [self refreshList];
            }];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIOUser *user = nil;
    if (self.isSearching) {
        user = self.search_sortedfriends[self.titleOfIndexes[indexPath.section]][indexPath.row];
    } else {
        user = self.sortedfriends[self.titleOfIndexes[indexPath.section]][indexPath.row];
    }
    
    TFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TFriendCell.class)
                                                        forIndexPath:indexPath];
    cell.contentView.backgroundColor = UIColor.whiteColor;
//    if ([user.userId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId]) {
//        [cell setNick:[NSString stringWithFormat:@"%@(自己) ",user.nick]];
//    } else {
        if (user.remarkname.length) {
            [cell setNick:user.remarkname];
        } else {
            [cell setNick:user.nick];
        }
//    }
    
    [cell setDetail:nil];
    
    [cell setAvatarUrl:user.avatar];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleOfIndexes.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.isSearching ? self.search_sortedfriends[self.titleOfIndexes[section]] : self.sortedfriends[self.titleOfIndexes[section]];
    return array.count;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 24)];
    view.backgroundColor = tableView.backgroundColor;
    UILabel *label = [UILabel.alloc init];
    label.text = self.titleOfIndexes[section];
    label.textColor = [UIColor colorWithHex:0x999999];
    label.font = [UIFont systemFontOfSize:12.f];
    [label sizeToFit];
    label.left = 16;
    label.centerY = view.middleY;
    [view addSubview:label];
    
    return view;
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
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIOUser *user = nil;
    
    if (self.isSearching) {
        user = self.search_sortedfriends[self.titleOfIndexes[indexPath.section]][indexPath.row];
    } else {
        user = self.sortedfriends[self.titleOfIndexes[indexPath.section]][indexPath.row];
    }
    
    [self alertShare:user];
}

#pragma mark - private

- (void)refreshList
{
    if (self.isSearching) {
        self.titleOfIndexes = [TSortString sortForStringAry:self.search_sortedfriends.allKeys];
    } else {
        self.titleOfIndexes = [TSortString sortForStringAry:self.sortedfriends.allKeys];
    }
    self.tableView.sc_indexViewDataSource = self.titleOfIndexes;
    
    [self.tableView reloadData];
}

- (void)alertShare:(TIOUser *)user
{
    NSString *title = self.toSelected ? @"发送给:" : @"好友推荐";
    TCardAlert *alert = [TCardAlert alertWithAvatar:user.avatar nick:user.nick title:title];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"发送名片" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        self.t_callback(self, user);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)textFieldEditing:(UITextField *)textField
{
    self.searchKey = textField.text;
    if (textField.text.length == 0) {
        self.isSearching = NO;
        [self refreshList];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isSearching = YES;
    return YES;
}

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.isSearching = NO;
    [self.view endEditing:YES];
}

@end
