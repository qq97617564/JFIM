//
//  TDMineViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TMineViewController.h"
#import "FrameAccessor.h"
#import "MineInfoViewController.h"
#import "TMineSettingViewController.h"
#import "TAccountViewController.h"
#import "UIImageView+Web.h"

#import "WalletKit.h"
#import "ImportSDK.h"
#import <UIImageView+WebCache.h>
#import "QRCodeViewController.h"
#import "ServerConfig.h"
#import "TCommonCell.h"

@interface TMineViewController () <TIOLoginDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *avatariew;
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UILabel *signLabel;

@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) TCommonCell *accountCell;
@property (strong,  nonatomic) TCommonCell *walletCell;
@property (strong,  nonatomic) TCommonCell *infoCell;
@property (strong,  nonatomic) TCommonCell *codeCell;
@property (strong,  nonatomic) TCommonCell *settingCell;
@property (strong,  nonatomic) NSArray<TCommonCell *> *cells;

@end

@implementation TMineViewController

- (void)dealloc
{
    [TIOChat.shareSDK.loginManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self refrshData];
    [TIOChat.shareSDK.loginManager addDelegate:self];
}

- (void)setupUI
{
    UIView *statusBar = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statusBar.backgroundColor = [UIColor colorWithHex:0x61A1FE];
    [self.view addSubview:statusBar];
    
    UIView *tableHeader = ({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, FlexWidth(230))];
        view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        // 超级背景 下滑时，仍然是 statusBar 的颜色
        UIView *supBg = [UIView.alloc initWithFrame:CGRectMake(0, -view.height, view.width, view.height)];
        supBg.backgroundColor = [UIColor colorWithHex:0x61A1FE];
        [view addSubview:supBg];
        
        UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, FlexWidth(230))];
        bg.image = [UIImage imageNamed:@"mine_bg"];
        bg.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:bg];
        
        self.avatariew = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 80, 80)];
        self.avatariew.centerX = view.middleX;
        self.avatariew.layer.cornerRadius = 4;
        self.avatariew.layer.masksToBounds = YES;
        self.avatariew.layer.borderColor = UIColor.whiteColor.CGColor;
        self.avatariew.layer.borderWidth = 4;
        self.avatariew.bottom = bg.bottom - 88;
        [view addSubview:self.avatariew];
        
        UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectMake(30, self.avatariew.bottom+9, self.view.width - 30*2, 28)];
        nickLabel.font = [UIFont boldSystemFontOfSize:20];
        nickLabel.textColor = [UIColor whiteColor];
        nickLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        UILabel *emailLabel = [UILabel.alloc initWithFrame:CGRectMake(30, nickLabel.bottom+4, nickLabel.width, 22)];
        emailLabel.font = [UIFont systemFontOfSize:16];
        emailLabel.textColor = [UIColor whiteColor];
        emailLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:emailLabel];
        self.emailLabel = emailLabel;
        
        // 二维码入口
        UIButton *qrCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        qrCodeBtn.viewSize = CGSizeMake(24, 24);
        [qrCodeBtn setImage:[UIImage imageNamed:@"mine_qr"] forState:UIControlStateNormal];
        qrCodeBtn.top = 10;
        qrCodeBtn.right = view.width - 16;
        [qrCodeBtn addTarget:self action:@selector(toQRCodeVC:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:qrCodeBtn];
        
        view;
    });
    
    self.accountCell = [self cellWithTitle:@"账号" icon:[UIImage imageNamed:@"mine_acc"]];
    self.walletCell = [self cellWithTitle:@"本地钱包" icon:[UIImage imageNamed:@"mine_wallet"]];
    self.infoCell = [self cellWithTitle:@"个人资料" icon:[UIImage imageNamed:@"mine_info"]];
    self.codeCell = [self cellWithTitle:@"邀请码" icon:[UIImage imageNamed:@"mine_info"]];
    self.settingCell = [self cellWithTitle:@"设置" icon:[UIImage imageNamed:@"mine_setting"]];
    self.cells = @[self.accountCell, self.walletCell, self.infoCell, self.settingCell];
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_StatusBar, self.view.width, self.view.height - Height_StatusBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.separatorInset = UIEdgeInsetsMake(0, 81, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE6E6E6];
    tableView.tableHeaderView = tableHeader;
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)refrshData
{
    [self.avatariew tio_imageUrl:[TIOChat.shareSDK.loginManager.userInfo avatar] placeHolderImageName:@"avatar_placeholder" radius:4];
    
    self.nickLabel.text = [TIOChat.shareSDK.loginManager userInfo].nick;
    
    self.emailLabel.text = [TIOChat.shareSDK.loginManager userInfo].phone;
}

