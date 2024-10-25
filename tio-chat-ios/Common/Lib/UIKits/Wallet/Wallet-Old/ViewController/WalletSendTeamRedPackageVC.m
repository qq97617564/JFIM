//
//  WalletSendTeamRedPackageVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletSendTeamRedPackageVC.h"
#import "WalletRedPackageRecordVC.h"
#import "WalletInputField.h"

#import "FrameAccessor.h"
#import "UIButton+Enlarge.h"
#import "UIControl+T_LimitClickCount.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"

#import "EHKWeboxManager.h"
#import "utils.h"

@interface WalletSendTeamRedPackageVC () <UITableViewDelegate, UITextFieldDelegate>
@property (strong,  nonatomic) NSArray<UIButton *> *tabButtons;
@property (strong,  nonatomic) UIView *tabIndiractor;

/// 0:拼人品红包 1:普通红包
@property (assign,  nonatomic) NSInteger redType;

/// "拼人品红包" "普通红包"
@property (weak,    nonatomic) UILabel *moenyInputLabel;
@property (strong,  nonatomic) UILabel *moneyLabel;

@property (strong,  nonatomic) UITextField *textField;
@property (strong,  nonatomic) UITextField *remarkField;
@property (strong,  nonatomic) UITextField *countField;
@property (strong,  nonatomic) UIButton *sendButton;
@property (assign,  nonatomic) NSInteger requestMoney;

@end

#define MAX_SEND_COUNT 100 // 红包最大发送数量

