//
//  TThirdBindListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TThirdBindListViewController.h"
#import "FrameAccessor.h"
#import "TCommonCell.h"
#import "ImportSDK.h"

@interface TThirdBindListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong,  nonatomic) TCommonCell *wxCell;
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray<NSArray *> *cells;
@end

@implementation TThirdBindListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"第三方登录";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    self.cells = @[self.wxCell];
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (TCommonCell *)wxCell
{
    if (!_wxCell) {
        _wxCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _wxCell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        _wxCell.textLabel.text = @"微信";
        _wxCell.detailTextLabel.text = TIOChat.shareSDK.loginManager.userInfo.thirdbindflag ? @"已绑定" : @"未绑定";
        _wxCell.hasIndiractor = YES;
    }
    return _wxCell;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.section][indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ({
        UIView *view = [UIView.alloc init];
        view.backgroundColor = tableView.backgroundColor;
        view;
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
