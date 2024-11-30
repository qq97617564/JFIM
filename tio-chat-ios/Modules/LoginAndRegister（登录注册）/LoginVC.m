//
//  LoginVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/21.
//  Copyright © 2024 刘宇. All rights reserved.
//

#import "LoginVC.h"

#import "UIImage+TColor.h"
#import "DefineHeader.h"
#import "TRegisteViewController.h"
#import "FrameAccessor.h"
#import "CBEmailValidator.h"
#import "TSMSLoginViewController.h"

#import "TIOHTTPSManager.h"

#import "TFindPwdViewController.h"
#import "UIControl+T_LimitClickCount.h"
#import <M80AttributedLabel.h>
#import "MBProgressHUD+NJ.h"
#import "WKWebViewController.h"
#import "UIButton+Enlarge.h"
#import <AuthenticationServices/AuthenticationServices.h>
/// SDK
#import "ImportSDK.h"
#import "RegisterVC.h"
#import "TTLogin.h"

@interface LoginVC () <UITextFieldDelegate, TIOLoginDelegate, M80AttributedLabelDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
@property (weak, nonatomic) IBOutlet UIView *pwdView;

@property (weak, nonatomic) IBOutlet UIView *zhView;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetButton;
@property(nonatomic, strong)UIButton * protocolBtn;


@property (weak, nonatomic) UILabel *errorLabel;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self setupUI];
    [self setupUI2];
    
    // 关闭推送
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    [self checkPrivacy];
}

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

- (void)setupUI2
{
    self.loginButton.layer.cornerRadius = 6;
    self.zhView.layer.cornerRadius = 6;
    self.zhView.layer.borderWidth = 1;
    self.zhView.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
    self.pwdView.layer.cornerRadius = 6;
    self.pwdView.layer.borderWidth = 1;
    self.pwdView.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.accountTF.delegate = self;
  
    
    self.pwdTF.delegate = self;
    UIImage *highlightBackgroundImage = [UIImage imageWithColor:[UIColor colorWithHex:0x7FC4FF]];
    UIImage *normalBackgroundImage = [UIImage imageWithColor:[UIColor colorWithHex:0x0087FC]];
    [self.loginButton setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:6 size:self.loginButton.viewSize] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:6 size:self.loginButton.viewSize] forState:UIControlStateHighlighted];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.loginButton addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    
    [self.forgetButton addTarget:self action:@selector(forgetClicked:) forControlEvents:UIControlEventTouchUpInside];

    
//    if (@available(iOS 13.0, *)) {
//        CGFloat leftPadding = (self.view.width - 3 * 40) / 4.f;
//
//        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        qqButton.viewSize = CGSizeMake(40, 40);
//        [qqButton setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
//        qqButton.tag = 100;
//        qqButton.left = leftPadding;
//        qqButton.bottom = self.view.height - 38;
//        [qqButton addTarget:self action:@selector(tloginClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:qqButton];
//
//        UIButton *wxButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        wxButton.viewSize = CGSizeMake(40, 40);
//        [wxButton setImage:[UIImage imageNamed:@"wx"] forState:UIControlStateNormal];
//        wxButton.tag = 101;
//        wxButton.left = qqButton.right + leftPadding;
//        wxButton.bottom = self.view.height - 38;
//        [wxButton addTarget:self action:@selector(tloginClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:wxButton];
//
//        ASAuthorizationAppleIDButton *appleLoginBtn = [[ASAuthorizationAppleIDButton alloc] initWithAuthorizationButtonType:ASAuthorizationAppleIDButtonTypeSignIn authorizationButtonStyle:ASAuthorizationAppleIDButtonStyleBlack];
//        appleLoginBtn.frame = CGRectMake(0, 0, 40, 40);
//        appleLoginBtn.left = wxButton.right + leftPadding;
//        appleLoginBtn.centerY = wxButton.centerY;
//        appleLoginBtn.layer.cornerRadius = 20;
//        appleLoginBtn.layer.masksToBounds = YES;
//        [appleLoginBtn addTarget:self action:@selector(appleLogin) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:appleLoginBtn];
//    } else {
        // Fallback on earlier versions