@implementation WalletSendTeamRedPackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    UIView *topBg = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_NavBar)];
    topBg.backgroundColor = [UIColor colorWithHex:0xFF5E5E];
    [self.view addSubview:topBg];
 
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront:self.navigationBar];
     
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
        [button setTitle:@"发红包" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-40];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"查看记录" style:UIBarButtonItemStylePlain target:self action:@selector(toRedRecordVC:)];
    
    UIImageView *topBg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, FlexWidth(104))];
    topBg1.image = [UIImage imageNamed:@"bg_red"];
    [self.view addSubview:topBg1];
    
    // tab
    UIView *tabView = [UIView.alloc initWithFrame:CGRectMake((self.view.width - 232)*0.5, Height_NavBar, 232, 32)];
    tabView.backgroundColor = [UIColor colorWithHex:0xFC5050];
    tabView.layer.cornerRadius = 16;
    tabView.layer.masksToBounds = YES;
    [self.view addSubview:tabView];
    
    UIButton *pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pinButton.frame = CGRectMake(0, 0, tabView.width * 0.45, tabView.height-2);
    pinButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [pinButton setTitleColor:[UIColor colorWithHex:0xFFBEBE] forState:UIControlStateNormal];
    [pinButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [pinButton setTitle:@"拼人品红包" forState:UIControlStateNormal];
    [pinButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    pinButton.selected = YES;
    [tabView addSubview:pinButton];
    
    UIButton *normalButton = [UIButton buttonWithType: UIButtonTypeCustom];
    normalButton.frame = CGRectMake(tabView.width * 0.55, 0, tabView.width * 0.45, tabView.height-2);
    normalButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [normalButton setTitleColor:[UIColor colorWithHex:0xFFBEBE] forState:UIControlStateNormal];
    [normalButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [normalButton setTitle:@"普通红包" forState:UIControlStateNormal];
    [normalButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tabView addSubview:normalButton];
    
    self.tabButtons = @[pinButton, normalButton];
    
    self.tabIndiractor = [UIView.alloc initWithFrame:CGRectMake(0, 0, 52, 1)];
    self.tabIndiractor.backgroundColor = UIColor.whiteColor;
    self.tabIndiractor.bottom = tabView.height - 4;
    self.tabIndiractor.centerX = pinButton.centerX;
    [tabView addSubview:self.tabIndiractor];
    
    //
    UIView *CardView = [UIView.alloc initWithFrame:CGRectMake(16, Height_NavBar+50, self.view.width-32, 180)];
    CardView.backgroundColor = UIColor.whiteColor;
    CardView.layer.cornerRadius = 4;
    CardView.layer.masksToBounds = YES;
    [self.view addSubview:CardView];
    // 金额
    UILabel *firstLabel = [UILabel.alloc initWithFrame:CGRectMake(16, 0, 120, 60)];
    firstLabel.text = @"总金额";
    firstLabel.font = [UIFont systemFontOfSize:16];
    firstLabel.textColor = [UIColor colorWithHex:0x333333];
    [CardView addSubview:firstLabel];
    self.moenyInputLabel = firstLabel;
    WalletInputField *moneyTF = [WalletInputField.alloc initWithFrame:CGRectMake(firstLabel.right, 0, CardView.width-firstLabel.right - 40, 60)];
    moneyTF.textAlignment = NSTextAlignmentRight;
    moneyTF.keyboardType = UIKeyboardTypeDecimalPad;
    moneyTF.placeholder = @"输入总金额";
    moneyTF.w_deleteBlock = ^(NSString * _Nonnull text) {
        
    };
    [moneyTF addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
    [CardView addSubview:moneyTF];
    self.textField = moneyTF;
    
    UILabel *firstUnitLabel = [UILabel.alloc initWithFrame:CGRectMake(moneyTF.right, 0, 20, 60)];
    firstUnitLabel.text = @"元";
    firstUnitLabel.font = [UIFont systemFontOfSize:16];
    firstUnitLabel.textColor = [UIColor colorWithHex:0x333333];
    firstUnitLabel.textAlignment = NSTextAlignmentRight;
    [CardView addSubview:firstUnitLabel];
    // 个数
    {
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(16, 60, 120, 60)];
        label.text = @"红包个数";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHex:0x333333];
        [CardView addSubview:label];
        UITextField *textfield = [UITextField.alloc initWithFrame:CGRectMake(label.right, 60, CardView.width-label.right - 40, 60)];
        textfield.placeholder = [NSString stringWithFormat:@"本群共%zd人",self.team?self.team.memberNumber:2];
        textfield.textAlignment = NSTextAlignmentRight;
        textfield.keyboardType = UIKeyboardTypeNumberPad;
        textfield.delegate = self;
        [textfield addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
        [CardView addSubview:textfield];
        self.countField = textfield;
        UILabel *unitLabel = [UILabel.alloc initWithFrame:CGRectMake(textfield.right, 60, 20, 60)];
        unitLabel.text = @"个";
        unitLabel.font = [UIFont systemFontOfSize:16];
        unitLabel.textColor = [UIColor colorWithHex:0x333333];
        unitLabel.textAlignment = NSTextAlignmentRight;
        [CardView addSubview:unitLabel];
    }
    
    // 祝福语
    {
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(16, 120, 120, 60)];
        label.text = @"祝福语";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHex:0x333333];
        [CardView addSubview:label];
        UITextField *textfield = [UITextField.alloc initWithFrame:CGRectMake(label.right, 120, CardView.width-label.right - 20, 60)];
        textfield.placeholder = @"恭喜发财，吉祥如意";
        textfield.textAlignment = NSTextAlignmentRight;
        textfield.delegate = self;
        [CardView addSubview:textfield];
        self.remarkField = textfield;
    }
    
    // 单个红包金额不能超过
    UILabel *tipLabel = [UILabel.alloc initWithFrame:CGRectZero];
    tipLabel.textColor = [UIColor colorWithHex:0xF9AD55];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.text = @"单个红包金额为0.01~100元";
    [tipLabel sizeToFit];
    tipLabel.top = CardView.bottom + 5;
    tipLabel.centerX = CardView.centerX;
    [self.view addSubview:tipLabel];
    
    // 显示输入的大的总金额
    self.moneyLabel = [UILabel.alloc initWithFrame:CGRectMake(16, tipLabel.bottom + 18, self.view.width-32, 55)];
    [self.view addSubview:self.moneyLabel];
    [self setMoney:@"0.00"];
    
    // 发送button
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.viewSize = CGSizeMake(self.view.width - 176, 40);
    sendButton.top = CardView.bottom+116;
    sendButton.centerX = CardView.centerX;
    [sendButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0xF55252]] imageWithCornerRadius:4 size:sendButton.viewSize]
                          forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0xFF5E5E]] imageWithCornerRadius:4 size:sendButton.viewSize]
                          forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0xFF908F]] imageWithCornerRadius:4 size:sendButton.viewSize]
                          forState:UIControlStateDisabled];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [sendButton setTitle:@"塞钱进红包" forState:UIControlStateNormal];
    [sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.acceptEventInterval = 0.5;
    [self.view addSubview:sendButton];
    self.sendButton = sendButton;
    self.sendButton.enabled = NO;
    
    [self.tabButtons[0] sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)tabButtonClicked:(UIButton *)button
{
    NSInteger index = [self.tabButtons indexOfObject:button];
    self.redType = index;
    
    button.selected = YES;
    self.tabButtons[1-index].selected = NO;
    
    [UIView animateWithDuration:0.15 animations:^{
        self.tabIndiractor.centerX = button.centerX;
    }];
    
    /// 更新总金额
    [self textfieldEditing:self.textField];
    
    if (index == 0) {
        NSDictionary *attr1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:16]};
        
        self.moenyInputLabel.attributedText = ({
            NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
            
            NSTextAttachment *attch = [NSTextAttachment.alloc init];
            attch.image = [UIImage imageNamed:@"wallet_pin_send"];
            attch.bounds = CGRectMake(0, -2.5, 18, 18);
            [aString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attch]];
            [aString appendAttributedString:[NSAttributedString.alloc initWithString:@" 拼人品红包" attributes:attr1]];
            
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle.alloc init];
            style.alignment = NSTextAlignmentLeft;
            [aString addAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, aString.length)];
            
            aString;
        });
        self.textField.placeholder = @"输入总金额";
    } else {
        self.moenyInputLabel.text = @"红包金额";
        self.textField.placeholder = @"输入单笔红包金额";
    }
    
}

