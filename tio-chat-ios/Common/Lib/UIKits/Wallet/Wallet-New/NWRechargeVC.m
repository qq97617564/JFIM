//
//  NWRechargeVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWRechargeVC.h"
#import "WalletInputField.h"
#import "WalletRechargeResultViewController.h"
#import "NWPay.h"

#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "ImportSDK.h"

#import "MBProgressHUD+NJ.h"

@interface NWRechargeVC ()
@property (strong,  nonatomic) UILabel *showLabel;
@property (strong,  nonatomic) UITextField *textField;

/// 记录提交时的价格
@property (copy,    nonatomic) NSString *requestMoney;

@property (weak,    nonatomic) UIButton *addNewBankBtn;

@end

@implementation NWRechargeVC

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
    
//    UIView *bankView = [UIView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 12, CGRectGetWidth(self.view.frame), 60)];
//    bankView.backgroundColor = UIColor.whiteColor;
//    [self.view addSubview:bankView];
//
//    {
//        UILabel *titleLabel = [UILabel.alloc init];
//        titleLabel.text = @"添加卡号";
//        titleLabel.font = [UIFont systemFontOfSize:14];
//        titleLabel.textColor = [UIColor colorWithHex:0x333333];
//        [titleLabel sizeToFit];
//        titleLabel.left = 16;
//        titleLabel.centerY = bankView.middleY;
//        [bankView addSubview:titleLabel];
//
//        UIButton *addNewCard = [UIButton buttonWithType:UIButtonTypeCustom];
//        addNewCard.frame = CGRectMake(95, 0, bankView.width - 120, bankView.height);
//        [addNewCard setImage:[UIImage imageNamed:@"add_bank"] forState:UIControlStateNormal];
//        [addNewCard setTitle:@"添加卡号" forState:UIControlStateNormal];
//        [addNewCard setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
//        [addNewCard.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        addNewCard.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        addNewCard.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
//        [addNewCard addTarget:self action:@selector(addNewCard:) forControlEvents:UIControlEventTouchUpInside];
//        [bankView addSubview:addNewCard];
//        self.addNewBankBtn = addNewCard;
//    }
    
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

- (void)addNewCard:(id)sender
{
    /// 吊起支付方式选择器
    NWPay *pay = NWPay.shareInstance;
    pay.code = NWBusinessCodeSelectPayment;
    [pay evoke:^(NSDictionary * _Nullable result, NWBusinessCode businessCode, NSError * _Nullable error) {
        if (!error) {
            id<NWPaymentChannel> payment = result[@"result"];
            [self.addNewBankBtn setImage:nil forState:UIControlStateNormal];
            [self.addNewBankBtn setTitle:[NSString stringWithFormat:@"%@（%@）",payment.name,payment.cardNo] forState:UIControlStateNormal];
            [self.addNewBankBtn setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        }
    }];
}

- (void)rechargeClicked:(id)sender
{
    if (self.textField.text.length == 0) {
        return;
    }
    
    
    // 转成分 0.01元 => 100分
    self.requestMoney = [NSString stringWithFormat:@"%.2f",self.textField.text.floatValue];
    NWPay *pay = [NWPay shareInstance];
    pay.code = NWBusinessCodeRecharge;
    pay.currentViewController = self;
    pay.amount = self.textField.text.floatValue * 100;
    [pay evoke:^(NSDictionary * _Nullable result, NWBusinessCode businessCode, NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            BOOL re = [result[@"result"] boolValue];
            if (re) {
                NSInteger status = [result[@"status"] integerValue];
                if (status == 1) {
                    // 成功
                    WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
                    vc.resultType = 1;
                    vc.money = self.requestMoney;
                    [self pushToVC:vc];
                } else if (status == 2) {
                    // 银行处理中
                    /// 倒计时5秒等通知，如果没收到，直接进入“银行处理中”的结果页
                    [MBProgressHUD showLoading:@"银行处理中" toView:self.view];
                    [self queryResult:result count:5];
                } else if (status == 3) {
                    // 失败
                    WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
                    vc.resultType = 2;
                    vc.money = self.requestMoney;
                    vc.errorMessage = result[@"ordererrormsg"];
                    [self pushToVC:vc];
                }
            }
        }
    }];
}

- (void)evoke_recharge:(NSString *)token walletid:(NSString *)walletid
{
    
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


#pragma mark - 轮询充值结果

/// 每次查询完  隔0.5秒再查询一次，直至成功或者达到最大限度
- (void)queryResult:(NSDictionary *)params count:(NSInteger)count
{
    [TIOChat.shareSDK.walletManager queryRechargeStatusWithRid:params[@"rid"] reqid:params[@"reqid"] completion:^(NSInteger status, NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            if (status == 2) {
                // 依然处理中
                if (count == 0) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    // 达到最大查询次数 结束：跳转处理结果页
                    WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
                    vc.resultType = 3;
                    vc.money = self.requestMoney;
                    [self pushToVC:vc];
                } else {
                    // 隔0.5秒 再次查询一次
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self queryResult:params count:count-1];
                    });
                }
            } else if (status == 1) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                // 成功 结束：跳转成功结果页
                WalletRechargeResultViewController *vc = [WalletRechargeResultViewController.alloc init];
                vc.resultType = 1;
                vc.money = self.requestMoney;
                [self pushToVC:vc];
            }
        }
    }];
}

@end
