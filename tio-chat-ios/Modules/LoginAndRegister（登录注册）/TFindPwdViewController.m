//
//  TFindPwdViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TFindPwdViewController.h"
#import "UIImage+TColor.h"
#import "DefineHeader.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "TAlertController.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"
#import "CaptchaView.h"
#import "TFindPwdTwoViewController.h"

@interface TFindPwdViewController () <UITextFieldDelegate>
@property (weak, nonatomic) UITextField *accountTF;
@property (weak, nonatomic) UILabel *errorLabel;
@property (weak,    nonatomic) UIButton *nextButton;
@end

@implementation TFindPwdViewController

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
    [self setupUI2];
    
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
    logo.image = [UIImage imageNamed:@"Group 1321315510"];
    logo.centerX = self.view.middleX;
    logo.top = Height_StatusBar + 74;
    [self.view addSubview:logo];
    
    [self.view addSubview:({
        UILabel *label = [UILabel.alloc init];
        label.text = @"季风";
        label.textColor = [UIColor colorWithHex:0x0087FC];
        label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        [label sizeToFit];
        label.centerX = self.view.middleX;
        label.top = logo.bottom+17;
        
        label;
    })];
    
    UILabel *label = [UILabel.alloc init];
    label.text = @"忘记密码";
    label.textColor = [UIColor colorWithHex:0x9199A4];
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [label sizeToFit];
    label.top = bg1.bottom + 54;
    label.left = 37;
    [self.view addSubview:label];
    
    UITextField *accountTF = ({
        UITextField *textfiled = [self textFiled:@"请输入手机号" left:15 right:0];
        textfiled.top = label.bottom + 6.5;
        textfiled.delegate = self;
        [textfiled addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
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
    [self.view addSubview:accountTF];
    self.accountTF = accountTF;
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, Height_StatusBar+325, self.view.width-38*2, 48);
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x0087FC],[UIColor colorWithHex:0x0087FC]]];
        [button setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:6 size:button.viewSize] forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:6 size:button.viewSize] forState:UIControlStateHighlighted];
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
    // 校验是否是手机号
    NSError *error = nil;
    [CBMobileValidator validateText:textfield.text error:&error];
    self.nextButton.enabled = !error;
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
//    textfiled.layer.shadowColor = [UIColor colorWithRed:235/255.0 green:243/255.0 blue:255/255.0 alpha:1.0].CGColor;
//    textfiled.layer.shadowOffset = CGSizeMake(0,3);
//    textfiled.layer.shadowRadius = 6;
//    textfiled.layer.shadowOpacity = 1;
    
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
    // 键盘下去
    [self.accountTF resignFirstResponder];
    
    // SDK API 获取验证码
    CBWeakSelf
    [TIOChat.shareSDK.loginManager checkMobile:self.accountTF.text type:6 handler:^(NSInteger re, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            CBWeakSelf
            [CaptchaView showWithType:puzzle CompleteBlock:^(NSString * _Nonnull result) {
                CBStrongSelfElseReturn
                NSLog(@"result = %@",result);
                
                CBWeakSelf
                [TIOChat.shareSDK.loginManager fetchSMSWithType:6 mobile:self.accountTF.text token:result handler:^(NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    if (error) {
                        [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    } else {
                        // 跳转下一页
                        TFindPwdTwoViewController *vc = [TFindPwdTwoViewController.alloc init];
                        vc.phone = self.accountTF.text;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }];
            }];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

@end
