//
//  WalletRechargeCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWithdrawCell.h"
#import "FrameAccessor.h"

@implementation WalletWithdrawCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.imageView.image = [UIImage imageNamed:@"recharge_record"];
        
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        
        self.moneyLabel = [UILabel.alloc init];
        self.moneyLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:18];
        self.moneyLabel.textColor = [UIColor colorWithHex:0x4C94FF];
        [self.contentView addSubview:self.moneyLabel];
        
        self.commissionLabel = [UILabel.alloc init];
        self.commissionLabel.font = [UIFont systemFontOfSize:14];
        self.commissionLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        [self.contentView addSubview:self.commissionLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.moneyLabel sizeToFit];
    self.moneyLabel.right = self.contentView.width - 16;
    self.moneyLabel.centerY = self.textLabel.centerY;
    
    [self.commissionLabel sizeToFit];
    self.commissionLabel.right = self.moneyLabel.right;
    self.commissionLabel.centerY = self.detailTextLabel.centerY;
}

@end
