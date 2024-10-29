//
//  GFWalletOrderListVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFWalletOrderListVC.h"
#import "GFWalletOrderListCell.h"
#import <UIScrollView+EmptyDataSet.h>


@interface GFWalletOrderListVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)UITableView *tableView;
@end

@implementation GFWalletOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的订单";
    self.dataArr = @[].mutableCopy;
    self.tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, ScreenWidth(), ScreenHeight() - Height_NavBar ) style:UITableViewStyleGrouped];
    self.tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [[UIColor.alloc init] colorWithAlphaComponent:0];
    [self.tableView registerNib:[UINib nibWithNibName:@"GFWalletOrderListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GFWalletOrderListCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self loadData];
}
-(void)loadData{
    CBWeakSelf
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.gfHttpManager accountGetBalanceOrderWithCompletion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
            return;
        }else{
            [self.dataArr addObjectsFromArray: (NSArray *)responseObject[@"list"]];
            [self.tableView reloadData];
        }
        
        
    }];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *data = self.dataArr[indexPath.section];
    orderModel *model = [orderModel objectWithJSONObject: self.dataArr[indexPath.section]];
    GFWalletOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFWalletOrderListCell" forIndexPath:indexPath];

    [cell setType:model.mode money:model.amount time:model.createtime status:model.status];
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.dataArr.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 16;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 71;
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"暂无数据"attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:14],NSForegroundColorAttributeName: [UIColor colorWithRed:143/255.0 green:156/255.0 blue:175/255.0 alpha:1]}];
    return string;
}

@end
