//
//  WalletRechargeResultViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletRechargeResultViewController.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"

@interface WalletRechargeResultViewController ()

@end

@implementation WalletRechargeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if (self.resultType == 1) {
        [self loadSuccessedUI];
    } else if (self.resultType == 2) {
        [self loadFailedUI];
    } else if (self.resultType == 3) {
        [self loadProcessingUI];
    } else {
        
    }
}

- (void)loadSuccessedUI
{
    UIImageView *logo = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"w_recharge_success"]];
    [logo sizeToFit];
    logo.centerX = self.view.middleX;
    logo.top = Height_NavBar+8;
    [self.view addSubview:logo];
    
    UILabel *successLabel = [UILabel.alloc init];
    successLabel.text = @"充值成功";
    successLabel.textColor = [UIColor colorWithHex:0x333333];
    successLabel.font = [UIFont systemFontOfSize:16];
    [successLabel sizeToFit];
    successLabel.top = logo.bottom+2;
    successLabel.centerX = self.view.middleX;
    [self.view addSubview:successLabel];
    
    UILabel *moneyLabel = [UILabel.alloc init];
    moneyLabel.frame = CGRectMake(16, Height_NavBar+158, self.view.width-32, 50);
    moneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc initWithString:@"¥ " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightBold], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}];
        [aString appendAttributedString:[NSMutableAttributedString.alloc initWithString:self.money attributes:@{NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:38], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}]];
        
        
        aString;
    });
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:moneyLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.viewSize = CGSizeMake(200, 40);
    button.centerX = self.view.middleX;
    button.bottom = self.view.height - 90;
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x8EBAFC]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateHighlighted];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)loadFailedUI
{
    UIImageView *logo = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"w_recharge_error"]];
    [logo sizeToFit];
    logo.centerX = self.view.middleX;
    logo.top = Height_NavBar+8;
    [self.view addSubview:logo];
    
    UILabel *contentLabel = [UILabel.alloc init];
    contentLabel.text = @"充值失败";
    contentLabel.textColor = [UIColor colorWithHex:0x333333];
    contentLabel.font = [UIFont systemFontOfSize:16];
    [contentLabel sizeToFit];
    contentLabel.top = logo.bottom+2;
    contentLabel.centerX = self.view.middleX;
    [self.view addSubview:contentLabel];
    
    UILabel *moneyLabel = [UILabel.alloc init];
    moneyLabel.frame = CGRectMake(16, Height_NavBar+158, self.view.width-32, 50);
    moneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc initWithString:@"¥ " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightBold], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}];
        [aString appendAttributedString:[NSMutableAttributedString.alloc initWithString:self.money attributes:@{NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:38], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}]];
        
        
        aString;
    });
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:moneyLabel];
    
    UILabel *errorLabel = [UILabel.alloc init];
    errorLabel.text = self.errorMessage;
    errorLabel.textColor = [UIColor colorWithHex:0x4C94FF];
    errorLabel.font = [UIFont systemFontOfSize:16];
    [errorLabel sizeToFit];
    errorLabel.top = Height_NavBar+217;
    errorLabel.centerX = self.view.middleX;
    [self.view addSubview:errorLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.viewSize = CGSizeMake(200, 40);
    button.centerX = self.view.middleX;
    button.bottom = self.view.height - 90;
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x8EBAFC]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateHighlighted];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)loadProcessingUI
{
    UILabel *titleLabel = [UILabel.alloc init];
    titleLabel.text = @"充值金额";
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel sizeToFit];
    titleLabel.top = Height_NavBar+2;
    titleLabel.centerX = self.view.middleX;
    [self.view addSubview:titleLabel];
    
    UILabel *moneyLabel = [UILabel.alloc init];
    moneyLabel.frame = CGRectMake(16, Height_NavBar+28, self.view.width-32, 50);
    moneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc initWithString:@"¥" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightBold], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}];
        [aString appendAttributedString:[NSMutableAttributedString.alloc initWithString:self.money attributes:@{NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:38], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}]];
        
        
        aString;
    });
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:moneyLabel];
    
    // 处理进度
    NSArray *texts = @[@"提交充值",@"银行处理中",@"完成充值"];
    for (int i = 0; i < 3; i++) {
        NSString *imgName = i==2?@"w_progress_2":@"w_progress_1";
        UIImageView *img1 = [UIImageView.alloc initWithImage:[UIImage imageNamed:imgName]];
        img1.bounds = CGRectMake(0, 0, 22, 22);
        img1.top = Height_NavBar + 120 + i*(22+36);
        img1.left = FlexWidth(130);
        [self.view addSubview:img1];
        
        if (i == 0) {
            UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, 0, 1, 38)];
            line.centerX = img1.centerX;
            line.top = img1.bottom;
            line.backgroundColor = [UIColor colorWithHex:0x4C94FF];
            [self.view addSubview:line];
        } else if (i == 1) {
            UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, 0, 1, 38)];
            line.centerX = img1.centerX;
            line.top = img1.bottom;
            line.backgroundColor = [UIColor colorWithHex:0xF1F1F1];
            [self.view addSubview:line];
        }
        
        UIColor *color = i==2?[UIColor colorWithHex:0x9C9C9C]:[UIColor colorWithHex:0x333333];
        UILabel *label = [UILabel.alloc init];
        label.text = texts[i];
        label.textColor = color;
        label.font = [UIFont systemFontOfSize:16];
        [label sizeToFit];
        label.left = img1.right+8;
        label.centerY = img1.centerY;
        [self.view addSubview:label];
    }
    
    UILabel *errorLabel = [UILabel.alloc init];
    errorLabel.text = @"等待银行处理";
    errorLabel.textColor = [UIColor colorWithHex:0x4C94FF];
    errorLabel.font = [UIFont systemFontOfSize:16];
    [errorLabel sizeToFit];
    errorLabel.bottom = self.view.height - 220;
    errorLabel.centerX = self.view.middleX;
    [self.view addSubview:errorLabel];
    
    UILabel *errorLabel2 = [UILabel.alloc init];
    errorLabel2.text = @"可在“钱包明细”中查看详情";
    errorLabel2.textColor = [UIColor colorWithHex:0x9C9C9C];
    errorLabel2.font = [UIFont systemFontOfSize:16];
    [errorLabel2 sizeToFit];
    errorLabel2.top = errorLabel.bottom+8;
    errorLabel2.centerX = self.view.middleX;
    [self.view addSubview:errorLabel2];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.viewSize = CGSizeMake(200, 40);
    button.centerX = self.view.middleX;
    button.bottom = self.view.height - 90;
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x8EBAFC]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateHighlighted];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - actions

- (void)confirmClicked:(id)sender
{   
    [self.navigationController popViewControllerAnimated:YES];
}

@end
