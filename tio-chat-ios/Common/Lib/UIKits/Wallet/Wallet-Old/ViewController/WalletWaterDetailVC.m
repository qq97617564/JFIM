//
//  WalletWaterDetailVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWaterDetailVC.h"
#import "WalletWithdrawCard.h"
#import "WalletRedPackageDetailsVC.h"

#import "FrameAccessor.h"

@interface WalletWaterDetailVC ()

@end

@implementation WalletWaterDetailVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"交易详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WalletWithdrawCard *cardView = [WalletWithdrawCard.alloc initWithFrame:CGRectMake(20, Height_NavBar+20, self.view.width-40, 352)];
    cardView.reverse = YES;
    cardView.backgroundColor = [UIColor clearColor];
    cardView.layer.shadowColor = [UIColor colorWithRed:228/255.0 green:238/255.0 blue:252/255.0 alpha:1.0].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0,3);
    cardView.layer.shadowRadius = 6;
    cardView.layer.shadowOpacity = 1;
    [self.view addSubview:cardView];
    
    UILabel *titleLabel = [UILabel.alloc init];
    titleLabel.text = self.model.bizstr;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    [titleLabel sizeToFit];
    titleLabel.centerX = cardView.middleX;
    titleLabel.top = 30;
    [cardView addSubview:titleLabel];
    
    NSString *symbol = self.model.coinflag == 1?@"+":@"-";
    UILabel *amountLabel = [UILabel.alloc init];
    amountLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:30];
    amountLabel.textColor = [UIColor colorWithHex:0x333333];
    amountLabel.text = [NSString stringWithFormat:@"%@%.2f",symbol,self.model.amount/100.f];
    [amountLabel sizeToFit];
    amountLabel.centerX = cardView.middleX;
    amountLabel.top = 60;
    [cardView addSubview:amountLabel];
    
 
    NSString *typeStr = self.model.mode==1?@"充值":(self.model.mode==2?@"提现":@"红包");
    NSString *processStatus = nil;
    if ([self.model.orderstatus isEqualToString:@"SUCCESS"]) {
        processStatus = @"完成";
    } else if ([self.model.orderstatus isEqualToString:@"PROCESS"]) {
        processStatus = @"处理中";
    } else {
        processStatus = @"失败";
    }
    
    NSString *time = self.model.bizcreattime;
    NSString *ordernumber = self.model.serialnumber;
    NSString *desc = self.model.bizstr;
    
    NSArray *names = @[@"类型",@"状态",@"时间",@"单号",@"描述"];
    NSArray *values = @[typeStr, processStatus, time, ordernumber, desc];
    
    for (int i = 0; i < names.count; i++) {
        UILabel *nameLabel = [self customLabel:names[i]];
        nameLabel.left = 20;
        nameLabel.top = 160 + (nameLabel.height + 15) * i;
        [cardView addSubview:nameLabel];
        
        if ([names[i] isEqualToString:@"详情"]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"查看" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button sizeToFit];
            button.right = cardView.width - 20;
            button.centerY = nameLabel.centerY;
            [cardView addSubview:button];
        } else {
            UILabel *valueLabel = [self customLabel:values[i]];
            valueLabel.right = cardView.width - 20;
            valueLabel.centerY = nameLabel.centerY;
            [cardView addSubview:valueLabel];
        }
    }
}

- (UILabel *)customLabel:(NSString *)title
{
    UILabel *label = [UILabel.alloc init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHex:0x666666];
    [label sizeToFit];
    
    return label;
}

@end
