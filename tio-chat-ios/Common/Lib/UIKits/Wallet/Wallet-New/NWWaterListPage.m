//
//  NWWaterListPage.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/2.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWWaterListPage.h"
#import "WalletWaterCell.h"
#import "NWWaterDetailVC.h"

#import "WalletManager.h"

#import <UIScrollView+EmptyDataSet.h>
#import <MJRefresh/MJRefresh.h>

@interface NWWaterListPage () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak,    nonatomic) UITableView *tableView;
@property (assign,  nonatomic) NSInteger pageNumber;
@property (strong,  nonatomic) NSArray<TIOWalletWaterDeatil *> *dataArray;
@end

@implementation NWWaterListPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageNumber = 1;
    [self setupUI];
    [self beginRefreshing:nil];
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
    tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部明细 —" forState:MJRefreshStateNoMoreData];
        [footer setRefreshingTarget:self refreshingAction:@selector(beginRefreshing:)];
        
        footer;
    });
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)beginRefreshing:(id)sender
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletWaterListWithRequestType:self.waterRequestType pageNumber:self.pageNumber completion:^(NSArray<TIOWalletWaterDeatil *> * _Nullable list, BOOL first, BOOL last, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [self.tableView.mj_footer resetNoMoreData];
        
        if (self.pageNumber == 1) {
            self.dataArray = list;
        } else {
            self.dataArray = [self.dataArray arrayByAddingObjectsFromArray:list];
        }
        
        if (last) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
            self.pageNumber++; // 下一次查询的页码
        }
        
        [self.tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIOWalletWaterDeatil *model = self.dataArray[indexPath.row];
    
    NSString *symbolFlag = model.coinflag == 1 ? @"+" : @"-";
    
    WalletWaterCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletWaterCell.class)];
    cell.detailTextLabel.text = model.bizcreattime;
    
    NSString *amount = nil;
    NSString *status = nil;
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        cell.textLabel.text = model.bizstr;
        amount  = [NSString stringWithFormat:@"%@%.2f",symbolFlag,model.amount/100.f];
        status  = model.orderstatus;
    } else {
        cell.textLabel.text = model.remark;
        amount  = [NSString stringWithFormat:@"%@%.2f",symbolFlag,model.cny/100.f];
        status  = model.status;
    }
    
    UIColor *textColor = [self colorInStatus:status mode:model.mode coinflag:model.coinflag];
    
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        if (model.mode == 1) {
            // 充值
            if ([model.orderstatus isEqualToString:@"SUCCESS"]) {
                cell.remarkLabel.text = nil;
            } else if ([model.orderstatus isEqualToString:@"PROCESS"]) {
                cell.remarkLabel.text = @"处理中";
            } else if ([model.orderstatus isEqualToString:@"FAIL"]) {
                cell.remarkLabel.text = @"失败";
            } else {
                cell.remarkLabel.text = [NSString stringWithFormat:@"订单状态（%@）",model.orderstatus];
            }
        } else if (self.dataArray[indexPath.row].mode == 2) {
            // 提现
            if ([model.orderstatus isEqualToString:@"SUCCESS"]) {
                cell.remarkLabel.text = nil;
            } else if ([model.orderstatus isEqualToString:@"PROCESS"]) {
                cell.remarkLabel.text = @"处理中";
            } else if ([model.orderstatus isEqualToString:@"FAIL"]) {
                cell.remarkLabel.text = @"失败";
            } else {
                cell.remarkLabel.text = [NSString stringWithFormat:@"订单状态（%@）",model.orderstatus];
            }
        } else {
            // 红包
            if ([model.orderstatus isEqualToString:@"SUCCESS"]) {
                cell.remarkLabel.text = nil;
            } else if ([model.orderstatus isEqualToString:@"PROCESS"]) {
                cell.remarkLabel.text = @"处理中";
            } else if ([model.orderstatus isEqualToString:@"FAIL"]) {
                cell.remarkLabel.text = @"失败";
            } else {
                cell.remarkLabel.text = [NSString stringWithFormat:@"订单状态（%@）",model.orderstatus];
            }
        }
    } else {
        if ([model.status isEqualToString:@"1"]) {
            cell.remarkLabel.text = nil;
        } else if ([model.status isEqualToString:@"-1"]) {
            cell.remarkLabel.text = @"处理中";
        } else if ([model.status isEqualToString:@"3"]) {
            cell.remarkLabel.text = @"失败";
        } else {
            cell.remarkLabel.text = [NSString stringWithFormat:@"订单状态（%@）",model.status];
        }
    }
    
    cell.moneyLabel.text = amount;
    cell.moneyLabel.textColor = textColor;
    
    return cell;
}

- (UIColor *)colorInStatus:(NSString *)status mode:(NSInteger)mode coinflag:(NSInteger)coinflag
{
    if ([status isEqualToString:@"SUCCESS"] || [status isEqualToString:@"1"]) {
        // 成功
        if (coinflag == 1) {
            // 收到
            return [UIColor colorWithHex:0x4C94FF];
        }
        // 发出
        return [UIColor colorWithHex:0x333333];
    } else if ([status isEqualToString:@"PROCESS"] || [status isEqualToString:@"-1"]) {
        // 处理中
        return [UIColor colorWithHex:0x333333];
    } else {
        // 失败
        return [UIColor colorWithHex:0x999999];
    }
    
//    if (mode == 1) {
//        // 充值
//        if ([status isEqualToString:@"SUCCESS"] || [status isEqualToString:@"PROCESS"]) {
//            return [UIColor colorWithHex:0x4C94FF];
//        } else {
//            return [UIColor colorWithHex:0x999999];
//        }
//    } else if (mode == 2) {
//        // 提现
//        if ([status isEqualToString:@"SUCCESS"] || [status isEqualToString:@"PROCESS"]) {
//            return [UIColor colorWithHex:0x333333];
//        } else {
//            return [UIColor colorWithHex:0x999999];
//        }
//    } else {
//        // 红包
//        if ([status isEqualToString:@"SUCCESS"] || [status isEqualToString:@"PROCESS"]) {
//            return [UIColor colorWithHex:0x4C94FF];
//        } else {
//            return [UIColor colorWithHex:0x999999];
//        }
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NWWaterDetailVC *vc = [NWWaterDetailVC.alloc init];
    vc.model = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
