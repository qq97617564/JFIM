//
//  TRegisterViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/3.
//  Copyright © 2020 刘宇. All rights reserved.
//
#import "LoginVC.h"
#import "TRegisteViewController.h"
#import "TRegisterResultViewController.h"
#import "TLoginViewController.h"

#import "UIImage+TColor.h"
#import "DefineHeader.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "CBEmailValidator.h"
#import "CBMobileValidator.h"
#import "WKWebViewController.h"
#import "TAlertController.h"
#import "UIControl+T_LimitClickCount.h"
#import "UIButton+Enlarge.h"
#import "MBProgressHUD+NJ.h"
#import <M80AttributedLabel.h>
#import "CaptchaView.h"

@interface TRegisteViewController () <UITextFieldDelegate, M80AttributedLabelDelegate>
@property (weak, nonatomic) UITextField *accountTF;
@property (weak, nonatomic) UITextField *nickTF; // 设置昵称 绑定邮箱时：输入邮箱
@property (weak, nonatomic) UITextField *pwdTF; // 设置密码 绑定邮箱时：输入邮箱密码
@property (weak, nonatomic) UITextField *codeTF;
@property (weak, nonatomic) UILabel *errorLabel;
@property (weak, nonatomic) UIButton *regButton;

/// 绑定邮箱
@property (weak,    nonatomic) UIButton *bindEmailButton;
@property (assign,  nonatomic) BOOL isNeedBindEmail;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;

@end

@implementation TRegisteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI2];
}

- (void)setupUI2
{
    self.navigationBar.hidden = YES;
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView *statuBar = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statuBar.backgroundColor = [UIColor colorWithHex:0xDBEAFF];
    [self.view addSubview:statuBar];
    
    UIImageView *bg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, statuBar.bottom, self.view.width, FlexWidth(107))];
    bg1.image = [UIImage imageNamed:@"reg_bg"];
    [self.view addSubview:bg1];
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"密码登录" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button sizeToFit];
        button.top = Height_StatusBar + 11;
        button.right = self.view.width - 16;
        [button setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [button addTarget:self action:@selector(accountAndPasswordLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];

    [self.view addSubview:({
        UILabel *label = [UILabel.alloc init];
        label.text = @"欢迎注册";
        label.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
        label.textColor = [UIColor colorWithHex:0x333333];
        [label sizeToFit];
        label.left = 52;
        label.top = Height_StatusBar + 51;
        label;
    })];
    
    // 手机号
    UITextField *phoneTF = ({
        UITextField *textfiled = [self textFiled:@"请输入手机号" left:40 right:0];
        textfiled.top = Height_StatusBar + 119;
        textfiled.delegate = self;
        textfiled.keyboardType = UIKeyboardTypeNumberPad;
        textfiled.leftView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_phone"]];
            [left sizeToFit];
            left.centerY = view.middleY;
            left.right = view.width - 2;
            [view addSubview:left];
            view;
        });
        
        textfiled;
    });
    [self.view addSubview:phoneTF];
    self.accountTF = phoneTF;
    
    UITextField *codeTF = ({
        UITextField *textfiled = [self textFiled:@"请输入验证码" left:40 right:104];
        textfiled.top = Height_StatusBar + 179;
        textfiled.delegate = self;
        textfiled.keyboardType = UIKeyboardTypeNumberPad;
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
    self.codeTF = codeTF;
    
    UITextField *nickTF = ({
        UITextField *textfiled = [self textFiled:@"请输入您的昵称" left:40 right:0];
        textfiled.top = Height_StatusBar + 239;
        textfiled.delegate = self;
        textfiled.leftView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_name"]];
            [left sizeToFit];
            left.centerY = view.middleY;
            left.right = view.width - 2;
            [view addSubview:left];
            view;
        });
        
        textfiled;
    });
    [self.view addSubview:nickTF];
    self.nickTF = nickTF;
    
    UITextField *passwordTF = ({
        UITextField *textfiled = [self textFiled:@"请设置登录密码" left:40 right:56];
        textfiled.top = Height_StatusBar + 299;
        textfiled.delegate = self;
        textfiled.secureTextEntry = YES;
//        textfiled.leftView = ({
//            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
//            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_pwd"]];
//            [left sizeToFit];
//            left.centerY = view.middleY;
//            left.right = view.width - 2;
//            [view addSubview:left];
//            view;
//        });
//        [textfiled.rightView addSubview:({
//            UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            eyeButton.frame = textfiled.rightView.bounds;
//            [eyeButton setImage:[UIImage imageNamed:@"showPassword"] forState:UIControlStateNormal];
//            [eyeButton setImage:[UIImage imageNamed:@"hidePassword"] forState:UIControlStateSelected];
//            [eyeButton addTarget:self action:@selector(eyeDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//            eyeButton.selected = YES;
//            
//            eyeButton;
//        })];
        
        textfiled;
    });
    [self.view addSubview:passwordTF];
    self.pwdTF = passwordTF;
    
