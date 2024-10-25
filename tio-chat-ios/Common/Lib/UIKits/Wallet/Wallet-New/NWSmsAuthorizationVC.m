//
//  NWSmsAuthorizationVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/3.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWSmsAuthorizationVC.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "ImportSDK.h"
#import "CaptchaView.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"

#import "NWSettingPayPasswordVC.h"

@interface NWSmsAuthorizationVC ()
@property (weak, nonatomic) UITextField *codeTF;
@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;
@property (copy,    nonatomic) NSString *phone;
@end

@implementation NWSmsAuthorizationVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"忘记支付密码";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phone = TIOChat.shareSDK.loginManager.userInfo.phone;
    [self setupUI];
}

- (void)setupUI
{
    
    UILabel *descLabel = [UILabel.alloc initWithFrame:CGRectMake(10, Height_NavBar+72, self.view.width - 20, 55)];
    descLabel.numberOfLines = 2;
    descLabel.attributedText = ({
        NSString *phone = self.phone;
        if (phone.length > 10) {
            phone = [phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
        NSMutableAttributedString *attributedString = [NSMutableAttributedString.alloc initWithString:@"短信验证码将发送至绑定手机" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"\n%@",phone] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]}]];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle.alloc init];
        style.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
        
        attributedString;
    });
    [self.view addSubview:descLabel];
    
    UITextField *codeTF = ({
        UITextField *textfiled = [UITextField.alloc initWithFrame:CGRectMake(38, Height_NavBar+157, self.view.width - 76, 44)];
        textfiled.keyboardType = UIKeyboardTypeNumberPad;
        textfiled.layer.cornerRadius = 4;
        textfiled.layer.borderWidth = 1;
        textfiled.layer.borderColor = [UIColor colorWithHex:0xF4F4F4].CGColor;
        textfiled.placeholder = @"请输入验证码";
        textfiled.leftViewMode = UITextFieldViewModeAlways;
        textfiled.leftView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, textfiled.height)];
            UIImageView *left = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"login_code"]];
            [left sizeToFit];
            left.centerY = view.middleY;
            left.right = view.width - 2;
            [view addSubview:left];
            view;
        });
        textfiled.rightViewMode = UITextFieldViewModeAlways;
        textfiled.rightView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 95, textfiled.height)];
        [textfiled.rightView addSubview:({
            // 获取验证码按钮
            UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            smsButton.frame = CGRectMake(0, 5, 90, 34);
            [smsButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:smsButton.viewSize] forState:UIControlStateNormal];
            [smsButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x9BC0F8]] imageWithCornerRadius:4 size:smsButton.viewSize] forState:UIControlStateDisabled];
            [smsButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [smsButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            smsButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [smsButton addTarget:self action:@selector(SMSButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.smsButton = smsButton;
            
            smsButton;
        })];
        
        textfiled;
    });
    [self.view addSubview:codeTF];
    self.codeTF = codeTF;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.viewSize = CGSizeMake(200, 40);
    nextButton.centerX = self.view.middleX;
    nextButton.top = codeTF.bottom + 34;
    [nextButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:nextButton.viewSize] forState:UIControlStateNormal];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
}

#pragma mark - actions
- (void)nextButtonClicked:(id)sender
{
    if (self.codeTF.text.length == 6) {
        CBWeakSelf
        NWSettingPayPasswordVC *vc = [NWSettingPayPasswordVC.alloc initWithTitle:@"忘记支付密码" code:NWPayPasswordCodeForget];
        vc.SMSCode = self.codeTF.text;
        vc.handler = ^(UIViewController * _Nonnull vController, BOOL re, NSString * _Nonnull pwd) {
            CBStrongSelfElseReturn
            [vController.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:vc animated:YES];
        
        /// 更改返回栈
        NSArray *tempVCs = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(0, self.navigationController.viewControllers.count-2)];
        [self.navigationController setViewControllers:[tempVCs arrayByAddingObject:vc]];
    }
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    NSError *error = nil;
    [CBMobileValidator validateText:self.phone error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    /// SDK API 获取验证码
    CBWeakSelf
    NSInteger type = 10;

    [TIOChat.shareSDK.loginManager checkMobile:self.phone type:type handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            [self evokeCaptchaView:type];
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
        [TIOChat.shareSDK.loginManager fetchSMSWithType:SMSType mobile:self.phone token:result handler:^(NSError * _Nullable error) {
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