//        CGFloat leftPadding = (self.view.width - 2 * 40) / 3.f;
//
//        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        qqButton.viewSize = CGSizeMake(40, 40);
//        [qqButton setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
//        qqButton.tag = 100;
//        qqButton.left = leftPadding;
//        qqButton.bottom = self.view.height - 38;
//        [qqButton addTarget:self action:@selector(tloginClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:qqButton];
//
//        UIButton *wxButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        wxButton.viewSize = CGSizeMake(40, 40);
//        [wxButton setImage:[UIImage imageNamed:@"wx"] forState:UIControlStateNormal];
//        wxButton.tag = 101;
//        wxButton.left = qqButton.right + leftPadding;
//        wxButton.bottom = self.view.height - 38;
//        [wxButton addTarget:self action:@selector(tloginClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:wxButton];
//    }
    // 同意协议
    UIButton *protocolButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 24, 24);
        [button setImage:[UIImage imageNamed:@"login_selected"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"login_unselected"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(agreementClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    self.protocolBtn = protocolButton;
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
    protocolLabel.top = self.loginButton.bottom;

    [self.view addSubview:protocolLabel];
    
    protocolButton.left = 38;
    protocolButton.centerY = protocolLabel.centerY;
    protocolLabel.left = protocolButton.right + 2;
}
- (void)agreementClicked:(UIButton *)button
{

    button.selected = !button.selected;
    self.loginButton.enabled = button.selected;
}
#pragma mark - 输入框

- (UITextField *)textFiled:(NSString *)placeholder left:(CGFloat)left right:(CGFloat)right
{
    UITextField *textfiled = [UITextField.alloc initWithFrame:CGRectMake(LoginFieldLeftPadding, 0, LoginFieldWidth, LoginFieldHeight)];
    textfiled.backgroundColor = UIColor.whiteColor;
    textfiled.placeholder = placeholder;
    if (left > 0) {
        textfiled.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, left, textfiled.height)];
        textfiled.leftViewMode = UITextFieldViewModeAlways;
    }
    if (right > 0) {
        textfiled.rightView = [UIView.alloc initWithFrame:CGRectMake(0, 0, left, textfiled.height)];
        textfiled.rightViewMode = UITextFieldViewModeAlways;
    } else {
        textfiled.rightViewMode = UITextFieldViewModeWhileEditing;
        textfiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    textfiled.textColor = [UIColor colorWithHex:0x333333];
    textfiled.font = [UIFont systemFontOfSize:16];
    
    textfiled.layer.cornerRadius = 22;
    textfiled.layer.shadowColor = [UIColor colorWithRed:235/255.0 green:243/255.0 blue:255/255.0 alpha:1.0].CGColor;
    textfiled.layer.shadowOffset = CGSizeMake(0,3);
    textfiled.layer.shadowRadius = 6;
    textfiled.layer.shadowOpacity = 1;
    
    return textfiled;
}

#pragma mark - Actions

- (IBAction)registClick:(id)sender {
    RegisterVC *vc= [[RegisterVC alloc]init];
    vc.params = self.params;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)eyeDidClicked:(UIButton *)button
{
    self.pwdTF.secureTextEntry = !button.selected;
    button.selected = !button.selected;
}

- (void)loginClicked:(UIButton *)button
{
    if (!self.self.protocolBtn.isSelected) {
        [MBProgressHUD showError: @"请先阅读并同意《用户服务协议》和《隐私政策》"];
        return;
    }
//    if (self.accountTF.text.length <= 0) {
//        [MBProgressHUD showInfo:@"账户不能为空" toView:self.view];
//        return;
//    }
//
//    if (self.pwdTF.text.length <= 0) {
//        [MBProgressHUD showInfo:@"密码不能为空" toView:self.view];
//        return;
//    }
    
    /// TIOChat SDK登录功能中内置了输入框空值判断
    /// 在completion内处理异常
    
    [MBProgressHUD showLoading:@"正在登录" toView:self.view];
    [TIOChat.shareSDK.loginManager login:self.accountTF.text
                                password:self.pwdTF.text
                                authcode:nil
                              completion:^(TIOLoginUser * _Nullable userData, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

- (void)forgetClicked:(UIButton *)button
{
    [self.navigationController pushViewController:[TFindPwdViewController.alloc init] animated:YES];
}

- (void)smsButtonDidClicked
{
    TSMSLoginViewController *vc = [TSMSLoginViewController.alloc init];
    vc.params = self.params;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tloginClicked:(UIButton *)button
{
    ThirdPlatform platform = ThirdPlatformQQ;
    platform = button.tag==100?ThirdPlatformQQ:ThirdPlatformWX;
    
    CBWeakSelf
    [TTLogin tLoginWithType:platform currentVC:self completion:^(NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
}

#pragma mark - AppleID Sign

- (void)appleLogin {
    if (@available(iOS 13.0, *)) {
        
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        // 用户授权请求的联系信息
        appleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest]];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    } else {
        [MBProgressHUD showError:@"该系统版本不可用Apple登录" toView:self.view];
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *user = appleIDCredential.user;
        // 使用过授权的，可能获取不到以下三个参数
        NSString *familyName = appleIDCredential.fullName.familyName;
        NSString *givenName = appleIDCredential.fullName.givenName;
        NSString *email = appleIDCredential.email;
        
        // 服务器验证需要使用的参数
        NSString *identityTokenStr = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
        NSString *authorizationCodeStr = [[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding];
        NSLog(@"%@\n\n%@", identityTokenStr, authorizationCodeStr);
        
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
            // 用户登录使用现有的密码凭证（iCloud记录的）
        ASPasswordCredential *passwordCredential = authorization.credential;
            // 密码凭证对象的用户标识 用户的唯一标识
        NSString *user = passwordCredential.user;
            // 密码凭证对象的密码
        NSString *password = passwordCredential.password;
        
        
            
    } else {
            NSLog(@"授权信息均不符");
            [MBProgressHUD showError:@"授权信息均不符" toView:self.view];
        
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
            
        default:
            break;
    }
    NSLog(@"%@", errorMsg);
    [MBProgressHUD showError:errorMsg toView:self.view];
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

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    textField.layer.borderWidth = 0.f;
//    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
//}
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    textField.layer.borderWidth = 1.f;
//    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
//    return YES;
//}

#pragma mark - SDK
#pragma mark - TIOLoginDelegate

- (void)onLogin:(NSError *)error
{
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

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.accountTF resignFirstResponder];
    [self.pwdTF resignFirstResponder];
}

#pragma mark - 用户权限隐私

- (void)checkPrivacy
{
    if (![[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppVersion"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"AppVersion"];
        [self showPrivacy];
    } else {
        if (![NSUserDefaults.standardUserDefaults boolForKey:@"isAgreePrivacy"]) {
            [self showPrivacy];
        }
    }
}

- (void)showPrivacy
{
    UIView *mask = [UIView.alloc initWithFrame:self.view.bounds];
    mask.tag = 444;
    mask.backgroundColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:62/255.0 alpha:1.0];
    mask.alpha = 0;
    [self.view addSubview:mask];
    
    [UIView animateWithDuration:0.2 animations:^{
        mask.alpha = 0.5;
    }];
    
    
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 324, 473)];
    view.tag = 555;
    view.center = self.view.middlePoint;
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:view];

    UILabel *titLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 22, 150, 22)];
    titLabel.text = @"个人信息保护指引";
    titLabel.font = [UIFont systemFontOfSize:16];
    titLabel.textColor = [UIColor colorWithHex:0x4C94FF];
    titLabel.centerX = view.middleX;
    [view addSubview:titLabel];

    UILabel *cLabel = [UILabel.alloc initWithFrame:CGRectMake(19, 65, 280, 284)];
    NSString *text = @"1、我们会遵循用户协议与隐私政策收集、使用信息，但不会仅因同意本隐私政策而采取强制捆绑的方式收集信息;\n2、在仅浏览时，为保障服务所必需，我们会收集设备信息、 操作日志信息，用于信息推送；\n3、摄像头、麦克风、相册权限均不会默认开启， 有经过明示授权才会在为实现相应功能或服务时使用， 会在功能或服务不需要时而通过您授权的权限收集信息。";
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 行间距设置为30
    [paragraphStyle  setLineSpacing:6];
    [paragraphStyle setParagraphSpacing:15];
    [paragraphStyle setAlignment:NSTextAlignmentJustified];
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:text];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    cLabel.attributedText = setString;
    cLabel.font = [UIFont systemFontOfSize:14];
    cLabel.textColor = [UIColor colorWithHex:0x333333];
    cLabel.numberOfLines = 0;
    [view addSubview:cLabel];

    M80AttributedLabel *protocolLabel = [M80AttributedLabel.alloc init];
    [protocolLabel appendText:@"查看完整版《用户协议》和《隐私协议》"];
    protocolLabel.font = [UIFont systemFontOfSize:14];
    protocolLabel.textColor = [UIColor colorWithHex:0x666666];
    [protocolLabel addCustomLink:@(2) forRange:NSMakeRange(5, 6) linkColor:[UIColor colorWithHex:0x54A7F8]];
    [protocolLabel addCustomLink:@(3) forRange:NSMakeRange(12, 6) linkColor:[UIColor colorWithHex:0x54A7F8]];
    protocolLabel.delegate = self;
    [protocolLabel sizeToFit];
    protocolLabel.centerX = view.middleX;
    protocolLabel.bottom = view.height - 80;
    [view addSubview:protocolLabel];

    UIButton *disagreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    disagreeBtn.viewSize = CGSizeMake(130, 40);
    disagreeBtn.layer.cornerRadius = 4;
    disagreeBtn.layer.masksToBounds = YES;
    disagreeBtn.left = 19;
    disagreeBtn.bottom = view.height - 20;
    [disagreeBtn setBackgroundColor:[UIColor colorWithHex:0xEBEBEB]];
    [disagreeBtn setTitle:@"不同意并退出" forState:UIControlStateNormal];
    [disagreeBtn setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
    disagreeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [disagreeBtn addTarget:self action:@selector(disagreePrivacy:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:disagreeBtn];

    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.viewSize = CGSizeMake(130, 40);
    agreeBtn.layer.cornerRadius = 4;
    agreeBtn.layer.masksToBounds = YES;
    agreeBtn.right = view.width - 19;
    agreeBtn.bottom = view.height - 20;
    [agreeBtn setBackgroundColor:[UIColor colorWithHex:0x4C94FF]];
    [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    agreeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [agreeBtn addTarget:self action:@selector(agreePrivacy:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:agreeBtn];

    view.transform = CGAffineTransformMakeScale(0.2, 0.2);

    [UIView animateWithDuration:0.3 animations:^{
        view.transform = CGAffineTransformIdentity;
    }];
}

- (void)agreePrivacy:(UIButton *)button
{
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"isAgreePrivacy"];
    
    UIView *alert = nil;
    UIView *mask = nil;
    
    for (UIView *subView in self.view.subviews) {
        if (subView.tag == 444) {
            mask = subView;
        } else if (subView.tag == 555) {
            alert = subView;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        mask.alpha = 0;
        alert.transform = CGAffineTransformMakeScale(0.2, 0.2);
    } completion:^(BOOL finished) {
        [mask removeFromSuperview];
        [alert removeFromSuperview];
    }];
}

- (void)disagreePrivacy:(UIButton *)button
{
    abort();
}

#pragma mark M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData
{
    if ([linkData isEqualToNumber:@(1)]) {
        RegisterVC *vc = [[RegisterVC alloc]init];
        vc.params = self.params;
        [self.navigationController pushViewController:vc animated:YES];
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


@end
