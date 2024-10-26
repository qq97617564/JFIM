//
//  TSMSLoginTwoViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/25.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSMSLoginTwoViewController.h"
#import "FrameAccessor.h"
#import "CaptchaView.h"
#import "UIButton+Enlarge.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"
#import "CBMobileValidator.h"
#import "ImportSDK.h"

@interface TSMSLoginTwoViewController () <UITextFieldDelegate>
/// 输入验证码
@property (weak,    nonatomic) UILabel *label;
/// 验证码输入
@property (weak,    nonatomic) UITextField *textfield;
/// 登录
@property (weak,    nonatomic) UIButton *confirmButton;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;
@end

@implementation TSMSLoginTwoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self startCountdownTimerIfNecessary];
}

- (void)setupUI
{   
    UIView *statuBar = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statuBar.backgroundColor = [UIColor colorWithHex:0xDBEAFF];
    [self.view addSubview:statuBar];
    
    UIImageView *bg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, statuBar.bottom, self.view.width, FlexWidth(144))];
    bg1.image = [UIImage imageNamed:@"login_bg"];
    [self.view addSubview:bg1];
    
    UIImageView *logo = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 50, 50)];
    logo.image = [UIImage imageNamed:@"Group 1321315510"];
    logo.centerX = self.view.middleX;
    logo.top = Height_StatusBar + 45;
    [self.view addSubview:logo];
    
    UILabel *label1 = ({
        UILabel *label = [UILabel.alloc init];
        label.text = @"验证码登录";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHex:0x333333];
        [label sizeToFit];
        label.left = 59;
        label.top = bg1.bottom + 54;
        label;
    });
    [self.view addSubview:label1];
    self.label = label1;
    
    UITextField *codeTF = ({
        UITextField *textfiled = [self textFiled:@"请输入短信验证码" left:40 right:104];
        textfiled.top = label1.bottom + 20;
        textfiled.delegate = self;
        textfiled.leftView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_code"]];
            [left sizeToFit];
            left.centerY = view.middleY;
            left.right = view.width - 2;
            [view addSubview:left];
            view;
        });
        [textfiled.rightView addSubview:({
            // 获取验证码按钮
            UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            smsButton.frame = textfiled.rightView.bounds;
            smsButton.enabled = NO;
            [smsButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [smsButton setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
            [smsButton setTitleColor:[UIColor colorWithHex:0xBBBBBB] forState:UIControlStateDisabled];
            smsButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [smsButton addTarget:self action:@selector(SMSButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.smsButton = smsButton;
            
            smsButton;
        })];
        
        textfiled;
    });
    [self.view addSubview:codeTF];
    self.textfield = codeTF;
    
    UIButton *loginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, codeTF.bottom+50, self.view.width-38*2, 50);
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
        [button setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateHighlighted];
        [button setTitle:@"登录" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:loginButton];
    self.confirmButton = loginButton;
    
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront:self.navigationBar];
}

- (UITextField *)textFiled:(NSString *)placeholder left:(CGFloat)left right:(CGFloat)right
{
    UITextField *textfiled = [UITextField.alloc initWithFrame:CGRectMake(38, 0, self.view.width-38*2, 44)];
    textfiled.backgroundColor = UIColor.whiteColor;
    textfiled.placeholder = placeholder;
    if (left > 0) {
        textfiled.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, left, textfiled.height)];
        textfiled.leftViewMode = UITextFieldViewModeAlways;
    }
    if (right > 0) {
        textfiled.rightView = [UIView.alloc initWithFrame:CGRectMake(0, 0, right, textfiled.height)];
        textfiled.rightViewMode = UITextFieldViewModeAlways;
    } else {
        textfiled.rightViewMode = UITextFieldViewModeWhileEditing;
        textfiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    textfiled.textColor = [UIColor colorWithHex:0x333333];
    textfiled.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    
    textfiled.layer.cornerRadius = 6;
    textfiled.layer.borderWidth = 1;
    textfiled.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
    
    return textfiled;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 禁止输入空格
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];

    if (![string isEqualToString:tem]) {
        return NO;
    }

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderWidth = 0.f;
    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.layer.borderWidth = 1.f;
    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
    return YES;
}

#pragma mark - actions

/// 点击登录
- (void)loginClicked
{
    [MBProgressHUD showMessage:@"登录中" toView:self.view];
    CBWeakSelf
    [TIOChat.shareSDK.loginManager login:self.phone password:nil authcode:self.textfield.text completion:^(TIOLoginUser * _Nullable userData, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            if (self.params) {
                if ([self.params.allKeys containsObject:@"callback"]) {
                    ModuleCallback callback = self.params[@"callback"];
                    callback(self, nil);
                    TLogRetainCount(@"登录成功的回调 callback", callback);
                }
            }
        }
    }];
}

/// 点击获取获取验证码
- (void)getcodeClicked
{
    // 键盘下去
    [self.textfield resignFirstResponder];
    
    // 校验是否是手机号
    NSError *error = nil;
    [CBMobileValidator validateText:self.textfield.text error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    // SDK API 获取验证码
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkMobile:self.textfield.text type:3 handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            CBWeakSelf
            [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
                CBStrongSelfElseReturn
                NSLog(@"result = %@",result);
                CBWeakSelf
                [TIOChat.shareSDK.loginManager fetchSMSWithType:3 mobile:self.textfield.text token:result handler:^(NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    if (error) {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    } else {
                        [self startCountdownTimerIfNecessary];
                    }
                }];
            }];
        }
    }];
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    // 重新获取验证码
    [self getcodeClicked];
}

- (void)startCountdownTimerIfNecessary
{
    if (self.countdownTimer) {
        return;
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimerDidFire:) userInfo:nil repeats:YES];
    self.smsButton.enabled = NO;
    self.smsButton.tag = 60;
    [self.smsButton setTitle:@"获取验证码" forState:UIControlStateDisabled];
    self.countdownTimer = timer;
}

- (void)countdownTimerDidFire:(NSTimer *)sender
{
    NSInteger seconds = self.smsButton.tag - 1;
    [self.smsButton setTitle:[NSString stringWithFormat:@"已发送(%@s)",@(seconds)] forState:UIControlStateDisabled];
    self.smsButton.tag = seconds;
    if (self.smsButton.tag == 0) {
        self.smsButton.enabled = YES;
        [self cancelCountdownTimer];
    }
}

- (void)cancelCountdownTimer
{
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    self.smsButton.enabled = YES;
}

@end
