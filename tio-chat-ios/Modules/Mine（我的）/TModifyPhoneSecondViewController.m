//
//  TModifyPhoneSecondViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TModifyPhoneSecondViewController.h"
#import "TModifyPhoneThirdViewController.h"

#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"
#import "CaptchaView.h"
#import "UIImage+TColor.h"

@interface TModifyPhoneSecondViewController () <UITextFieldDelegate>
@property (weak, nonatomic) UITextField *accountTF;
@property (weak, nonatomic) UITextField *pwdTF;
@property (weak, nonatomic) UITextField *codeTF;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;

@end

@implementation TModifyPhoneSecondViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"修改手机号";
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
//    [self commonUI];
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.frame = CGRectMake(15,Height_NavBar+35,196,22.5);
    titleL.numberOfLines = 0;
    titleL.text = @"绑定新手机：";
    titleL.textColor = [UIColor colorWithHex:0x9199A4];
    titleL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [self.view addSubview:titleL];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(15, Height_NavBar+65, ScreenWidth()-30, 406)];
    backView.backgroundColor = UIColor.whiteColor;
    backView.layer.cornerRadius = 6;
    backView.layer.masksToBounds = true;
    [self.view addSubview:backView];
    
    UILabel *titleA = [[UILabel alloc] init];
    titleA.frame = CGRectMake(20,24,196,18);
    titleA.numberOfLines = 0;
    titleA.text = @"手机号";
    titleA.textColor = [UIColor colorWithHex:0x9199A4];
    titleA.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [backView addSubview:titleA];
    // 手机号
    UITextField *phoneTF = ({
        UITextField *textfiled = [self textFiled:@"请输入手机号" left:15 right:0];
        textfiled.top = 48;
        textfiled.delegate = self;
        textfiled.keyboardType = UIKeyboardTypeNumberPad;
//        textfiled.leftView = ({
//            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
//            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_phone"]];
//            [left sizeToFit];
//            left.centerY = view.middleY;
//            left.right = view.width - 2;
//            [view addSubview:left];
//            view;
//        });
        
        textfiled;
    });
    [backView addSubview:phoneTF];
    self.accountTF = phoneTF;
    
    UILabel *titleB = [[UILabel alloc] init];
    titleB.frame = CGRectMake(20,107,196,18);
    titleB.numberOfLines = 0;
    titleB.text = @"验证码";
    titleB.textColor = [UIColor colorWithHex:0x9199A4];
    titleB.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [backView addSubview:titleB];
    UITextField *codeTF = ({
        UITextField *textfiled = [self textFiled:@"请输入验证码" left:15 right:104];
        textfiled.top = 131;
        textfiled.delegate = self;
        textfiled.keyboardType = UIKeyboardTypeNumberPad;
//        textfiled.leftView = ({
//            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
//            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_code"]];
//            [left sizeToFit];
//            left.centerY = view.middleY;
//            left.right = view.width - 2;
//            [view addSubview:left];
//            view;
//        });
        [textfiled.rightView addSubview:({
            // 获取验证码按钮
            UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            smsButton.frame = textfiled.rightView.bounds;
            [smsButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [smsButton setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
            [smsButton setTitleColor:[UIColor colorWithHex:0xBBBBBB] forState:UIControlStateDisabled];
            smsButton.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightBold];
            [smsButton addTarget:self action:@selector(SMSButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.smsButton = smsButton;
            
            smsButton;
        })];
        
        textfiled;
    });
    [backView addSubview:codeTF];
    self.codeTF = codeTF;
    
    
    UILabel *titleC = [[UILabel alloc] init];
    titleC.frame = CGRectMake(20,190,196,18);
    titleC.numberOfLines = 0;
    titleC.text = @"密码";
    titleC.textColor = [UIColor colorWithHex:0x9199A4];
    titleC.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [backView addSubview:titleC];
    UITextField *passwordTF = ({
        UITextField *textfiled = [self textFiled:@"请输入当前账号密码" left:15 right:56];
        textfiled.top = 214;
        textfiled.delegate = self;
//        textfiled.secureTextEntry = YES;
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
    [backView addSubview:passwordTF];
    self.pwdTF = passwordTF;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(20, 302, self.view.width-70, 48);
    UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:loginButton.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
    UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:loginButton.bounds andColors:@[[UIColor colorWithHex:0x0087FC],[UIColor colorWithHex:0x0087FC]]];
    [loginButton setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:6 size:loginButton.viewSize] forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:6 size:loginButton.viewSize] forState:UIControlStateHighlighted];
    [loginButton setTitle:@"提交" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightBold]];
    [loginButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:loginButton];
}

