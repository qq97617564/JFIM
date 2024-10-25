//
//  WalletWaterRechargeViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/26.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWaterRechargeViewController.h"
#import "WalletWaterCell.h"
#import <UIScrollView+EmptyDataSet.h>

@interface WalletWaterRechargeViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak,    nonatomic) UITableView *tableView;
@end

@implementation WalletWaterRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - Height_NavBar - 34)
                                                        style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.emptyDataSetDelegate = self;
    tableView.emptyDataSetSource = self;
    tableView.rowHeight = 70;
    tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    [tableView registerClass:WalletWaterCell.class forCellReuseIdentifier:NSStringFromClass(WalletWaterCell.class)];
    tableView.tableHeaderView = ({
        UIView *v = [UIView.alloc initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 12)];
        v.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        v;
    });
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WalletWaterCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletWaterCell.class)];
    cell.textLabel.text = @"收红包";
    cell.detailTextLabel.text = @"2020-11-3 13:24:56";
    cell.moneyLabel.text = @"+10000.00";
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIViewController *)listViewController
{
    return self;
}

#pragma mark - DZNEmptyDataSetSource

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"wallet_empty"];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *attrString = @"你还没有明细哦！";
    return [[NSAttributedString alloc] initWithString:attrString attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHex:0xAAAAAA], NSFontAttributeName : [UIFont systemFontOfSize:12]}];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return UIColor.whiteColor;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -112;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

@end