#pragma mark - actions

- (void)editInfor
{
    [self.navigationController pushViewController:[MineInfoViewController.alloc init] animated:YES];
}

- (void)toWallet
{
    /// 如果没有开户，会直接进入开户流程页；
    /// 如果已经开户，会直接进入钱包主页。
    CBWeakSelf
    [WalletManager.shareInstance evokeOpenAccount:@{} callback:^(id  _Nonnull data) {
        CBStrongSelfElseReturn
    }];
}

- (void)toSetSetting
{
    TMineSettingViewController *vc = [TMineSettingViewController.alloc init];
    vc.user = TIOChat.shareSDK.loginManager.userInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toQRCodeVC:(id)sender
{
    QRCodeViewController *vc = [QRCodeViewController.alloc init];
    vc.leftBarButtonText = @"我的二维码";
    vc.isP2P = YES;
    vc.iconUrl = TIOChat.shareSDK.loginManager.userInfo.avatar;
    vc.name = TIOChat.shareSDK.loginManager.userInfo.nick;
    vc.qr_data = [QR_SERVER stringByAppendingFormat:@"&uid=%@",TIOChat.shareSDK.loginManager.userInfo.userId];
    [self.navigationController pushViewController:vc animated:YES];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _accountCell) {
        // 账户
        [self.navigationController pushViewController:[TAccountViewController.alloc init] animated:YES];
    } else if (cell == _walletCell) {
        // 钱包
        [self toWallet];
    } else if (cell == _infoCell) {
        // 个人资料
        [self editInfor];
    } else if (cell == _settingCell) {
        // 设置
        [self toSetSetting];
    }
}

#pragma mark -  工厂

- (TCommonCell *)cellWithTitle:(NSString *)title icon:(UIImage *)icon
{
    TCommonCell *cell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.contentView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    cell.hasIndiractor = YES;
    cell.textLabel.textColor = [UIColor colorWithHex:0x333333];
    cell.textLabel.text = title;
    cell.imageView.image = icon;
    
    return cell;
}

- (UIView *)viewWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle icon:(NSString *)icon hasIndiractor:(BOOL)hasIndiractor selector:(nullable SEL)selector subLabel:( UILabel * _Nullable *)subTitleLabel;
{
    UIView *view = [UIView.alloc initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    UIImageView *iconImage = [UIImageView.alloc initWithFrame:CGRectMake(16, 0, 24, 24)];
    iconImage.centerY = view.middleY;
    iconImage.image = [UIImage imageNamed:icon];
    [view addSubview:iconImage];
    
    
    UILabel *titleLabel = [UILabel.alloc init];
    titleLabel.text = title;
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel sizeToFit];
    titleLabel.left = iconImage.right+5;
    titleLabel.centerY = view.middleY;
    [view addSubview:titleLabel];
    
    UILabel *subLabel = [UILabel.alloc init];
    subLabel.text = subTitle;
    subLabel.textColor = [UIColor colorWithHex:0x909090];
    subLabel.font = [UIFont systemFontOfSize:14];
    [subLabel sizeToFit];
    subLabel.centerY = view.middleY;
    subLabel.right = view.width - 24;
    [view addSubview:subLabel];
    
    if (subTitleLabel) {
        *subTitleLabel = subLabel;
    }
    
    if (hasIndiractor) {
        UIImageView *indiractor = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"inner"]];
        [indiractor sizeToFit];
        indiractor.centerY = view.middleY;
        indiractor.right = view.width - 16;
        [view addSubview:indiractor];
        
        subLabel.right = indiractor.left;
    }
    
    if (selector) {
        UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:selector];
        [view addGestureRecognizer:tap];
    }
    
    return view;
}


#pragma mark - SDK-delegate TIOLoginDelegate

/// 一定要实现此代理
/// 当自己的用户信息发生变更后，此代理有效，刷新UI
/// @param user 最新的用户信息
- (void)didUpdateCurrentUserInfo:(TIOLoginUser *)user
{
    /// 更新内存数据
    [self refrshData];
}


// wxp://f2f0Qz9qxst1qazKE_53XToPLIzMELvT8Ccd
// https://qr.alipay.com/fkx13673gkz2fi4kwuvzjb9?t=1608010938119
@end
