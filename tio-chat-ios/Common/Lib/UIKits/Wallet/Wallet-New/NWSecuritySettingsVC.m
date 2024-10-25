//
//  WalletSecuritySettingsVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/10/30.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "NWSecuritySettingsVC.h"

#import "TCommonCell.h"
#import "FrameAccessor.h"

#import "NWSettingPayPasswordVC.h"
#import "NWSmsAuthorizationVC.h"

@interface NWSecuritySettingsVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,   weak) UITableView *tableView;
@property (nonatomic,   weak) TCommonCell *realNameCell;
@property (nonatomic,   weak) TCommonCell *dataCerCell;
@property (nonatomic,   weak) TCommonCell *modifyPwdCell;
@property (nonatomic,   weak) TCommonCell *forgetPwdCell;
@property (nonatomic,   strong) NSArray *cells;
@end

@implementation NWSecuritySettingsVC

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = @"安全设置";
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
    TCommonCell *realNameCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    realNameCell.hasIndiractor = YES;
    realNameCell.textLabel.text = @"实名认证";
    realNameCell.detailTextLabel.text = @"未实名";
    
    TCommonCell *dataCerCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    dataCerCell.hasIndiractor = YES;
    dataCerCell.textLabel.text = @"数字证书";
    dataCerCell.detailTextLabel.text = @"未安装";
    
    TCommonCell *modifyPwdCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    modifyPwdCell.hasIndiractor = YES;
    modifyPwdCell.textLabel.text = @"修改支付密码";
    self.modifyPwdCell = modifyPwdCell;
    
    TCommonCell *forgetPwdCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    forgetPwdCell.hasIndiractor = YES;
    forgetPwdCell.textLabel.text = @"忘记支付密码";
    self.forgetPwdCell = forgetPwdCell;
    
    self.cells = @[@[modifyPwdCell, forgetPwdCell]];
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.section][indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = self.cells[section];
    return rows.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView.alloc init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.realNameCell) { // 实名认证
        
    } else if (cell == self.dataCerCell) { // 数字证书
        
    } else if (cell == self.modifyPwdCell) { // 修改支付密码
        /// 先去验证身份
        NWSettingPayPasswordVC *vc = [NWSettingPayPasswordVC.alloc initWithTitle:@"修改支付密码" code:NWPayPasswordCodeAuthorization];
        CBWeakSelf
        vc.handler = ^(UIViewController * _Nonnull vController, BOOL re, NSString *pwd) {
            CBStrongSelfElseReturn
            if (re) {
                // 正式去修改密码
                NWSettingPayPasswordVC *vc = [NWSettingPayPasswordVC.alloc initWithTitle:@"修改支付密码" code:NWPayPasswordCodeModify];
                vc.oldPassword = pwd;
                CBWeakSelf
                vc.handler = ^(UIViewController * _Nonnull vControllerr, BOOL re, NSString * _Nonnull pwd) {
                    CBStrongSelfElseReturn
                    [vControllerr.navigationController popViewControllerAnimated:YES];
                };
                [vController.navigationController pushViewController:vc animated:YES];
                NSArray *tempVCs = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(0, self.navigationController.viewControllers.count-2)];
                [self.navigationController setViewControllers:[tempVCs arrayByAddingObject:vc]];
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else { // 忘记支付密码
        NWSmsAuthorizationVC *vc = [NWSmsAuthorizationVC.alloc init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)modifyPwd
{
    

}

@end
