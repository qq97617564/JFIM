//
//  TRegisterResultViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TRegisterResultViewController.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"

@interface TRegisterResultViewController ()

@end

@implementation TRegisterResultViewController

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
    
    UIImageView *bg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, statuBar.bottom, self.view.width, FlexWidth(107))];
    bg1.image = [UIImage imageNamed:@"reg_bg"];
    [self.view addSubview:bg1];
    
    UIImageView *logo = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"reg_result"]];
    [logo sizeToFit];
    logo.top = Height_StatusBar + 45;
    logo.centerX = self.view.middleX;
    [self.view addSubview:logo];
    
    UILabel *contentLabel = [UILabel.alloc init];
    contentLabel.text = self.content;
    contentLabel.textColor = [UIColor colorWithHex:0x333333];
    contentLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    [contentLabel sizeToFit];
    contentLabel.centerX = self.view.middleX;
    contentLabel.top = Height_StatusBar + 193;
    [self.view addSubview:contentLabel];
    
    if (self.detail) {
        UILabel *detailLabel = [UILabel.alloc init];
        detailLabel.text = self.detail;
        detailLabel.textColor = [UIColor colorWithHex:0x666666];
        detailLabel.font = [UIFont systemFontOfSize:16];
        [detailLabel sizeToFit];
        detailLabel.centerX = self.view.middleX;
        detailLabel.top = Height_StatusBar + 234;
        [self.view addSubview:detailLabel];
    }
    
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(38, Height_StatusBar+303, self.view.width-38*2, 50);
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:button.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
        [button setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:button.viewSize] forState:UIControlStateHighlighted];
        [button setTitle:@"返回登录" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)confirmClicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
