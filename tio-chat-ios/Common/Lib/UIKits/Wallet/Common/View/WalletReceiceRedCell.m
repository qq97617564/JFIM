//
//  WalletReceiceRedCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletReceiceRedCell.h"
#import "FrameAccessor.h"

@implementation WalletReceiceRedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x999999];
        
        self.moneyLabel = [UILabel.alloc init];
        self.moneyLabel.textColor = [UIColor colorWithHex:0x333333];
        self.moneyLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:16];
        [self.contentView addSubview:self.moneyLabel];
        
        self.pinImageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.pinImageView.image = [UIImage imageNamed:@"wallet_pin"];
        self.pinImageView.hidden = YES;
        [self.contentView addSubview:self.pinImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(16,( self.contentView.height-44)*0.5, 44, 44);
    
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    self.textLabel.left = 70;
    self.detailTextLabel.left = 70;
    
    self.textLabel.top = (self.contentView.height - self.textLabel.height - 2 - self.detailTextLabel.height) * 0.5;
    self.detailTextLabel.top = self.textLabel.bottom+2;
    
    if (self.textLabel.width > self.contentView.width *0.5) {
        self.textLabel.width = self.contentView.width *0.5;
    }
    
    self.pinImageView.left = self.textLabel.right + 4;
    self.pinImageView.centerY = self.textLabel.centerY;
    
    [self.moneyLabel sizeToFit];
    self.moneyLabel.right = self.contentView.width - 20;
    self.moneyLabel.centerY = self.textLabel.centerY;
}

- (void)setType:(NSInteger)type
{
    switch (type) {
        case 0:
        {
            self.pinImageView.hidden = YES;
        }
            break;
        case 1:
        {
            self.pinImageView.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

@end
