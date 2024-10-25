//
//  TFindPwdTwoViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TFindPwdTwoViewController.h"
#import "TFindPwdThreeViewController.h"
#import "UIImage+TColor.h"
#import "DefineHeader.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "TAlertController.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"
#import "CaptchaView.h"

@interface TFindPwdTwoViewController () <UITextFieldDelegate>
@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;
@property (weak, nonatomic) UITextField *codeTF;
@property (weak,    nonatomic) UIButton *nextButton;
@end

@implementation TFindPwdTwoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"返回";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI2];
    [self startCountdownTimerIfNecessary];
}

- (void)setupUI2
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView *statuBar = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statuBar.backgroundColor = [UIColor colorWithHex:0xDBEAFF];
    [self.view addSubview:statuBar];
    
    UIImageView *bg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, statuBar.bottom, self.view.width, FlexWidth(144))];
    bg1.image = [UIImage imageNamed:@"login_bg"];
    [self.view addSubview:bg1];
    
    UIImageView *logo = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 50, 50)];
    logo.image = [UIImage imageNamed:@"logo"];
    logo.centerX = self.view.middleX;
    logo.top = Height_StatusBar + 45;
    [self.view addSubview:logo];
    
    [self.view addSubview:({
        UILabel *label = [UILabel.alloc init];
        label.text = @"谭聊";
        label.textColor = [UIColor colorWithHex:0x666666];
        label.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
        [label sizeToFit];
        label.centerX = self.view.middleX;
        label.top = logo.bottom+17;
        
        label;
    })];
    
    UILabel *label = [UILabel.alloc init];
    label.text = @"获取验证码";
    [label sizeToFit];
    label.top = bg1.bottom + 54;
    label.left = 59;
    [self.view addSubview:label];
    
    UITextField *codeTF = ({
        UITextField *textfiled = [self textFiled:@"请输入验证码" left:40 right:104];
        textfiled.top = Height_StatusBar + 179;
        textfiled.delegate = self;
        textfiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [textfiled addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
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
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, Height_StatusBar+333, self.view.width-38*2, 50);
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x3B8AFF]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
        [button setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateHighlighted];
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.enabled = NO;
        self.nextButton = button;
        
        button;
    })];
    
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront:self.navigationBar];
}

#pragma mark - 输入框

- (void)textfieldEditing:(UITextField *)textfield
{
    // 校验短信收否输入
    self.nextButton.enabled = textfield.text.length;
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
    textfiled.font = [UIFont systemFontOfSize:16];
    
    textfiled.layer.cornerRadius = 22;
    textfiled.layer.shadowColor = [UIColor colorWithRed:235/255.0 green:243/255.0 blue:255/255.0 alpha:1.0].CGColor;
    textfiled.layer.shadowOffset = CGSizeMake(0,3);
    textfiled.layer.shadowRadius = 6;
    textfiled.layer.shadowOpacity = 1;
    
    return textfiled;
}

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

#pragma mark - Actions

- (void)doneButtonClicked:(UIButton *)button
{
    // 跳转下一页：输入新密码+确认新密码
    // 1、先检查验证码是否正确
    // 2、验证码正确后，进入设置密码页
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkSMSCode:self.codeTF.text type:6 mobile:self.phone handler:^(NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            TFindPwdThreeViewController *vc = [TFindPwdThreeViewController.alloc init];
            vc.phone = self.phone;
            vc.code = self.codeTF.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    // 校验是否是手机号
    NSError *error = nil;
    [CBMobileValidator validateText:self.codeTF.text error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    // SDK API 获取验证码
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkMobile:self.codeTF.text type:6 handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            CBWeakSelf
            [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
                CBStrongSelfElseReturn
                NSLog(@"result = %@",result);
                CBWeakSelf
                [TIOChat.shareSDK.loginManager fetchSMSWithType:6 mobile:self.codeTF.text token:result handler:^(NSError * _Nullable error) {
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