- (void)toRedRecordVC:(id)sender
{
    [self.navigationController pushViewController:[WalletRedPackageRecordVC.alloc init] animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - actions

- (void)confirmClicked:(id)sender
{
    if (self.textField.text.length == 0) {
        return;
    }
    
    if (self.countField.text.integerValue < 1) {
        return;
    }
    
    // 转成分 0.01元 => 100分
    NSInteger amount = self.textField.text.floatValue * 100;
    
    if (amount < self.countField.text.integerValue * 0.01 * 100 && self.redType == 0) {
        [MBProgressHUD showInfo:@"这点儿红包不够他们分的" toView:self.view];
        return;
    }
    
    /// 单笔金额
    NSInteger singleAmount = amount;
    
    if (self.redType == 1) {
        // 普通红包 总金额重新计算：单笔金额 * 红包个数
        amount = amount * self.countField.text.integerValue;
    }
    
    self.requestMoney = amount;
    
    NSString *remark = self.remarkField.text.length?self.remarkField.text:self.remarkField.placeholder;
    
    /// 预下单，获取token
    CBWeakSelf
    NSString *uid = [TIOChat.shareSDK.loginManager.userInfo userId];
    [TIOChat.shareSDK.walletManager sendRedPackageToSession:self.sessionId
                                                 packetType:self.redType==0?2:1
                                                     amount:amount
                                               singleAmount:singleAmount
                                                packetCount:self.countField.text.integerValue
                                                        uid:uid
                                                   walletid:nil
                                                     remark:remark
                                                 completion:^(TIORedPackage * _Nullable redPackage, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else {
            
            if (self.requestMoney != redPackage.amount) {
                /// 红包金额和实际扣款金额不一致！！！
                [MBProgressHUD showError:@"" toView:self.view];
            }
            else {
                [self evoke_send:redPackage.token walletid:redPackage.walletId];
            }
        }
        
    }];
}


#pragma mark - private

- (void)evoke_send:(NSString *)token walletid:(NSString *)walletid
{
    EHKWeboxManager * wallet = [EHKWeboxManager instanceManager];
    [utils configuration:wallet walletid:walletid token:token businessCode:EHKWEBOX_BUSINESSCODE_REDPACKAGE vc:self];
    
    // 调起输入密码的弹窗
    CBWeakSelf
    [wallet evoke:^(EHKWeboxManager * _Nonnull wallet, EHKWeboxStatus status) {
        CBStrongSelfElseReturn
//        self.navigationController.navigationBar.hidden = YES;
        self.navigationBar.hidden = NO;
        self.navigationBar.backgroundColor = [UIColor clearColor];
        if (status == EHKWEBOX_STASTUS_PROCESS) {
            /// 倒计时5秒等通知，如果没收到，直接进入“银行处理中”的结果页
            [MBProgressHUD showInfo:@"处理中" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else if (status == EHKWEBOX_STASTUS_FAILURE) {
            [MBProgressHUD showError:wallet.errorMessage toView:self.view];
        } else if (status == EHKWEBOX_STASTUS_SUCCESS) {
            [MBProgressHUD showSuccess:@"红包已发送" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else if (status == EHKWEBOX_STASTUS_CANCEL) {
        }
    }];
}

- (void)setMoney:(NSString *)num
{
    NSDictionary *attr1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:28 weight:UIFontWeightSemibold]};
    NSDictionary *attr2 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:42]};//DINAlternate-Bold //DINCondensed-Bold
    
    self.moneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"¥ " attributes:attr1]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:num attributes:attr2]];
        
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle.alloc init];
        style.alignment = NSTextAlignmentCenter;
        [aString addAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, aString.length)];
        
        aString;
    });
}

- (void)textfieldEditing:(UITextField *)textfield
{
    self.sendButton.enabled = self.textField.text.length>0 && self.countField.text.integerValue>=1;
    
//    if (textfield == self.countField) {
//        if (self.countField.text.integerValue > 100) {
//            [MBProgressHUD showInfo:@"最多发100个红包" toView:self.view];
//            return;
//        }
//    }
    
    if (self.textField.text.floatValue == 0) {
        [self setMoney:@"0.00"];
        return;
    }
    
    if (self.redType == 0) {
        /// 拼人品红包
        /// 判断是不是0.开头
        if ([self isDecimalNum:self.textField.text]) {
            [self setMoney:self.textField.text];
        } else {
            [self setMoney:[self.textField.text stringByAppendingString:@".00"]];
        }
    } else {
        /// 普通红包
        NSInteger redCount = self.countField.text.integerValue;
        if (redCount == 0) {
            [self setMoney:@"0.00"];
        } else {
            if (self.textField.text.floatValue > 0) {
                [self setMoney:[NSString stringWithFormat:@"%.2f",self.textField.text.floatValue * redCount]];
            }
        }
    }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByAppendingString:string];
    if (textField == self.remarkField) {
        return str.length < 15;
    }
    if (textField == self.countField) {
        if (str.integerValue > MAX_SEND_COUNT) {
            [MBProgressHUD showInfo:[NSString stringWithFormat:@"最多发%d个红包",MAX_SEND_COUNT] toView:self.view];
            return NO;
        } else {
            return YES;
        }
    }
    
    return YES;
}

@end
