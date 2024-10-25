//
//  NWHomeViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/2.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWHomeViewController.h"
#import "NWSecuritySettingsVC.h"
#import "NWAccountVC.h"
#import "NWWaterListContainer.h"
#import "NWRechargeVC.h"
#import "WalletWithdrawViewController.h"
#import "WalletRedPackageRecordVC.h"
#import "NWBankListVC.h"
#import "NWWithdrawVC.h"

#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "UIButton+Enlarge.h"
#import "TCommonCell.h"
#import "ImportSDK.h"

@interface NWHomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,   weak) UILabel *moneyLabel;
@property (nonatomic,   weak) UITableView *tableview;
@property (nonatomic,   strong) NSArray *cells;
@property (nonatomic,   weak) TCommonCell *accountCell;
@property (nonatomic,   weak) TCommonCell *wCell;
@property (nonatomic,   weak) TCommonCell *redCell;
@property (nonatomic,   weak) TCommonCell *bankCell;
@property (nonatomic,   weak) TCommonCell *secCell;
@property (nonatomic,   weak) TCommonCell *helpCell;
@property (nonatomic,   assign) CGFloat blance;
@end

@implementation NWHomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavgationbar];
    [self setupUI];
}

- (void)setupNavgationbar
{
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront:self.navigationBar];
     
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
        [button setTitle:@"钱包" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-40];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)setupUI
{
    UIView *statusView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statusView.backgroundColor = [UIColor colorWithHex:0x4C94FF];
    [self.view addSubview:statusView];
    
    UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, Height_StatusBar, self.view.width, 221)];
    bg.image = [UIImage imageNamed:@"wallet_bg"];
    bg.userInteractionEnabled = YES;
    [self.view addSubview:bg];
    
    UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eyeButton setFrame:CGRectMake(0, 0, 90, 25)];
    eyeButton.centerX = bg.middleX;
    eyeButton.top = 44;
    eyeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [eyeButton setImage:[UIImage imageNamed:@"wallet_open"] forState:UIControlStateNormal];
    [eyeButton setImage:[UIImage imageNamed:@"wallet_close"] forState:UIControlStateSelected];
    [eyeButton setTitle:@" 我的余额" forState:UIControlStateNormal];
    [eyeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [eyeButton addTarget:self action:@selector(didClickedEye:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:eyeButton];
    
    UILabel *moneyLabel = [UILabel.alloc initWithFrame:CGRectMake(20, eyeButton.bottom + 4, bg.width - 40, 42)];
    moneyLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:34];
    moneyLabel.textColor = UIColor.whiteColor;
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    [bg addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    [self setMoney:@"0.00"];
    // 提现
    UIButton *withdrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    withdrawButton.bounds = CGRectMake(0, 0, 114, 44);
    withdrawButton.top = moneyLabel.bottom + 20;
    withdrawButton.right = bg.middleX - 26;
    withdrawButton.layer.cornerRadius = 22;
    withdrawButton.layer.masksToBounds = YES;
    withdrawButton.layer.borderColor = UIColor.whiteColor.CGColor;
    withdrawButton.layer.borderWidth = 1.f;
    withdrawButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [withdrawButton setTitle:@"提现" forState:UIControlStateNormal];
    [withdrawButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [withdrawButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] forState:UIControlStateNormal];
    [withdrawButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x6AA7FF]] forState:UIControlStateHighlighted];
    [withdrawButton addTarget:self action:@selector(withdrawClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:withdrawButton];
    // 充值
    UIButton *rechargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rechargeButton.bounds = CGRectMake(0, 0, 114, 44);
    rechargeButton.top = moneyLabel.bottom + 20;
    rechargeButton.left = bg.middleX + 26;
    rechargeButton.layer.cornerRadius = 22;
    rechargeButton.layer.masksToBounds = YES;
    rechargeButton.layer.borderColor = UIColor.whiteColor.CGColor;
    rechargeButton.layer.borderWidth = 1.f;
    rechargeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rechargeButton setTitle:@"充值" forState:UIControlStateNormal];
    [rechargeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [rechargeButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] forState:UIControlStateNormal];
    [rechargeButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x6AA7FF]] forState:UIControlStateHighlighted];
    [rechargeButton addTarget:self action:@selector(rechargeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:rechargeButton];
    
    [self setupNavgationbar];
    
    UIView *bg2 = [UIView.alloc initWithFrame:CGRectMake(0, bg.bottom, self.view.width, 30)];
    bg2.backgroundColor = [UIColor colorWithHex:0x4C94FF];
    [self.view addSubview:bg2];
    
    TCommonCell *accountCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    accountCell.hasIndiractor = YES;
    accountCell.imageView.image = [UIImage imageNamed:@"wallet_account"];
    accountCell.textLabel.text = @"账户信息";
    self.accountCell = accountCell;
    
    TCommonCell *wCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    wCell.hasIndiractor = YES;
    wCell.imageView.image = [UIImage imageNamed:@"wallet_wallet"];
    wCell.textLabel.text = @"钱包明细";
    self.wCell = wCell;
    
    TCommonCell *redCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    redCell.hasIndiractor = YES;
    redCell.imageView.image = [UIImage imageNamed:@"wallet_red"];
    redCell.textLabel.text = @"红包记录";
    self.redCell = redCell;
    
    TCommonCell *bankCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    bankCell.hasIndiractor = YES;
    bankCell.imageView.image = [UIImage imageNamed:@"wallet_bank"];
    bankCell.textLabel.text = @"银行卡";
    self.bankCell = bankCell;
    
    TCommonCell *secCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    secCell.hasIndiractor = YES;
    secCell.imageView.image = [UIImage imageNamed:@"wallet_sec"];
    secCell.textLabel.text = @"安全设置";
    self.secCell = secCell;
    
    TCommonCell *helpCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    helpCell.hasIndiractor = YES;
    helpCell.imageView.image = [UIImage imageNamed:@"wallet_help"];
    helpCell.textLabel.text = @"帮助中心";
    self.helpCell = helpCell;
    
    self.cells = @[accountCell, wCell, redCell, bankCell, secCell];
    
    // uitableview
    UITableView *tableview = [UITableView.alloc initWithFrame:CGRectMake(0, bg.bottom-10, self.view.width, self.view.height - bg.bottom + 10) style:UITableViewStylePlain];
    tableview.layer.mask = ({
        UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:tableview.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20.f, 20.f)];
        CAShapeLayer* shape = [[CAShapeLayer alloc] init];
        [shape setPath:rounded.CGPath];
        
        shape;
    });
    tableview.rowHeight = 60;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    tableview.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    [self.view addSubview:tableview];
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletInformation:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.walletid = responseObject[@"walletid"];
        self.blance = [responseObject[@"cny"] integerValue]/100.f;
        [self setMoney:[NSString stringWithFormat:@"%.2f",self.blance]];
    }];
}

