//
//  TMineUpdatePasswordViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TMineUpdatePasswordViewController.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "TAlertController.h"

@interface TMineUpdatePasswordViewController ()
/// 原始密码
@property (nonatomic,   strong) UILabel *errorLabel;
@property (nonatomic,   strong) UITextField *originTF;
/// 新密码
@property (nonatomic,   strong) UITextField *pwdTF;
/// 确认密码
@property (nonatomic,   strong) UITextField *confirmPwdTF;
@end

@implementation TMineUpdatePasswordViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = @"修改密码";
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
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    self.originTF = [UITextField.alloc initWithFrame:CGRectMake(0, Height_NavBar + 20, self.view.width, 60)];
    self.originTF.backgroundColor = [UIColor whiteColor];
    self.originTF.placeholder = @"请输入原密码";
    self.originTF.leftViewMode = UITextFieldViewModeAlways;
    self.originTF.leftView = [self labelWithText:@"原密码"];
    [self.view addSubview:self.originTF];
    
    self.pwdTF = [UITextField.alloc initWithFrame:CGRectMake(0, self.originTF.bottom, self.view.width, 60)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.placeholder = @"请输入新密码";
    self.pwdTF.leftViewMode = UITextFieldViewModeAlways;
    self.pwdTF.leftView = [self labelWithText:@"新密码"];
    [self.view addSubview:self.pwdTF];
    
    self.confirmPwdTF = [UITextField.alloc initWithFrame:CGRectMake(0, self.pwdTF.bottom, self.view.width, 60)];
    self.confirmPwdTF.backgroundColor = [UIColor whiteColor];
    self.confirmPwdTF.placeholder = @"再次输入新密码";
    self.confirmPwdTF.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPwdTF.leftView = [self labelWithText:@"确认新密码"];
    [self.view addSubview:self.confirmPwdTF];
    
    self.errorLabel = [UILabel.alloc initWithFrame:CGRectMake(80, self.confirmPwdTF.bottom, self.view.width - 160, 60)];
    self.errorLabel.textColor = [UIColor colorWithHex:0xFF754C];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.errorLabel];
    
    
    // 保存按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, self.confirmPwdTF.bottom+60, FlexWidth(256), 50);
    doneButton.centerX = self.view.middleX;
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = doneButton.bounds;
    gl.startPoint = CGPointMake(0.015625, 0.08695652335882187);
    gl.endPoint = CGPointMake(0.953125, 0.760869562625885);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:114/255.0 green:171/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:59/255.0 green:138/255.0 blue:255/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0),@(1.0f)];
    [doneButton.layer addSublayer:gl];

    doneButton.layer.cornerRadius = 25.f;
    doneButton.clipsToBounds = YES;
    
    doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneButton setTitle:@"保存" forState:UIControlStateNormal];
    [doneButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(updatePassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:doneButton];
}

- (UIView *)labelWithText:(NSString *)text
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 120, 60)];
    view.backgroundColor = UIColor.whiteColor;
    
    UILabel *label = [UILabel.alloc init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:16];
    [label sizeToFit];
    label.left = 16;
    label.centerY = view.middleY;
    [view addSubview:label];
    
    return view;
}

- (void)updatePassword:(id)sender
{
    if (!self.originTF.text.length) {
        self.errorLabel.text = @"请输入原密码";
        
        return;
    }
    
    if (!self.pwdTF.text.length) {
        self.errorLabel.text = @"请输入新密码";
        
        return;
    }
    
    if (!self.confirmPwdTF.text.length) {
        self.errorLabel.text = @"请再次输入新密码";
        
        return;
    }
    
    if (![self.pwdTF.text isEqualToString:self.confirmPwdTF.text]) {
        self.errorLabel.text = @"确认密码与新密码不一致";
        
        return;
    }
    
    [TIOChat.shareSDK.loginManager updatePassword:self.pwdTF.text
                                      oldPassword:self.originTF.text
                                       needLogout:NO
                                       completion:^(NSError * _Nullable error) {
        if (error)
        {
            self.errorLabel.text = error.localizedDescription;
        }
        else
        {
            TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"密码修改成功!" preferredStyle:TAlertControllerStyleAlert];
            alert.maxActionCountOfOneLine = 1;
            [alert addAction:[TAlertAction actionWithTitle:@"重新登录" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                // 执行退出操作
                [TIOChat.shareSDK.loginManager logout:^(NSError * _Nullable error) {
                    
                }];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
