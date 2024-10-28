//
//  WalletWithdrawResultViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWithdrawResultViewController.h"
#import "WalletWithdrawCard.h"

#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import "UIImageView+Web.h"

@interface WalletWithdrawResultViewController ()

@end

@implementation WalletWithdrawResultViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"提现";
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
//    UIImageView *cardImageView = [UIImageView.alloc initWithFrame:CGRectMake(20, Height_NavBar+20, self.view.width-40, 352)];
//    cardImageView.image = [[UIImage imageNamed:@"w_withdraw_card"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 0, 24) resizingMode:UIImageResizingModeStretch];
//    cardImageView.layer.shadowColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.16].CGColor;
//    cardImageView.layer.shadowOffset = CGSizeMake(0,3);
//    cardImageView.layer.shadowRadius = 6;
//    cardImageView.layer.shadowOpacity = 1;
//    [self.view addSubview:cardImageView];
    
    WalletWithdrawCard *cardView = [WalletWithdrawCard.alloc initWithFrame:CGRectMake(20, Height_NavBar+20, self.view.width-40, 352)];
    cardView.backgroundColor = [UIColor clearColor];
    cardView.layer.shadowColor = [UIColor colorWithRed:228/255.0 green:238/255.0 blue:252/255.0 alpha:1.0].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0,3);
    cardView.layer.shadowRadius = 6;
    cardView.layer.shadowOpacity = 1;
    [self.view addSubview:cardView];
    
    UIImageView *icon = [UIImageView.alloc initWithFrame:CGRectMake(0, 27, 104, 104)];
    icon.image = [UIImage imageNamed:@"w_withdraw_success"];
    icon.centerX = cardView.middleX;
    [cardView addSubview:icon];
    
    UILabel *contentLabel = [UILabel.alloc initWithFrame:CGRectZero];
    contentLabel.text = @"提现申请成功，等待银行处理";
    contentLabel.textColor = [UIColor colorWithHex:0x333333];
    contentLabel.font = [UIFont systemFontOfSize:18 weight:18];
    [contentLabel sizeToFit];
    contentLabel.centerX = cardView.middleX;
    contentLabel.top = icon.bottom+12;
    [cardView addSubview:contentLabel];
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.viewSize = CGSizeMake(200, 40);
    button.centerX = self.view.middleX;
    button.top = cardView.bottom + 30;
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x8EBAFC]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateHighlighted];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 每一项的名称
    UILabel *serverLabel = [UILabel.alloc initWithFrame:CGRectZero];
    serverLabel.text = @"服务费";
    serverLabel.font = [UIFont systemFontOfSize:14];
    serverLabel.textColor = [UIColor colorWithHex:0x333333];
    [serverLabel sizeToFit];
    serverLabel.left = 20;
    serverLabel.bottom = cardView.height - 20;
    [cardView addSubview:serverLabel];
    
    UILabel *bankLabel = [UILabel.alloc initWithFrame:CGRectZero];
    bankLabel.text = @"到账银行卡";
    bankLabel.font = [UIFont systemFontOfSize:14];
    bankLabel.textColor = [UIColor colorWithHex:0x333333];
    [bankLabel sizeToFit];
    bankLabel.left = 20;
    bankLabel.bottom = serverLabel.top - 10;
    [cardView addSubview:bankLabel];
    
    UILabel *amountLabel = [UILabel.alloc initWithFrame:CGRectZero];
    amountLabel.text = @"提现金额";
    amountLabel.font = [UIFont systemFontOfSize:14];
    amountLabel.textColor = [UIColor colorWithHex:0x333333];
    [amountLabel sizeToFit];
    amountLabel.left = 20;
    amountLabel.bottom = bankLabel.top - 10;
    [cardView addSubview:amountLabel];
    // 每一项的内容
    UILabel *serverContentLabel = [UILabel.alloc initWithFrame:CGRectZero];
    serverContentLabel.text = self.serverMoney;
    serverContentLabel.textColor = [UIColor colorWithHex:0x666666];
    serverContentLabel.font = [UIFont systemFontOfSize:12];
    [serverContentLabel sizeToFit];
    serverContentLabel.centerY = serverLabel.centerY;
    serverContentLabel.right = cardView.width - 20;
    [cardView addSubview:serverContentLabel];
    
    UILabel *bankContentLabel = [UILabel.alloc initWithFrame:CGRectZero];
    bankContentLabel.text = self.bankName;
    bankContentLabel.textColor = [UIColor colorWithHex:0x666666];
    bankContentLabel.font = [UIFont systemFontOfSize:12];
    [bankContentLabel sizeToFit];
    bankContentLabel.centerY = bankLabel.centerY;
    bankContentLabel.right = cardView.width - 20;
    [cardView addSubview:bankContentLabel];
    
    UIImageView *iconView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
    iconView.right = bankContentLabel.left - 4;
    iconView.centerY = bankContentLabel.centerY;
    [iconView tio_imageUrl:self.bankIconUrl placeHolderImageName:@"" radius:0];
    [cardView addSubview:iconView];
    
    UILabel *amountContentLabel = [UILabel.alloc initWithFrame:CGRectZero];
    amountContentLabel.text = self.amount;
    amountContentLabel.textColor = [UIColor colorWithHex:0x666666];
    amountContentLabel.font = [UIFont systemFontOfSize:12];
    [amountContentLabel sizeToFit];
    amountContentLabel.centerY = amountLabel.centerY;
    amountContentLabel.right = cardView.width - 20;
    [cardView addSubview:amountContentLabel];
}

#pragma mark - actions

- (void)confirmClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