#pragma mark - Actions

- (void)didClickedEye:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        // 不显示金额
        self.moneyLabel.text = @"*****";
    } else {
        // 显示金额
        [self setMoney:[NSString stringWithFormat:@"%.2f",self.blance]];
    }
}

- (void)setMoney:(NSString *)num
{
    NSDictionary *attr1 = @{NSForegroundColorAttributeName:UIColor.whiteColor, NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]};
    NSDictionary *attr2 = @{NSForegroundColorAttributeName:UIColor.whiteColor, NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:34]};//DINAlternate-Bold //DINCondensed-Bold
    self.moneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"¥ " attributes:attr1]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:num attributes:attr2]];
        
        aString;
    });
}

- (void)withdrawClicked:(id)sender
{
    NWWithdrawVC *vc = [NWWithdrawVC.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rechargeClicked:(id)sender
{
    NWRechargeVC *vc = [NWRechargeVC.alloc init];
    vc.uid = self.uid;
    vc.walletid = self.walletid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView.alloc init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell == self.wCell) { // 钱包明细
        [self.navigationController pushViewController:[NWWaterListContainer.alloc init] animated:YES];
    } else if (selectedCell == self.redCell) { // 红包记录
        [self.navigationController pushViewController:[WalletRedPackageRecordVC.alloc init] animated:YES];
    } else if (selectedCell == self.bankCell) { // 银行卡
        /// 我的银行卡
        NWBankListVC *vc = [NWBankListVC.alloc init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (selectedCell == self.secCell){ // 安全设置
        NWSecuritySettingsVC *vc = [NWSecuritySettingsVC.alloc init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (selectedCell == self.accountCell) { // 账户信息
        [self.navigationController pushViewController:[NWAccountVC.alloc init] animated:YES];
    } else { // 帮助中心
        
    }
}

@end
