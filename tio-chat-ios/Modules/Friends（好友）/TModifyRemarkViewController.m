//
//  TModifyRemarkViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TModifyRemarkViewController.h"
#import "UIImage+TColor.h"
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"
#import "FrameAccessor.h"

@interface TModifyRemarkViewController ()
@property (nonatomic, strong) UITextField *textfield;
@end

@implementation TModifyRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.viewSize = CGSizeMake(60, 28);
    saveButton.top = Height_StatusBar + 8;
    saveButton.right = self.view.width - 16;
    saveButton.layer.cornerRadius = 14;
    saveButton.layer.masksToBounds = YES;
    saveButton.backgroundColor = [UIColor colorWithHex:0x0087FC];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:saveButton];
    
    UITextField *textfield = [UITextField.alloc initWithFrame:CGRectMake(0, Height_NavBar + 20, self.view.width, 60)];
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.font = [UIFont systemFontOfSize:16];
    textfield.textColor = [UIColor colorWithHex:0x333333];
    textfield.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 16, textfield.height)];
    textfield.leftViewMode = UITextFieldViewModeAlways;
    textfield.rightViewMode = UITextFieldViewModeWhileEditing;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:textfield];
    self.textfield = textfield;
}

- (void)save:(id)sender
{
    if (!self.textfield.text || self.textfield.text.length == 0) {
        return;
    }
    
    [TIOChat.shareSDK.friendManager updateRemark:self.textfield.text uid:self.uid completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            [MBProgressHUD showInfo:@"修改成功" toView:self.view];
            
            if (self.modifiedCallback) {
                self.modifiedCallback(self.textfield.text);
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

@end
