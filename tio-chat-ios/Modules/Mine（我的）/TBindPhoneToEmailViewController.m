//
//  TBindPhoneToEmailViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TBindPhoneToEmailViewController.h"
#import "FrameAccessor.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"
#import "CaptchaView.h"
#import "UIImage+TColor.h"
#import "UIButton+Enlarge.h"
#import "TAlertController.h"

#import "TTabBarController.h"

#import "ImportSDK.h"

@interface TBindPhoneToEmailViewController () <UITextFieldDelegate, TIOLoginDelegate>
@property (weak,    nonatomic) UITextField *accountTF;
@property (weak,    nonatomic) UITextField *passwordTF;
@property (weak,    nonatomic) UITextField *codeTF;
@property (weak,    nonatomic) UIButton *doneButton;

@property (weak,    nonatomic) UIButton *smsButton;
@property (weak,    nonatomic) NSTimer *countdownTimer;
@end

@implementation TBindPhoneToEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    self.navigationBar.hidden = YES;
    
    UIImageView *logo = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 50, 50)];
    logo.image = [UIImage imageNamed:@"Group 1321315510"];
    logo.centerX = self.view.middleX;
    logo.top = Height_StatusBar + 45;
    [self.view addSubview:logo];
    
    [self.view addSubview:({
        UILabel *label = [UILabel.alloc init];
        label.text = @"季风";
        label.textColor = [UIColor colorWithHex:0x666666];
        label.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
        [label sizeToFit];
        label.centerX = self.view.middleX;
        label.top = logo.bottom+17;
        
        label;
    })];
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(16, Height_StatusBar, 120, 44);
        [button setImage:[UIImage imageNamed:@"nav_cancel"] forState:UIControlStateNormal];
        [button setTitle:@"绑定手机号" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-28];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [button addTarget:self action:@selector(cancelVC) forControlEvents:UIControlEventTouchUpInside];

        button;
    })];
    
    [self.view addSubview:({
        UILabel *label = [UILabel.alloc init];
        label.frame = CGRectMake(22, Height_StatusBar+183, self.view.width - 22*2, 44);
        label.text = @"根据国家有关法律法规要求，使用互联网服务需进行账号实名，请绑定实名手机号。";
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor colorWithHex:0x666666];
        label.font = [UIFont systemFontOfSize:14];
        
        label;
    })];
    
    
    UITextField *phoneTF = ({
        UITextField *textfiled = [self textFiled:@"请输入手机号" left:40 right:0];
        textfiled.top = Height_StatusBar + 255;
        textfiled.delegate = self;
        textfiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [textfiled addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
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
        UITextField *textfiled = [self textFiled:@"请输入短信验证码" left:40 right:104];
        textfiled.top = Height_StatusBar + 315;;
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
    self.codeTF = codeTF;
    
    if (self.type == 0) {
        UITextField *passwordTF = ({
            UITextField *textfiled = [self textFiled:@"请输入当前账号密码" left:40 right:56];
            textfiled.top = Height_StatusBar + 375;
            textfiled.delegate = self;
//            textfiled.secureTextEntry = YES;
//            textfiled.leftView = ({
//                UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
//                UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_pwd"]];
//                [left sizeToFit];
//                left.centerY = view.middleY;
//                left.right = view.width - 2;
//                [view addSubview:left];
//                view;
//            });
//            [textfiled.rightView addSubview:({
//                UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                eyeButton.frame = textfiled.rightView.bounds;
//                [eyeButton setImage:[UIImage imageNamed:@"showPassword"] forState:UIControlStateNormal];
//                [eyeButton setImage:[UIImage imageNamed:@"hidePassword"] forState:UIControlStateSelected];
//                [eyeButton addTarget:self action:@selector(eyeDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//                eyeButton.selected = YES;
//                
//                eyeButton;
//            })];
            
            textfiled;
        });
        [self.view addSubview:passwordTF];
        self.passwordTF = passwordTF;
    }
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, Height_StatusBar+460, self.view.width-38*2, 48);
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x0087FC],[UIColor colorWithHex:0x0087FC]]];
        [button setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:6 size:button.viewSize] forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:6 size:button.viewSize] forState:UIControlStateHighlighted];

        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        self.doneButton = button;
        
        button;
    })];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self cancelSideBack];
}

#pragma mark - TIOLoginDelegate

- (void)onThirdAccountDidBindToOldMobilephone:(NSString *)mobilePhone
{
    // 已经绑定成功
}

