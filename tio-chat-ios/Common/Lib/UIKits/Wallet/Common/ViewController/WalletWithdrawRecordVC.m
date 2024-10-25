//
//  WalletWithdrawRecordVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWithdrawRecordVC.h"
#import "WalletWithdrawCell.h"
#import "WalletWithdrawDetailVC.h"

#import "ImportSDK.h"

#import "FrameAccessor.h"
#import <MJRefresh/MJRefresh.h>

#import "WalletManager.h"

@interface WalletWithdrawRecordVC () <UITableViewDelegate, UITableViewDataSource>
@property (strong,  nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray *dataArray;
@property (assign,  nonatomic) NSInteger pageNumber;
@end

@implementation WalletWithdrawRecordVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"提现记录";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageNumber = 1;
    [self setupUI];
    [self beginRefreshing:nil];
}

- (void)beginRefreshing:(id)sender
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWithdrawRecordsWithPageNumber:self.pageNumber completion:^(NSArray<TIOWalletWithdraw *> * _Nullable withdrawList, BOOL first, BOOL last, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [self.tableView.mj_footer resetNoMoreData];
        
        self.tableView.mj_footer.hidden = withdrawList.count==0;
        
        if (self.pageNumber == 1) {
            self.dataArray = withdrawList;
        } else {
            self.dataArray = [self.dataArray arrayByAddingObjectsFromArray:withdrawList];
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

- (void)setupUI
{
    self.tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    self.tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.tableView registerClass:WalletWithdrawCell.class forCellReuseIdentifier:NSStringFromClass(WalletWithdrawCell.class)];
    self.tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部 —" forState:MJRefreshStateNoMoreData];
        [footer setRefreshingTarget:self refreshingAction:@selector(beginRefreshing:)];
        
        footer;
    });
    [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIOWalletWithdraw *model = [self.dataArray objectAtIndex:indexPath.row];
    WalletWithdrawCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletWithdrawCell.class)];
    
    NSString *cardNo = @"卡号丢失";
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        cardNo = model.bankcardnumber.length>4?[model.bankcardnumber substringFromIndex:model.bankcardnumber.length-4]:model.bankcardnumber;
    } else if (WalletManager.shareInstance.vendor == WalletVendorNewPay) {
        cardNo = model.cardno.length>4?[model.cardno substringFromIndex:model.cardno.length-4]:model.cardno;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"提现到%@（%@）",model.bankname,cardNo];
    cell.detailTextLabel.text = model.bizcreattime;
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2f",model.amount/100.f];
    if ([model.status isEqualToString:@"FAIL"]) {
        cell.moneyLabel.textColor = [UIColor colorWithHex:0x999999];
        cell.commissionLabel.text = @"提现失败";
        cell.commissionLabel.textColor = [UIColor colorWithHex:0xFFA058];
    } else {
        cell.moneyLabel.textColor = [UIColor colorWithHex:0x4C94FF];
        cell.commissionLabel.text = @"";
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /// test -
    TIOWalletWithdraw *model = self.dataArray[indexPath.row];
    
    WalletWithdrawDetailVC *vc = [WalletWithdrawDetailVC.alloc init];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
