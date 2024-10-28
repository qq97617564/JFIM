//
//  TFindPwdThreeViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TFindPwdThreeViewController.h"
#import "TRegisterResultViewController.h"
#import "UIImage+TColor.h"
#import "DefineHeader.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "TAlertController.h"
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"

@interface TFindPwdThreeViewController () <UITextFieldDelegate>
@property (weak,    nonatomic) UITextField *textField1;
@property (weak,    nonatomic) UITextField *textField2;
@property (weak,    nonatomic) UIButton *nextButton;
@property (weak,    nonatomic) UITextField *currentEditingField;
@end

@implementation TFindPwdThreeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"";
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
    
    UILabel *label = [UILabel.alloc init];
    label.text = @"重置密码";
    label.textColor = [UIColor colorWithHex:0x9199A4];
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [label sizeToFit];
    label.top = bg1.bottom + 54;
    label.left = 37;
    [self.view addSubview:label];
    
    UITextField *passwordTF = ({
        UITextField *textfiled = [self textFiled:@"请输入至少6位数的新密码" left:15 right:56];
        textfiled.top = Height_StatusBar + 239;
        textfiled.delegate = self;
//        textfiled.secureTextEntry = YES;
        [textfiled addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
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
//            eyeButton.tag = 101;
//            
//            eyeButton;
//        })];
        
        self.textField1 = textfiled;
        
        textfiled;
    });
    [self.view addSubview:passwordTF];
    
    UITextField *passwordTF2 = ({
        UITextField *textfiled = [self textFiled:@"再次确认新密码" left:15 right:56];
        textfiled.top = Height_StatusBar + 299;
        textfiled.delegate = self;
//        textfiled.secureTextEntry = YES;
        [textfiled addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
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
//            eyeButton.tag = 102;
//            
//            eyeButton;
//        })];
        self.textField2 = textfiled;
        
        textfiled;
    });
    [self.view addSubview:passwordTF2];
    
    self.currentEditingField = passwordTF;
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, Height_StatusBar+393, self.view.width-38*2, 48);
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

#pragma mark - Actions

- (void)eyeDidClicked:(UIButton *)button
{
    if (button.tag == 101) {
        self.textField1.secureTextEntry = !button.selected;
    } else if (button.tag == 102) {
        self.textField2.secureTextEntry = !button.selected;
    } else {
        
    }
    button.selected = !button.selected;
}

- (void)doneButtonClicked:(UIButton *)button
{
    // 跳转下一页：密码设置成功
    
    // 校验两次密码是否一致
    if (![self.textField1.text isEqualToString:self.textField2.text]) {
        [MBProgressHUD showError:@"两次密码输入不一致,请检查密码" toView:self.view];
        return;
    }
    
    CBWeakSelf
    [TIOChat.shareSDK.loginManager beforeFindPasswordWithPhone:self.phone code:self.code completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            NSString *p = result[@"phone"];
            NSString *e = result[@"email"];
            CBWeakSelf
            [TIOChat.shareSDK.loginManager findPasswordWithNewPassword:self.textField1.text code:self.code phone:p email:e completion:^(NSError * _Nullable error) {
                CBStrongSelfElseReturn
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                } else {
                    // 进入完成页
                    TRegisterResultViewController *vc = [TRegisterResultViewController.alloc init];
                    vc.content = @"密码设置成功";
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

#pragma mark - 输入框

- (void)textfieldEditing:(UITextField *)textfield
{
    self.nextButton.enabled = [self.textField1.text isEqualToString:self.textField2.text];
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
    self.currentEditingField = textField;
    
    textField.layer.borderWidth = 1.f;
    textField.layer.borderColor = [UIColor colorWithHex:0x84B5FF].CGColor;
    return YES;
}


@end