#pragma mark - actions

- (void)textfieldEditing:(UITextField *)textfield
{
    // 校验是否是手机号
    NSError *error = nil;
    [CBMobileValidator validateText:textfield.text error:&error];
    self.doneButton.enabled = !error;
}

- (void)eyeDidClicked:(UIButton *)button
{
    self.passwordTF.secureTextEntry = !button.selected;
    button.selected = !button.selected;
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
    
    if (self.codeTF.text.length <= 0) {
        [MBProgressHUD showError:@"验证码为空！" toView:self.view];
        return;
    }
    
    if (self.type == 0) {
        if (self.passwordTF.text.length <= 0) {
            [MBProgressHUD showError:@"当前账号密码不能为空！" toView:self.view];
            return;
        }
    }
    
    if (self.type == 0) {
        // 邮箱绑定
        CBWeakSelf
        [TIOChat.shareSDK.loginManager bindPhone:self.accountTF.text toEmail:TIOChat.shareSDK.loginManager.userInfo.email code:self.codeTF.text password:self.passwordTF.text option:3 completion:^(NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [MBProgressHUD showSuccess:@"手机号绑定成功" toView:self.view];
                CBWeakSelf
                [TIOChat.shareSDK.loginManager updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    if (error) {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    } else {
        // 三方登录的绑定
        CBWeakSelf
        [TIOChat.shareSDK.loginManager bindPhone:self.accountTF.text toEmail:@"" code:self.codeTF.text password:@"" option:2 completion:^(NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [MBProgressHUD showSuccess:@"手机号绑定成功" toView:self.view];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    // 重要建议：此刻建议更换根视图的方式 切换到登录后的页面
                    UIViewController *tabViewController = [TTabBarController.alloc init];
                    UIApplication.sharedApplication.delegate.window.rootViewController = tabViewController;
                });
            }
        }];
    }
}

- (void)cancelVC
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"确定要退出吗" preferredStyle:TAlertControllerStyleAlert];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        }];
        action;
    })];
    CBWeakSelf
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            CBStrongSelfElseReturn
            CBWeakSelf
            [TIOChat.shareSDK.loginManager logout:^(NSError * _Nullable error) {
                CBStrongSelfElseReturn
                if (error) [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }];
        }];
        action;
    })];
    [self presentViewController:alert animated:YES completion:nil];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderWidth = 0.f;
    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.codeTF) {
        if (!self.countdownTimer.isValid) {
            // 校验是否是手机号
            NSError *error = nil;
            [CBMobileValidator validateText:self.accountTF.text error:&error];
            if (!error) {
                self.smsButton.enabled = YES;
            }
        }
    }
    
    textField.layer.borderWidth = 1.f;
    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
    return YES;
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    // 重新获取验证码
    NSError *error = nil;
    [CBMobileValidator validateText:self.accountTF.text error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    // SDK API 获取验证码
    CBWeakSelf
    NSInteger type = self.type==0?1:8;// 区分邮箱绑定还是三方绑定
    [TIOChat.shareSDK.loginManager checkMobile:self.accountTF.text type:type handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [self alert2:error.localizedDescription];
        } else {
            if (self.type == 0) {
                [self evokeCaptchaView:type];
            } else {
                if (re == 1) {
                    // 当前手机号已注册，是否绑定到该三方账号
                    [self alert1:type];
                } else {
                    // 正常
                    [self evokeCaptchaView:type];
                }
            }
        }
    }];
}

- (void)evokeCaptchaView:(NSInteger)SMSType
{
    CBWeakSelf
    [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
        CBStrongSelfElseReturn
        NSLog(@"result = %@",result);
        CBWeakSelf
        [TIOChat.shareSDK.loginManager fetchSMSWithType:SMSType mobile:self.accountTF.text token:result handler:^(NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
#ifdef DEBUG
#endif
                [self startCountdownTimerIfNecessary]; // 开始倒计时
            }
        }];
    }];
}

- (void)alert1:(NSInteger)type
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"当前手机号已注册，是否绑定到该账号?" preferredStyle:TAlertControllerStyleAlert];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"换其他手机" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        }];
        action;
    })];
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"绑定该手机" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            [self evokeCaptchaView:type];
        }];
        action;
    })];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alert2:(NSString *)msg
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:msg preferredStyle:TAlertControllerStyleAlert];
    alert.maxActionCountOfOneLine = 1;
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        }];
        action;
    })];
    [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
