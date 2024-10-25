//
//  NWSettingPayPasswordVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/2.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWSettingPayPasswordVC.h"
#import "LYSecurityField.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"

#import "ImportSDK.h"

@interface NWSettingPayPasswordVC ()<LYPaymentFieldDelegate>
@property (weak,    nonatomic) UILabel *titleLabel;
@property (copy,    nonatomic) NSString *firstPassword;
@property (weak,    nonatomic) UIButton *doneButton;
@property (weak,    nonatomic) LYSecurityField *pwdField;

@property (strong,  nonatomic) NSArray *titles;

@end

@implementation NWSettingPayPasswordVC

- (instancetype)initWithTitle:(NSString *)title code:(NWPayPasswordCode)code
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = title;
        _code = code;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     * 配置第一次输入密码和确认密码时的文案
     **/
    if (self.code == NWPayPasswordCodeCreate) { // 创建密码
        self.titles = @[@"请设置支付密码，用于支付验证",@"请再次输入支付密码确认"];
    } else if (self.code == NWPayPasswordCodeModify) { // 修改密码
        self.titles = @[@"请设置新的支付密码，用于支付验证",@"请再次输入新的支付密码确认"];
    } else if (self.code == NWPayPasswordCodeForget) { // 忘记密码
        self.titles = @[@"请设置新的支付密码，用于支付验证",@"请再次输入新的支付密码确认"];
    } else { // 验证身份
        self.titles = @[@"请输入支付密码，以验证身份"];
    }
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(10, Height_NavBar + 102, self.view.width - 20, 25)];
    titleLabel.text = self.titles.firstObject;
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    
    CBWeakSelf
    LYSecurityField *passwordField = [[LYSecurityField alloc] initWithNumberOfCharacters:6 securityCharacterType:SecurityCharacterTypeSecurityDot borderType:BorderTypeHaveRoundedCorner];
    passwordField.tintColor = [UIColor colorWithHex:0xC6C6C6];
    passwordField.frame = CGRectMake(15, titleLabel.bottom + 30, 284, 48);
    passwordField.centerX = self.view.middleX;
    passwordField.widthOfBox = 48;
    passwordField.delegate = self;
    passwordField.completion = ^(LYSecurityField * _Nonnull field, NSString * _Nonnull text) {
        // 输入满格时被触发
        CBStrongSelfElseReturn
    };
    [self.view addSubview:passwordField];
    self.pwdField = passwordField;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.viewSize = CGSizeMake(200, 40);
    doneButton.centerX = self.view.centerX;
    doneButton.top = passwordField.bottom + 30;
    doneButton.hidden = YES;
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [doneButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:doneButton.viewSize] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x3181F5]] imageWithCornerRadius:4 size:doneButton.viewSize] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    self.doneButton = doneButton;
}

#pragma mark - actions

- (void)doneButtonClicked:(id)sender
{
    if (self.code == NWPayPasswordCodeCreate) {
        /// 通过调用SDK API 实现设置新密码
        [MBProgressHUD showLoading:@"" toView:self.view];
        [TIOChat.shareSDK.walletManager createPaymentPassword:self.firstPassword completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                if (self.handler) {
                    self.handler(self, YES, self.firstPassword);
                }
            }
        }];
        
    } else if (self.code == NWPayPasswordCodeModify) {
        /// SDK API
        [MBProgressHUD showLoading:@"" toView:self.view];
        [TIOChat.shareSDK.walletManager updatePaymentPassword:self.oldPassword toNewPassword:self.firstPassword completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [MBProgressHUD showSuccess:@"新密码设置成功" toView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.handler(self, YES, self.firstPassword);
                });
            }
        }];
    } else if (self.code == NWPayPasswordCodeForget) {
        [MBProgressHUD showLoading:@"" toView:self.view];
        [TIOChat.shareSDK.walletManager findPaymentPasswordWithSMSCode:self.SMSCode newPassword:self.firstPassword completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [MBProgressHUD showSuccess:@"新密码设置成功" toView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.handler(self, YES, self.firstPassword);
                });
            }
        }];
    } else {
        // 身份验证
        
    }
}

#pragma mark - LYPaymentFieldDelegate

- (void)lYPaymentFieldDidBeginEditing:(LYSecurityField *)paymentField
{
}

- (void)lYPaymentFieldDidFinishedEditing:(LYSecurityField *)paymentField
{
    if (self.firstPassword.length < 6) {
        
        if (self.code == NWPayPasswordCodeAuthorization) {
            /// 身份验证
            /// SDK 校验
            [MBProgressHUD showLoading:@"" toView:self.view];
            [TIOChat.shareSDK.walletManager checkPaymentPassword:paymentField.text completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (error) {
                    [self reInputPassword:error.localizedDescription];
                } else {
                    self.handler(self, YES, paymentField.text);
                }
            }];
        } else {
            /// 需要二次输入确认
            /// 第一次密码输入完成
            self.firstPassword = paymentField.text;
            self.titleLabel.text = self.titles.lastObject;
            [paymentField clear];
        }
        
    } else {
        /// 第二次密码输入完成
        if (![self.firstPassword isEqualToString:paymentField.text]) {
            self.titleLabel.text = self.titles.firstObject;
            [paymentField clear];
            self.firstPassword = nil;
            [MBProgressHUD showInfo:@"两次密码输入不一致，请重新设置" toView:self.view];
        } else {
            /// 二次密码输入正确
            self.doneButton.hidden = NO;
        }
    }
}

- (void)lYPaymentFieldDidDelete:(LYSecurityField *)paymentField
{
    NSLog(@"已经删除一个字符");
}

- (void)lYPaymentFieldDidClear:(LYSecurityField *)paymentField
{
    NSLog(@"清除完毕");
}

- (void)reInputPassword:(NSString *)msg
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:msg preferredStyle:TAlertControllerStyleAlert];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        [self.pwdField clear];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