//    [self.view addSubview:({
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setFrame:CGRectMake(38, Height_StatusBar+357, 150, 25)];
//        [button setImage:[UIImage imageNamed:@"login_unselected"] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"login_selected"] forState:UIControlStateSelected];
//        [button setTitle:@"绑定已有邮箱账号" forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
//        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:2];
//        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [button setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
//        [button addTarget:self action:@selector(bindEmailClicked:) forControlEvents:UIControlEventTouchUpInside];
//        
//        button;
//    })];
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, Height_StatusBar+427, self.view.width-38*2, 50);
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
        [button setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateHighlighted];
        [button setTitle:@"注册" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        button.enabled = NO;
        self.regButton = button;
        
        button;
    })];
    
    // 同意协议
    UIButton *protocolButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 24, 24);
        [button setImage:[UIImage imageNamed:@"login_selected"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"login_unselected"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(agreementClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    [self.view addSubview:protocolButton];
    M80AttributedLabel *protocolLabel = [M80AttributedLabel.alloc init];
    [protocolLabel appendText:@"阅读并同意《用户服务协议》和《隐私政策》"];
    protocolLabel.font = [UIFont systemFontOfSize:14];
    protocolLabel.textColor = [UIColor colorWithHex:0x999999];
    protocolLabel.delegate = self;
    [protocolLabel addCustomLink:@(2) forRange:NSMakeRange(5, 8) linkColor:[UIColor colorWithHex:0x4C94FF]];
    [protocolLabel addCustomLink:@(3) forRange:NSMakeRange(14, 6) linkColor:[UIColor colorWithHex:0x4C94FF]];
    protocolLabel.underLineForLink = NO;
    protocolLabel.textAlignment = kCTTextAlignmentCenter;
    [protocolLabel sizeToFit];
    protocolLabel.top = Height_StatusBar + 391;
    [self.view addSubview:protocolLabel];
    
    protocolButton.left = 38;
    protocolButton.centerY = protocolLabel.centerY;
    protocolLabel.left = protocolButton.right + 2;
}


#pragma mark - Actions

- (void)eyeDidClicked:(UIButton *)button
{
    self.pwdTF.secureTextEntry = !button.selected;
    button.selected = !button.selected;
}

- (void)agreementClicked:(UIButton *)button
{
    button.selected = !button.selected;
    self.regButton.enabled = button.selected;
}

- (void)accountAndPasswordLoginClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bindEmailClicked:(UIButton *)button
{
    button.selected = !button.selected;
    self.isNeedBindEmail = button.selected;
    
    self.nickTF.text = nil;
    self.pwdTF.text = nil;
    
    if (self.isNeedBindEmail) {
        self.nickTF.placeholder = @"请输入已有邮箱账号";
        self.pwdTF.placeholder = @"请输入邮箱账号密码";
        [self.regButton setTitle:@"绑定邮箱账号" forState:UIControlStateNormal];
    } else {
        self.nickTF.placeholder = @"请设置您的昵称";
        self.pwdTF.placeholder = @"请设置登录密码";
        [self.regButton setTitle:@"注册" forState:UIControlStateNormal];
    }
}

- (void)confirmClicked
{
    // 校验手机格式
    NSError *error = nil;
    [CBMobileValidator validateText:self.accountTF.text error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    if (self.pwdTF.text.length <= 0) {
        [MBProgressHUD showError:@"密码不能为空" toView:self.view];
        return;
    }
    
    if (self.nickTF.text.length <= 0) {
        [MBProgressHUD showError:@"昵称不能为空" toView:self.view];
        return;
    }
    
    if (self.isNeedBindEmail) {
        // 绑定
        
        // 检验邮箱格式
        NSError *error = nil;
        [CBEmailValidator validateText:self.nickTF.text error:&error];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
            return;
        }
        
        CBWeakSelf
        [TIOChat.shareSDK.loginManager bindPhone:self.accountTF.text toEmail:self.nickTF.text code:self.codeTF.text password:self.pwdTF.text option:1 completion:^(NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                TRegisterResultViewController *vc = [TRegisterResultViewController.alloc init];
                vc.content = @"绑定成功";
                vc.detail = @"您可以使用手机或邮箱进行登录了";
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    } else {
        // 注册
        CBWeakSelf
        [TIOChat.shareSDK.loginManager registerLoginname:self.accountTF.text password:self.pwdTF.text nick:self.nickTF.text code:self.codeTF.text completion:^(NSError * _Nullable error, NSString * _Nullable msg) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [self autoFillLoginnameToLoginVC];
                TRegisterResultViewController *vc = [TRegisterResultViewController.alloc init];
                vc.content = @"注册成功";
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

/// 自动填充注册/绑定的手机号到登录页
- (void)autoFillLoginnameToLoginVC
{
    NSArray *vcs = self.navigationController.viewControllers;
    for (UIViewController *vc in vcs) {
        if ([vc isKindOfClass:NSClassFromString(@"LoginVC")]) {
            LoginVC *loginVC = (LoginVC *)vc;
            loginVC.accountTF.text = self.accountTF.text;
            break;
        }
    }
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
    if (textField == self.codeTF) {
        // 校验是否是手机号
        NSError *error = nil;
        [CBMobileValidator validateText:self.accountTF.text error:&error];
        if (!error) {
            if (!self.countdownTimer.valid) {
                self.smsButton.enabled = YES;
            }
        }
    }
    textField.layer.borderWidth = 1.f;
    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
    return YES;
}

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.accountTF resignFirstResponder];
    [self.pwdTF resignFirstResponder];
    [self.nickTF resignFirstResponder];
}

#pragma mark M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData
{
    if ([linkData isEqualToNumber:@(1)]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([linkData isEqualToNumber:@(2)]) {
        NSString *url = [TIOChat.shareSDK.config.httpsAddress stringByAppendingString:@"/appinsert/useragreement.html"];
        WKWebViewController *web = [WKWebViewController.alloc init];
        web.urlString = url;
        [self.navigationController pushViewController:web animated:YES];
    } else {
        NSString *url = [TIOChat.shareSDK.config.httpsAddress stringByAppendingString:@"/appinsert/privacy.html"];
        WKWebViewController *web = [WKWebViewController.alloc init];
        web.urlString = url;
        [self.navigationController pushViewController:web animated:YES];
    }
}

#pragma mark - 输入框

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

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    // 校验是否是手机号
    NSError *error = nil;
    [CBMobileValidator validateText:self.accountTF.text error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    // 键盘下去
    [self.codeTF resignFirstResponder];
    
    // SDK API 获取验证码
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkMobile:self.accountTF.text type:2 handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            CBWeakSelf
            [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
                CBStrongSelfElseReturn
                NSLog(@"result = %@",result);
                CBWeakSelf
                [TIOChat.shareSDK.loginManager fetchSMSWithType:2 mobile:self.accountTF.text token:result handler:^(NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    if (error) {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    } else {
                        [self startCountdownTimerIfNecessary]; // 开始倒计时
                    }
                }];
            }];
        }
    }];
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
