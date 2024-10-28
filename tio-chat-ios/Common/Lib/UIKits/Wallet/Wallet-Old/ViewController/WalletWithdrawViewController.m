//
//  WalletWithdrawViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWithdrawViewController.h"
#import "WalletInputField.h"
#import "WalletWithdrawRecordVC.h"
#import "WalletWithdrawResultViewController.h"

#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "UIImage+TColor.h"
#import "EHKWeboxManager.h"
#import "utils.h"
#import "MBProgressHUD+NJ.h"

@interface WalletWithdrawViewController () <UITextFieldDelegate>
@property (strong,  nonatomic) UILabel *showLabel;
@property (strong,  nonatomic) UITextField *textField;
@property (strong,  nonatomic) TIOWallet *wallet;
@property (copy,    nonatomic) NSString *serialnumber;

@end

@implementation WalletWithdrawViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"提现";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self requestData];
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletDetailWithUid:self.uid walletid:self.walletid completion:^(TIOWallet * _Nullable wallet, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.wallet = wallet;
        self.showLabel.text = [NSString stringWithFormat:@"当前余额%.2f元",wallet.balance.integerValue/100.f];
    }];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *barbutton = [UIBarButtonItem.alloc initWithCustomView:({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"提现记录" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(toWithdrawRecordVC) forControlEvents:UIControlEventTouchUpInside];
            
            button;
        })];
        
        barbutton;
    });
    
    UIView *bg = [UIView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 12, CGRectGetWidth(self.view.frame), 162)];
    bg.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bg];
    
    UILabel *titleLabel = [UILabel.alloc init];
    titleLabel.text = @"提现金额";
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
    textfield.placeholder = @"提现金额";
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
    [textfield addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
    __weak __typeof__(self) WeakSelf = self;
    textfield.w_deleteBlock = ^(NSString * _Nonnull text) {
        __strong __typeof__(self) self = WeakSelf; if(!self) return;
        NSLog(@"delete: %@",text);
        [self checkMoneyInput:text];
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
    
    UIButton *wholeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wholeButton.frame = CGRectMake(bg.width - 86, bg.height - 40, 86, 40);
    wholeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [wholeButton setTitle:@"全部提现" forState:UIControlStateNormal];
    [wholeButton setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
    [wholeButton addTarget:self action:@selector(wholeMoneyClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:wholeButton];
    
    UIButton *withdrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    withdrawButton.viewSize = CGSizeMake(200, 40);
    withdrawButton.centerX = self.view.middleX;
    withdrawButton.top = bg.bottom + 30;
    [withdrawButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:withdrawButton.viewSize] forState:UIControlStateNormal];
    [withdrawButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x8EBAFC]] imageWithCornerRadius:4 size:withdrawButton.viewSize] forState:UIControlStateHighlighted];
    [withdrawButton setTitle:@"提现" forState:UIControlStateNormal];
    [withdrawButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [withdrawButton addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:withdrawButton];
}

- (void)toWithdrawRecordVC
{
    [self.navigationController pushViewController:[WalletWithdrawRecordVC.alloc init] animated:YES];
}

- (void)clearInputMoneyClicked:(id)sender
{
    self.textField.text = @"";
}

- (void)wholeMoneyClicked:(id)sender
{
    if (self.wallet) {
        self.textField.text = @"";
        [self.textField insertText:[NSString stringWithFormat:@"%.2f",self.wallet.balance.integerValue/100.f]];
    } else {
        
    }
}

- (void)confirmClicked:(id)sender
{
    if (self.textField.text.length == 0) {
        return;
    }
    
    // 转成分 0.01元 => 100分
    NSString *amount = [NSString stringWithFormat:@"%.0f",self.textField.text.floatValue * 100];
    
    // 开始预下单
    CBWeakSelf
    [TIOChat.shareSDK.walletManager withdrawMoney:amount walletid:self.walletid uid:self.uid remark:@"" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (!error) {
            NSString *token = responseObject[@"token"];
            NSString *walletid = responseObject[@"walletId"];
            self.serialnumber = responseObject[@"serialnumber"];
            [self evoke_recharge:token walletid:walletid];
        } else {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
}

- (void)evoke_recharge:(NSString *)token walletid:(NSString *)walletid
{
    EHKWeboxManager * wallet = [EHKWeboxManager instanceManager];
    [utils configuration:wallet walletid:walletid token:token businessCode:EHKWEBOX_BUSINESSCODE_WITHDRAW vc:self];
    
    // 调起输入密码的弹窗
    CBWeakSelf
    [wallet evoke:^(EHKWeboxManager * _Nonnull wallet, EHKWeboxStatus status) {
        CBStrongSelfElseReturn
        self.navigationController.navigationBar.hidden = YES;
        self.navigationBar.backgroundColor = [UIColor clearColor];
        if (status == EHKWEBOX_STASTUS_PROCESS) {
            [MBProgressHUD showLoading:@"处理中" toView:self.view];
            /// 刷新数据
            [self requestData];
            CBWeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CBStrongSelfElseReturn
                [self check];
            });
        } else if (status == EHKWEBOX_STASTUS_FAILURE) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"提现失败：%@",wallet.errorMessage] toView:self.view];
        } else if (status == EHKWEBOX_STASTUS_SUCCESS) {
            [MBProgressHUD showSuccess:@"提现成功" toView:self.view];
            // 刷新数据
            [self requestData];
        } else if (status == EHKWEBOX_STASTUS_CANCEL) {
            [MBProgressHUD showError:@"操作取消" toView:self.view];
        }
    }];
}

- (void)textfieldEditing:(UITextField *)textfield
{
//    NSLog(@"money = %@",textfield.text);
//    
//    if (textfield.text.floatValue == 0) {
//        self.showLabel.text = @"当前金额0.00元";
//        return;
//    }
//    
//    if ([self isDecimalNum:textfield.text]) {
//        self.showLabel.text = [NSString stringWithFormat:@"当前金额%@元",textfield.text];
//    } else {
//        self.showLabel.text = @"当前金额0.00元";
//    }
}

- (BOOL)isDecimalNum:(NSString *)text
{
    int i = 0;
    BOOL flag = NO;
    while (i < text.length)
    {
        NSString * stringSet = [text substringWithRange:NSMakeRange(i, 1)];
        
        if ([stringSet isEqualToString:@"."]) {
            flag = YES;
        }
        
        i++;
    }
    
    return flag;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)checkMoneyInput:(NSString *)text
{
//    CGFloat floatNumber = text.floatValue;
//    self.textField.text = [NSString stringWithFormat:@"%.2f",floatNumber];
}

- (void)check
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager checkWithdrawResultWithSerialNumber:self.serialnumber completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            if ([responseObject[@"status"] isEqualToString:@"SUCCESS"]) {
                [MBProgressHUD showSuccess:@"提现成功" toView:self.view];
            }
            else if ([responseObject[@"status"] isEqualToString:@"PROCESS"]) {
                NSInteger amount = [responseObject[@"amount"] integerValue];
                NSInteger arrivalAmount = [responseObject[@"arrivalAmount"] integerValue];
                WalletWithdrawResultViewController *vc = [WalletWithdrawResultViewController.alloc init];
                vc.amount = [NSString stringWithFormat:@"%.2f元",amount/100.f];
                vc.bankName = responseObject[@"bankname"];
                vc.bankIconUrl = responseObject[@"bankicon"];
                vc.serverMoney = [NSString stringWithFormat:@"%.2f元",(amount-arrivalAmount)/100.f];
                [self.navigationController pushViewController:vc animated:YES];
            } 
        }
    }];
}

@end
