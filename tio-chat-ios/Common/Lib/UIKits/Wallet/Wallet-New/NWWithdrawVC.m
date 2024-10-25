//
//  NWWithdrawVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWWithdrawVC.h"
#import "WalletInputField.h"
#import "WalletWithdrawRecordVC.h"
#import "WalletWithdrawResultViewController.h"

#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"

#import "NWPay.h"
#import "NWPaymentObject.h"

@interface NWWithdrawVC () <UITextFieldDelegate>
@property (strong,  nonatomic) UILabel *showLabel;
@property (strong,  nonatomic) UITextField *textField;
@property (copy,    nonatomic) NSString *serialnumber;
@property (assign,  nonatomic) NSInteger balance;

@property (weak,    nonatomic) UIButton *addNewBankBtn;
@property (strong,  nonatomic) id <NWPaymentChannel> payment;

@end

@implementation NWWithdrawVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"提现";
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
    [TIOChat.shareSDK.walletManager fetchWalletInformation:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.balance = [responseObject[@"cny"] integerValue];
        self.showLabel.text = [NSString stringWithFormat:@"当前余额%.2f元",self.balance/100.f];
    }];
    
    [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (responObject.count > 0) {
            NWPaymentObject *payment = [NWPaymentObject.alloc initWithModel:responObject.firstObject];
            [self.addNewBankBtn setTitle:[NSString stringWithFormat:@"%@（%@）",payment.name,payment.backFourCardNo] forState:UIControlStateNormal];
            [self.addNewBankBtn setImage:nil forState:UIControlStateNormal];
            self.payment = payment;
        }
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
    
    UIView *bankView = [UIView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 12, CGRectGetWidth(self.view.frame), 60)];
    bankView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bankView];

    {
        UILabel *titleLabel = [UILabel.alloc init];
        titleLabel.text = @"选择卡号";
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor colorWithHex:0x333333];
        [titleLabel sizeToFit];
        titleLabel.left = 16;
        titleLabel.centerY = bankView.middleY;
        [bankView addSubview:titleLabel];

        UIButton *addNewCard = [UIButton buttonWithType:UIButtonTypeCustom];
        addNewCard.frame = CGRectMake(95, 0, bankView.width - 120, bankView.height);
        [addNewCard setImage:[UIImage imageNamed:@"add_bank"] forState:UIControlStateNormal];
        [addNewCard setTitle:@"提现方式" forState:UIControlStateNormal];
        [addNewCard setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
        [addNewCard.titleLabel setFont:[UIFont systemFontOfSize:14]];
        addNewCard.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        addNewCard.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
        [addNewCard addTarget:self action:@selector(addNewCard:) forControlEvents:UIControlEventTouchUpInside];
        [bankView addSubview:addNewCard];
        self.addNewBankBtn = addNewCard;
    }
    
    UIView *bg = [UIView.alloc initWithFrame:CGRectMake(0, bankView.bottom + 12, CGRectGetWidth(self.view.frame), 162)];
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
    self.textField.text = @"";
    [self.textField insertText:[NSString stringWithFormat:@"%.2f",self.balance/100.f]];
}

- (void)confirmClicked:(id)sender
{
    if (self.textField.text.length == 0) {
        return;
    }
    
    if (!self.payment) {
        [MBProgressHUD showInfo:@"请先选择提现到的银行卡" toView:self.view];
        return;
    }
    
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletInformation:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        NSInteger cny = [responseObject[@"cny"] integerValue];
        
        
        if (self.textField.text.floatValue * 100 > cny) {
            [MBProgressHUD showError:@"提现超出余额" toView:self.view];
            return;
        }
        
        
        CBWeakSelf
        [TIOChat.shareSDK.walletManager fetchWithdrawConfigWithAmount:self.textField.text.floatValue * 100 completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            /*
             max = 200000;
             min = 30;
             rate = 10;
             withholdconst = 1;
             */
            
            if (self.textField.text.floatValue < ([result[@"min"] integerValue] / 100.f)) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"最低提现金额%.2f元",[result[@"min"] integerValue] / 100.f] toView:self.view];
                return;
            }
            
            if (self.textField.text.floatValue > ([result[@"max"] integerValue] / 100.f)) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"最高提现金额%.2f元",[result[@"max"] integerValue] / 100.f] toView:self.view];
                return;
            }
            
            // 开始预下单
            NWPay *pay  = [NWPay shareInstance];
            pay.code    = NWBusinessCodeWithDraw;
            pay.currentViewController = self;
            pay.amount  = self.textField.text.floatValue * 100;
            pay.agrno   = self.payment.agreementNo;
            pay.rate    = [result[@"rate"] integerValue];
            pay.withholdconst   = [result[@"withholdconst"] integerValue];
            pay.fee     = [result[@"commission"] integerValue];
            [pay evoke:^(NSDictionary * _Nullable result, NWBusinessCode businessCode, NSError * _Nullable error) {
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                } else {
                    BOOL re = [result[@"result"] boolValue];
                    if (re) {
                        /// 刷新数据
                        [self requestData];
                        [MBProgressHUD showLoading:@"处理中" toView:self.view];
                        [self queryResult:result count:5 wid:result[@"id"] reqid:result[@"reqid"]];
                    }
                }
            }];
        }];
    }];
}

- (void)addNewCard:(id)sender
{
    NWPay *pay = [NWPay shareInstance];
    pay.code = NWBusinessCodeSelectPayment;
    pay.currentViewController = self;
    [pay evoke:^(NSDictionary * _Nullable result, NWBusinessCode businessCode, NSError * _Nullable error) {
        id<NWPaymentChannel> payment = result[@"result"];
        [self.addNewBankBtn setTitle:[NSString stringWithFormat:@"%@（%@）",payment.name,payment.backFourCardNo] forState:UIControlStateNormal];
        [self.addNewBankBtn setImage:nil forState:UIControlStateNormal];
        self.payment = payment;
    }];
}

#pragma mark - 输入控制


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

#pragma mark - 轮询充值结果

/// 每次查询完  隔0.5秒再查询一次，直至成功或者达到最大限度
- (void)queryResult:(NSDictionary *)params count:(NSInteger)count wid:(NSString *)wid reqid:(NSString *)reqid
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager queryWithdrawStatusWithWid:wid reqid:reqid completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            NSInteger status = [result[@"status"] integerValue];
            if (status == 2 || status == -1) {
                // 依然处理中
                if (count == 0) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    // 达到最大查询次数 结束：跳转处理结果页
                    NSInteger amount = [result[@"amount"] integerValue];
                    NSInteger arrivalAmount = [result[@"arrivalamount"] integerValue];
                    WalletWithdrawResultViewController *vc = [WalletWithdrawResultViewController.alloc init];
                    vc.amount = [NSString stringWithFormat:@"%.2f元",amount/100.f];
                    vc.bankName = self.payment.name;
                    vc.bankIconUrl = self.payment.iconUrl;
                    vc.serverMoney = [NSString stringWithFormat:@"%.2f元",(amount-arrivalAmount)/100.f];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    // 隔0.5秒 再次查询一次
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self queryResult:result count:count-1 wid:wid reqid:reqid];
                    });
                }
            } else if (status == 1) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showSuccess:@"提现成功" toView:self.view];
            } else if (status == 3) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }
    }];
}

@end
