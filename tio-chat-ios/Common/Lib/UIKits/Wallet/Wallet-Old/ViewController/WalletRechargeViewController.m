//
//  WalletRechargeViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletRechargeViewController.h"
#import "WalletInputField.h"
#import "WalletRechargeResultViewController.h"

#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "ImportSDK.h"

#import "EHKWeboxManager.h"
#import "utils.h"
#import "MBProgressHUD+NJ.h"

@interface WalletRechargeViewController ()
@property (strong,  nonatomic) UILabel *showLabel;
@property (strong,  nonatomic) UITextField *textField;

/// 记录提交时的价格
@property (copy,    nonatomic) NSString *requestMoney;

@end

@implementation WalletRechargeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"充值";
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
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    UIView *bg = [UIView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 12, CGRectGetWidth(self.view.frame), 162)];
    bg.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bg];
    
    UILabel *titleLabel = [UILabel.alloc init];
    titleLabel.text = @"充值金额";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    [titleLabel sizeToFit];
    titleLabel.left = 16;
    titleLabel.top = 20;
    [bg addSubview:titleLabel];
    
    UILabel *symbolLabel = [UILabel.alloc init];
    symbolLabel.text = @"¥";
    symbolLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    symbolLabel.textColor = [UIColor colorWithHex:0x333333];
    [symbolLabel sizeToFit];
    symbolLabel.left = 16;
    symbolLabel.top = 74;
    [bg addSubview:symbolLabel];
    
    WalletInputField *textfield = [WalletInputField.alloc initWithFrame:CGRectMake(39, 60, self.view.width - 39 - 21, 44)];
    textfield.placeholder = @"充值金额";
    textfield.keyboardType = UIKeyboardTypeDecimalPad;
//    textfield.delegate = self;
    textfield.font = [UIFont fontWithName:@"DINAlternate-Bold" size:34];
    textfield.rightViewMode = UITextFieldViewModeWhileEditing;
    textfield.rightView = ({
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(0, 0, 44, 44);
        [clearButton setImage:[UIImage imageNamed:@"wallet_clear"] forState:UIControlStateNormal];
        clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [clearButton addTarget:self action:@selector(clearInputMoneyClicked:) forControlEvents:UIControlEventTouchUpInside];
        clearButton;
    });
    __weak __typeof__(self) WeakSelf = self;
    textfield.w_deleteBlock = ^(NSString * _Nonnull text) {
        __strong __typeof__(self) self = WeakSelf; if(!self) return;
        NSLog(@"delete: %@",text);
        
    };
    [bg addSubview:textfield];
    self.textField = textfield;
    
    UIView *line = [UIView.alloc initWithFrame:CGRectMake(15, 122, bg.width - 30, 1)];
    line.backgroundColor = [UIColor colorWithHex:0xE8E8E8];
    [bg addSubview:line];
    
    UILabel *showLabel = [UILabel.alloc initWithFrame:CGRectMake(20, 132, bg.width * 0.5, 20)];
    showLabel.font = [UIFont systemFontOfSize:14];
    showLabel.textColor = [UIColor colorWithHex:0x333333];
    showLabel.textAlignment = NSTextAlignmentLeft;
    [bg addSubview:showLabel];
    self.showLabel = showLabel;
    
    UIButton *rechargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rechargeButton.viewSize = CGSizeMake(200, 40);
    rechargeButton.centerX = self.view.middleX;
    rechargeButton.top = bg.bottom + 30;
    [rechargeButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:rechargeButton.viewSize] forState:UIControlStateNormal];
    [rechargeButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x8EBAFC]] imageWithCornerRadius:4 size:rechargeButton.viewSize] forState:UIControlStateHighlighted];
    [rechargeButton setTitle:@"充值" forState:UIControlStateNormal];
    [rechargeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [rechargeButton addTarget:self action:@selector(rechargeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rechargeButton];
}

- (void)clearInputMoneyClicked:(id)sender
{
    self.textField.text = @"";
}

- (void)rechargeClicked:(id)sender
{
    if (self.textField.text.length == 0) {
        return;
    }
    
    NSString *uid = [TIOChat.shareSDK.loginManager.userInfo userId];
    NSString *walletid = [TIOChat.shareSDK.loginManager.userInfo walletid];
    
    // 转成分 0.01元 => 100分
    self.requestMoney = self.textField.text;
    NSString *amount = [NSString stringWithFormat:@"%.0f",self.textField.text.floatValue * 100];
    
    // 开始预下单
    [TIOChat.shareSDK.walletManager rechargeMoney:amount walletid:walletid uid:uid remark:@"" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *token = responseObject[@"token"];
            NSString *walletid = responseObject[@"walletId"];
            [self evoke_recharge:token walletid:walletid];
        } else {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
}

- (void)evoke_recharge:(NSString *)token walletid:(NSString *)walletid
{
    EHKWeboxManager * wallet = [EHKWeboxManager instanceManager];
    [utils configuration:wallet walletid:walletid token:token businessCode:EHKWEBOX_BUSINESSCODE_RECHARGE vc:self];
    
    // 调起输入密码的弹窗
    CBWeakSelf
    [wallet evoke:^(EHKWeboxManager * _Nonnull wallet, EHKWeboxStatus status) {
        CBStrongSelfElseReturn
        self.navigationController.navigationBar.hidden = YES;
        self.navigationBar.backgroundColor = [UIColor clearColor];
        if (status == EHKWEBOX_STASTUS_PROCESS) {
            /// 倒计时5秒等通知，如果没收到，直接进入“银行处理中”的结果页
            WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
            vc.resultType = 3;
            vc.money = self.requestMoney;
            [self pushToVC:vc];
        } else if (status == EHKWEBOX_STASTUS_FAILURE) {
            WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
            vc.resultType = 2;
            vc.money = self.requestMoney;
            vc.errorMessage = wallet.errorMessage?:@"异常错误";
            [self pushToVC:vc];
        } else if (status == EHKWEBOX_STASTUS_SUCCESS) {
            WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
            vc.resultType = 1;
            vc.money = self.requestMoney;
            [self pushToVC:vc];
        } else if (status == EHKWEBOX_STASTUS_CANCEL) {
            [MBProgressHUD showError:@"返回状态：取消" toView:self.view];
        }
    }];
}

- (void)pushToVC:(UIViewController *)vc
{
    [self.navigationController pushViewController:vc animated:YES];
    
    NSArray *tempVCs = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(0, self.navigationController.viewControllers.count-2)];
    [self.navigationController setViewControllers:[tempVCs arrayByAddingObject:vc]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
