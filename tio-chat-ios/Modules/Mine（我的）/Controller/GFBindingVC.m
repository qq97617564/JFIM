//
//  GFBindingVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFBindingVC.h"
#import "TCommonCell.h"
#import "GFBindingWXVC.h"
#import "GFBindingZFBVC.h"
#import "GFBindingBankVC.h"

@interface GFBindingVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) TCommonCell *wxCell;
@property (strong,  nonatomic) TCommonCell *zfbCell;
@property (strong,  nonatomic) TCommonCell *bankCell;

@property (strong,  nonatomic) NSArray<TCommonCell *> *cells;



@end

@implementation GFBindingVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"充值卡绑定";
    self.navigationBar.titleL.text = @"充值卡绑定";
//    self.wxCell = [self cellWithTitle:@"绑定微信" icon:[UIImage imageNamed:@"Group 1321315564"]];
//    self.zfbCell = [self cellWithTitle:@"绑定支付宝" icon:[UIImage imageNamed:@"Group 1321315562"]];
    self.bankCell = [self cellWithTitle:@"绑定银行卡" icon:[UIImage imageNamed:@"Group 1321315563"]];
   
    self.cells = @[/*self.wxCell, self.zfbCell,*/self.bankCell];
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar+16, ScreenWidth(), 53*self.cells.count) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.scrollEnabled = false;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 53;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self loadData];
}
-(void)loadData{
    [TIOChat.shareSDK.gfHttpManager  accountGetBnakDetailWithType:@"bank" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            
        }else{
            if (responseObject[@"cardno"]) {
                self.bankCell.textLabel.text = responseObject[@"cardno"];
            }

        }
    }];
}


#pragma mark - tableviewdelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _wxCell) {
        // 绑定微信
        GFBindingWXVC *vc = [[GFBindingWXVC alloc]init];
        [self.navigationController pushViewController:vc animated:true];
    } else if (cell == _zfbCell) {
        // 绑定支付宝
        GFBindingZFBVC *vc = [[GFBindingZFBVC alloc]init];
        [self.navigationController pushViewController:vc animated:true];
    }else if (cell == _bankCell) {
        // 绑定银行卡
        GFBindingBankVC *vc = [[GFBindingBankVC alloc]init];
        [self.navigationController pushViewController:vc animated:true];

    }
}

#pragma mark -  工厂

- (TCommonCell *)cellWithTitle:(NSString *)title icon:(UIImage *)icon
{
    TCommonCell *cell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.hasIndiractor = true;
    cell.textLabel.textColor = [UIColor colorWithHex:0x161A25];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = title;
    cell.imageView.image = icon;
    CGRect frame = cell.imageView.frame;
    cell.imageView.frame = CGRectMake(8, frame.origin.y, frame.size.width, frame.size.height);
    
    return cell;
}

@end
