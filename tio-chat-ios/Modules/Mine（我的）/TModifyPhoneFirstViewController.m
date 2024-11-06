//
//  TModifyPhoneFirstViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TModifyPhoneFirstViewController.h"
#import "TModifyPhoneSecondViewController.h"


#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"
#import "CaptchaView.h"
#import "UIImage+TColor.h"

@interface TModifyPhoneFirstViewController () <UITextFieldDelegate>
@property (weak, nonatomic) UITextField *codeTF;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;
@end

@implementation TModifyPhoneFirstViewController

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
    titleL.frame = CGRectMake(16,Height_NavBar+35,196,22.5);
    titleL.numberOfLines = 0;
    titleL.text = @"验证原手机：";
    titleL.textColor = [UIColor colorWithHex:0x9199A4];
    titleL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [self.view addSubview:titleL];

    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(15, Height_NavBar+65, ScreenWidth()-30, 260)];
    backView.backgroundColor = UIColor.whiteColor;
    backView.layer.cornerRadius = 6;
    backView.layer.masksToBounds = true;
    [self.view addSubview:backView];
    NSString *phone = TIOChat.shareSDK.loginManager.userInfo.phone;
    if (phone.length == 11) {
        phone = [phone stringByReplacingCharactersInRange:NSMakeRange(4, 4) withString:@"****"];
    }
    
    UILabel *label = [UILabel.alloc init];
    label.numberOfLines = 2;
    label.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc initWithString:@"更换手机号需要输入当前手机号验证码\n当前手机号为：" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x999999], NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightBold]}];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:phone attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x0087FC], NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightBold]}]];
        
        aString;
    });
    [label sizeToFit];
    label.left = 17;
    label.top = 16;
    [backView addSubview:label];
    
    UITextField *codeTF = ({
        UITextField *textfiled = [self textFiled:@"请输入验证码" left:15 right:104];
        textfiled.left = 17;
        textfiled.width = ScreenWidth()-30-34;
        textfiled.top = 82;
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
            [smsButton setTitleColor:[UIColor colorWithHex:0x0087FC] forState:UIControlStateNormal];
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
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(17, codeTF.bottom+50, ScreenWidth()-30-34, 48);
    UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:loginButton.bounds andColors:@[[UIColor colorWithHex:0x0087FC],[UIColor colorWithHex:0x0087FC]]];
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
//    NSArray *icons = @[@"w_progress_1",@"w_progress_2",@"w_progress_2"];
//    NSArray *strings = @[@"验证原手机",@"绑定新手机",@"修改成功"];
//    
//    NSInteger index = 0;
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

- (UITextField *)textFiled:(NSString *)placeholder left:(CGFloat)left right:(CGFloat)right
{
    UITextField *textfiled = [UITextField.alloc initWithFrame:CGRectMake(17, 0, self.view.width-32*2, 48)];
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

#pragma mark - actions

- (void)confirm:(id)sender
{
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkSMSCode:self.codeTF.text type:5 mobile:TIOChat.shareSDK.loginManager.userInfo.phone handler:^(NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            // 进入下一步 （下一页）
            TModifyPhoneSecondViewController *vc = TModifyPhoneSecondViewController.alloc.init;
            vc.oldSMSCode = self.codeTF.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    // 键盘下去
    [self.codeTF resignFirstResponder];

//#pragma marl - test
//    [self startCountdownTimerIfNecessary]; // 开始倒计时
//    return;
    
    NSString *phone = TIOChat.shareSDK.loginManager.userInfo.phone;
    
    if (!phone.length) return;
    
    // SDK API 获取验证码
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkMobile:phone type:5 handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            CBWeakSelf
            [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
                CBStrongSelfElseReturn
                NSLog(@"result = %@",result);
                CBWeakSelf
                [TIOChat.shareSDK.loginManager fetchSMSWithType:5 mobile:phone token:result handler:^(NSError * _Nullable error) {
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