//- (void)commonUI
//{
//    NSArray *icons = @[@"w_progress_3",@"w_progress_1",@"w_progress_2"];
//    NSArray *strings = @[@"验证原手机",@"绑定新手机",@"修改成功"];
//    
//    NSInteger index = 1;
//    CGFloat padding = (self.view.width - icons.count*22) / (icons.count+1);
//    
//    for (int i = 0; i < icons.count; i++) {
//        UIImageView *imageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:icons[i]]];
//        imageView.frame = CGRectMake(padding + (padding+22)*i, Height_NavBar+32, 22, 22);
//        [self.view addSubview:imageView];
//        
//        UILabel *label = [UILabel.alloc init];
//        label.text = strings[i];
//        label.textColor = i == index ? [UIColor colorWithHex:0x333333] : [UIColor colorWithHex:0x888888];
//        label.font = [UIFont systemFontOfSize:14];
//        [label sizeToFit];
//        label.centerX = imageView.centerX;
//        label.top  = imageView.bottom + 10;
//        [self.view addSubview:label];
//        
//        if (i < icons.count - 1) {
//            UILabel *line = [UILabel.alloc init];
//            line.width = padding - 8;
//            line.height = 1;
//            line.left = imageView.right + 4;
//            line.centerY = imageView.centerY;
//            line.backgroundColor = [UIColor colorWithHex:0xF1F1F1];
//            [self.view addSubview:line];
//        }
//    }
//}

#pragma mark - actions

- (void)eyeDidClicked:(UIButton *)button
{
    self.pwdTF.secureTextEntry = !button.selected;
    button.selected = !button.selected;
}

- (void)confirm:(id)sender
{
    
    if (self.accountTF.text.length < 11) {
        [MBProgressHUD showError:@"手机号格式不正确" toView:self.view];
        return;
    }
    
    if (self.codeTF.text.length <= 0) {
        [MBProgressHUD showError:@"验证码未填写" toView:self.view];
        return;
    }
    
    if (self.pwdTF.text.length <= 0) {
        [MBProgressHUD showError:@"原密码未填写" toView:self.view];
        return;
    }
    
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkSMSCode:self.codeTF.text type:7 mobile:self.accountTF.text handler:^(NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            
            // 开始重新绑定
            CBWeakSelf
            [TIOChat.shareSDK.loginManager changeBoundPhone:self.accountTF.text code:self.codeTF.text password:self.pwdTF.text email:TIOChat.shareSDK.loginManager.userInfo.email?:@"" completion:^(NSInteger result, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                } else {
                    // 进入下一步 （下一页）
                    [self.navigationController pushViewController:TModifyPhoneThirdViewController.alloc.init animated:YES];
                }
            }];
        }
    }];
}

#pragma mark - 输入框

- (UITextField *)textFiled:(NSString *)placeholder left:(CGFloat)left right:(CGFloat)right
{
    UITextField *textfiled = [UITextField.alloc initWithFrame:CGRectMake(20, 0, self.view.width-70, 48)];
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
    
//#pragma marl - test
//    [self startCountdownTimerIfNecessary]; // 开始倒计时
//    return;
    
    // SDK API 获取验证码
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkMobile:self.accountTF.text type:7 handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            CBWeakSelf
            [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
                CBStrongSelfElseReturn
                NSLog(@"result = %@",result);
                CBWeakSelf
                [TIOChat.shareSDK.loginManager fetchSMSWithType:7 mobile:self.accountTF.text token:result handler:^(NSError * _Nullable error) {
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

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
