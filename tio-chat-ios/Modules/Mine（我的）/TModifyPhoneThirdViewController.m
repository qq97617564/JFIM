//
//  TModifyPhoneThirdViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TModifyPhoneThirdViewController.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "ImportSDK.h"

@interface TModifyPhoneThirdViewController ()

@end

@implementation TModifyPhoneThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI
{
    [self commonUI];
    
    UIImageView *icon = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"mine_result"]];
    icon.frame = CGRectMake(0, 0, 128, 128);
    icon.centerX = self.view.middleX;
    icon.top = Height_NavBar + 106;
    [self.view addSubview:icon];
    
    UILabel *lable1 = [UILabel.alloc init];
    lable1.text = @"修改手机成功！";
    lable1.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    lable1.textColor = [UIColor colorWithHex:0x333333];
    [lable1 sizeToFit];
    lable1.centerX = self.view.middleX;
    lable1.top = icon.bottom + 20;
    [self.view addSubview:lable1];
    
    UILabel *lable2 = [UILabel.alloc init];
    lable2.text = @"请使用新的手机账号登录";
    lable2.font = [UIFont systemFontOfSize:16];
    lable2.textColor = [UIColor colorWithHex:0x666666];
    [lable2 sizeToFit];
    lable2.centerX = self.view.middleX;
    lable2.top = lable1.bottom + 12;
    [self.view addSubview:lable2];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(38, lable2.bottom+40, self.view.width-38*2, 50);
    UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:loginButton.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x3B8AFF]]];
    UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:loginButton.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
    [loginButton setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:loginButton.viewSize] forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:loginButton.viewSize] forState:UIControlStateHighlighted];
    [loginButton setTitle:@"返回登录" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)commonUI
{
    NSArray *icons = @[@"w_progress_3",@"w_progress_3",@"w_progress_1"];
    NSArray *strings = @[@"验证原手机",@"绑定新手机",@"修改成功"];
    
    NSInteger index = 2;
    CGFloat padding = (self.view.width - icons.count*22) / (icons.count+1);
    
    for (int i = 0; i < icons.count; i++) {
        UIImageView *imageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:icons[i]]];
        imageView.frame = CGRectMake(padding + (padding+22)*i, Height_NavBar+32, 22, 22);
        [self.view addSubview:imageView];
        
        UILabel *label = [UILabel.alloc init];
        label.text = strings[i];
        label.textColor = i == index ? [UIColor colorWithHex:0x333333] : [UIColor colorWithHex:0x888888];
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        label.centerX = imageView.centerX;
        label.top  = imageView.bottom + 10;
        [self.view addSubview:label];
        
        if (i < icons.count - 1) {
            UILabel *line = [UILabel.alloc init];
            line.width = padding - 8;
            line.height = 1;
            line.left = imageView.right + 4;
            line.centerY = imageView.centerY;
            line.backgroundColor = [UIColor colorWithHex:0xF1F1F1];
            [self.view addSubview:line];
        }
    }
}

#pragma mark - actions

- (void)confirm:(id)sender
{
    // 退出 重新登录
    [TIOChat.shareSDK.loginManager logout:^(NSError * _Nullable error) {
    }];
}

@end
