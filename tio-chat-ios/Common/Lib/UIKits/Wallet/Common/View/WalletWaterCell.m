//
//  WalletDetailCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWaterCell.h"

@implementation WalletWaterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        
        self.moneyLabel = [UILabel.alloc init];
        self.moneyLabel.textColor = [UIColor colorWithHex:0x4C94FF];
        self.moneyLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:18];
        [self.contentView addSubview:self.moneyLabel];
        
        self.remarkLabel = [UILabel.alloc init];
        self.remarkLabel.textColor = [UIColor colorWithHex:0xFFA058];
        self.remarkLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.remarkLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    [self.remarkLabel sizeToFit];
    
    CGRect textFrame = self.textLabel.frame;
    CGRect detailFrame = self.detailTextLabel.frame;
    
    textFrame.origin.x = 16;
    detailFrame.origin.x = 16;
    textFrame.origin.y = (CGRectGetHeight(self.contentView.frame) - textFrame.size.height - 3 - detailFrame.size.height) * 0.5;
    detailFrame.origin.y = CGRectGetMaxY(textFrame) + 3;
    
    self.textLabel.frame = textFrame;
    self.detailTextLabel.frame = detailFrame;
    
    [self.moneyLabel sizeToFit];
    CGRect moneyFrame = self.moneyLabel.frame;
    moneyFrame.origin.x = CGRectGetWidth(self.contentView.frame) - 16 - moneyFrame.size.width;
    self.moneyLabel.frame = moneyFrame;
    self.moneyLabel.center = CGPointMake(CGRectGetMidX(moneyFrame), CGRectGetMidY(textFrame));
    
    CGRect remarkFrame = self.remarkLabel.frame;
    remarkFrame.origin.x = CGRectGetWidth(self.contentView.frame) - 16 - remarkFrame.size.width;
    remarkFrame.origin.y = CGRectGetMaxY(moneyFrame) + 3;
    self.remarkLabel.frame = remarkFrame;
}

@end
