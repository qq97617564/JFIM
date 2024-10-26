//
//  MineVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/22.
//  Copyright © 2024 刘宇. All rights reserved.
//

#import "MineVC.h"
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
#import "InvitationCodeVC.h"

@interface MineVC () <TIOLoginDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet UIImageView *headV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *accountL;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *infoTap;
@property (weak, nonatomic) IBOutlet UIView *listView;

@property (weak, nonatomic) IBOutlet UIImageView *flag;


//@property (nonatomic, strong) UIImageView *avatariew;
//@property (nonatomic, strong) UILabel *nickLabel;
//@property (nonatomic, strong) UILabel *emailLabel;
//@property (nonatomic, strong) UILabel *signLabel;

@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) TCommonCell *accountCell;
@property (strong,  nonatomic) TCommonCell *walletCell;
@property (strong,  nonatomic) TCommonCell *infoCell;
@property (strong,  nonatomic) TCommonCell *codeCell;
@property (strong,  nonatomic) TCommonCell *settingCell;
@property (strong,  nonatomic) NSArray<TCommonCell *> *cells;


@end

@implementation MineVC
- (IBAction)infoAction:(UITapGestureRecognizer *)sender {
    [self editInfor];
}
- (IBAction)qrAction:(UITapGestureRecognizer *)sender {
    [self toQRCodeVC: nil];
}
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
    self.infoView.layer.cornerRadius = 6;
    self.listView.layer.masksToBounds = true;
    self.listView.layer.cornerRadius = 6;
//    UIView *statusBar = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
//    statusBar.backgroundColor = [UIColor colorWithHex:0x61A1FE];
//    [self.view addSubview:statusBar];
    self.navigationBar.hidden = true;
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F9FB];
    
    self.accountCell = [self cellWithTitle:@"账号" icon:[UIImage imageNamed:@"Group 1321315501"]];
    self.walletCell = [self cellWithTitle:@"本地钱包" icon:[UIImage imageNamed:@"Group 1321315502"]];
    self.infoCell = [self cellWithTitle:@"个人资料" icon:[UIImage imageNamed:@"Group 1321315503"]];
    self.codeCell = [self cellWithTitle:@"邀请码" icon:[UIImage imageNamed:@"Group 1321315504"]];
    self.settingCell = [self cellWithTitle:@"设置" icon:[UIImage imageNamed:@"Group 1321315505"]];
    self.cells = @[self.accountCell, self.walletCell, self.infoCell,self.codeCell, self.settingCell];
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(-7, 7, ScreenWidth()-25, 53*5+15) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.scrollEnabled = false;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 53;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.listView addSubview:tableView];
    self.tableView = tableView;
}

- (void)refrshData
{
    [self.headV tio_imageUrl:[TIOChat.shareSDK.loginManager.userInfo avatar] placeHolderImageName:@"avatar_placeholder" radius:4];
    
    self.nameL.text = [TIOChat.shareSDK.loginManager userInfo].nick;
    
    self.accountL.text = [NSString stringWithFormat:@"用户名：%@",[TIOChat.shareSDK.loginManager userInfo].loginname];
    if ([TIOChat.shareSDK.loginManager userInfo].xx == 3 || [TIOChat.shareSDK.loginManager userInfo].officialflag == 1){
        self.flag.hidden = false;
    }
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
    } else if (cell == _codeCell) {
        // 邀请码
        [self invitationCode];
    } else if (cell == _settingCell) {
        // 设置
        [self toSetSetting];
    }
}
-(void)invitationCode{
    InvitationCodeVC *vc = [[InvitationCodeVC alloc]init];
    [self.navigationController pushViewController:vc animated:true];
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
