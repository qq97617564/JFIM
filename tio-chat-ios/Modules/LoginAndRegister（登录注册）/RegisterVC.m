//
//  RegisterVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/21.
//  Copyright © 2024 刘宇. All rights reserved.
//

#import "RegisterVC.h"
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

@interface RegisterVC () <UITextFieldDelegate, M80AttributedLabelDelegate,TIOLoginDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UIView *pwdView;
@property (weak, nonatomic) IBOutlet UIView *codeView;

@property (weak, nonatomic) UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *regButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

/// 绑定邮箱
@property (weak,    nonatomic) UIButton *bindEmailButton;
@property (assign,  nonatomic) BOOL isNeedBindEmail;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;

@end

@implementation RegisterVC
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TIOChat.shareSDK.loginManager addDelegate:self];
    self.navigationBar.hidden = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TIOChat.shareSDK.loginManager removeDelegate:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI2];
}

- (void)setupUI2
{
    
    self.regButton.layer.cornerRadius = 6;
    self.accountView.layer.cornerRadius = 6;
    self.accountView.layer.borderWidth = 1;
    self.accountView.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
    self.pwdView.layer.cornerRadius = 6;
    self.pwdView.layer.borderWidth = 1;
    self.pwdView.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
    self.codeView.layer.cornerRadius = 6;
    self.codeView.layer.borderWidth = 1;
    self.codeView.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationBar.hidden = YES;
    
    UIView *statuBar = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statuBar.backgroundColor = [UIColor colorWithHex:0xDBEAFF];
    [self.view addSubview:statuBar];
    
    UIImageView *bg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, statuBar.bottom, self.view.width, FlexWidth(107))];
    bg1.image = [UIImage imageNamed:@"reg_bg"];
    [self.view addSubview:bg1];
    
    [self.loginButton  addTarget:self action:@selector(accountAndPasswordLoginClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    self.accountTF.delegate = self;
    
   
    self.codeTF.delegate = self;
    
    self.pwdTF.delegate = self;
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
    

   
        UIImage *highlightBackgroundImage = [UIImage imageWithColor:[UIColor colorWithHex:0x7FC4FF]];
        UIImage *normalBackgroundImage = [UIImage imageWithColor:[UIColor colorWithHex:0x0087FC]];
        [self.regButton setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:6 size:self.regButton.viewSize] forState:UIControlStateNormal];
        [self.regButton setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:6 size:self.regButton.viewSize] forState:UIControlStateHighlighted];
        [self.regButton setTitle:@"注册" forState:UIControlStateNormal];
        [self.regButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.regButton addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
       
    
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
    protocolLabel.font = [UIFont systemFontOfSize:11];
    protocolLabel.textColor = [UIColor colorWithHex:0x999999];
    protocolLabel.delegate = self;
    [protocolLabel addCustomLink:@(2) forRange:NSMakeRange(5, 8) linkColor:[UIColor colorWithHex:0x0087FC]];
    [protocolLabel addCustomLink:@(3) forRange:NSMakeRange(14, 6) linkColor:[UIColor colorWithHex:0x0087FC]];
    protocolLabel.underLineForLink = NO;
    protocolLabel.textAlignment = kCTTextAlignmentCenter;
    [protocolLabel sizeToFit];
//    protocolLabel.top = 447 + 44 + 15 + Height_StatusBar;
    protocolLabel.top = self.regButton.bottom;
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

//- (void)bindEmailClicked:(UIButton *)button
//{
//    button.selected = !button.selected;
//    self.isNeedBindEmail = button.selected;
//    
//    self.nickTF.text = nil;
//    self.pwdTF.text = nil;
//    
//    if (self.isNeedBindEmail) {
//        self.nickTF.placeholder = @"请输入已有邮箱账号";
//        self.pwdTF.placeholder = @"请输入邮箱账号密码";
//        [self.regButton setTitle:@"绑定邮箱账号" forState:UIControlStateNormal];
//    } else {
//        self.nickTF.placeholder = @"请设置您的昵称";
//        self.pwdTF.placeholder = @"请设置登录密码";
//        [self.regButton setTitle:@"注册" forState:UIControlStateNormal];
//    }
//}

- (void)confirmClicked
{
    // 校验是否包含字母
    if (![self isStringContainNumberWith:self.accountTF.text]){
        // 校验手机格式
        NSError *error = nil;
        [CBMobileValidator validateText:self.accountTF.text error:&error];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
            return;
        }
    }

    if (self.accountTF.text.length <= 0) {
        [MBProgressHUD showError:@"用户名不能为空" toView:self.view];
        return;
    }
    if (self.pwdTF.text.length <= 0) {
        [MBProgressHUD showError:@"密码不能为空" toView:self.view];
        return;
    }
    
//    if (self.nickTF.text.length <= 0) {
//        [MBProgressHUD showError:@"昵称不能为空" toView:self.view];
//        return;
//    }
//    
    if (self.isNeedBindEmail) {
//        // 绑定
//        
//        // 检验邮箱格式
//        NSError *error = nil;
//        [CBEmailValidator validateText:self.nickTF.text error:&error];
//        if (error) {
//            [MBProgressHUD showError:error.localizedDescription toView:self.view];
//            return;
//        }
//        
//        CBWeakSelf
//        [TIOChat.shareSDK.loginManager bindPhone:self.accountTF.text toEmail:self.nickTF.text code:self.codeTF.text password:self.pwdTF.text option:1 completion:^(NSError * _Nullable error) {
//            CBStrongSelfElseReturn
//            if (error) {
//                [MBProgressHUD showError:error.localizedDescription toView:self.view];
//            } else {
//                TRegisterResultViewController *vc = [TRegisterResultViewController.alloc init];
//                vc.content = @"绑定成功";
//                vc.detail = @"您可以使用手机或邮箱进行登录了";
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }];
    } else {
        // 注册
        NSTimeInterval timeS = [[NSDate date]timeIntervalSince1970];
        NSString *nick = [NSString stringWithFormat:@"用户%0.0f",timeS];
        CBWeakSelf
        [TIOChat.shareSDK.loginManager registerLoginname:self.accountTF.text password:self.pwdTF.text nick:nick code:self.codeTF.text completion:^(NSError * _Nullable error, NSString * _Nullable msg) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [self loginClick];
//                [self autoFillLoginnameToLoginVC];
//                TRegisterResultViewController *vc = [TRegisterResultViewController.alloc init];
//                vc.content = @"注册成功";
//                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}
- (BOOL)isStringContainNumberWith:(NSString *)str {

    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];

    NSInteger count = [numberRegular numberOfMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];

    //count是str中包含[A-Za-z]数字的个数，只要count>0，说明str中包含数字

    if (count > 0) {

        return YES;

    }

    return NO;

}

-(void)loginClick{
    [MBProgressHUD showLoading:@"正在登录" toView:self.view];
    [TIOChat.shareSDK.loginManager login:self.accountTF.text
                                password:self.pwdTF.text
                                authcode:nil
                              completion:^(TIOLoginUser * _Nullable userData, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
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
    if (textField.text.length > 10) {
        if (![string isEqualToString:@""]) {
            return NO;
        }

    }
    // 禁止输入空格
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];

    if (![string isEqualToString:tem]) {
        return NO;
    }

    return YES;
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    textField.layer.borderWidth = 0.f;
//    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (textField == self.codeTF) {
//        // 校验是否是手机号
//        NSError *error = nil;
//        [CBMobileValidator validateText:self.accountTF.text error:&error];
//        if (!error) {
//            if (!self.countdownTimer.valid) {
//                self.smsButton.enabled = YES;
//            }
//        }
//    }
//    textField.layer.borderWidth = 1.f;
//    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
    return YES;
}

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.accountTF resignFirstResponder];
    [self.pwdTF resignFirstResponder];
    [self.codeTF resignFirstResponder];
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
-(void)onLogin:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view];
    if (!error) {
        //TODO: 模拟登陆成功
        if (self.params) {
            if ([self.params.allKeys containsObject:@"callback"]) {
                ModuleCallback callback = self.params[@"callback"];
                callback(self, nil);
                TLogRetainCount(@"登录成功的回调 callback", callback);
            }
        }
    } else {
//        [MBProgressHUD showError:error.localizedDescription toView:self.view];
    }
}

@end
