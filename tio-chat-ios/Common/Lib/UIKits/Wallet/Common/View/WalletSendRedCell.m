//
//  WalletSendRedCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletSendRedCell.h"
#import "FrameAccessor.h"

@implementation WalletSendRedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x999999];
        
        self.moneyLabel = [UILabel.alloc init];
        self.moneyLabel.textColor = [UIColor colorWithHex:0x333333];
        self.moneyLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:16];
        [self.contentView addSubview:self.moneyLabel];
        
        self.recievedLabel = [UILabel.alloc init];
        self.recievedLabel.textColor = [UIColor colorWithHex:0x999999];
        self.recievedLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.recievedLabel];
        
        self.statusLabel = [UILabel.alloc init];
        self.statusLabel.textColor = [UIColor colorWithHex:0xFB9817];
        self.statusLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.statusLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    self.textLabel.left = 16;
    self.textLabel.top = (self.contentView.height - self.textLabel.height - self.detailTextLabel.height - 2) * 0.5;
    
    self.detailTextLabel.left = 16;
    self.detailTextLabel.top = self.textLabel.bottom + 2;
    
    [self.moneyLabel sizeToFit];
    self.moneyLabel.right = self.contentView.width - 20;
    self.moneyLabel.centerY = self.textLabel.centerY;
    
    [self.recievedLabel sizeToFit];
    self.recievedLabel.right = self.contentView.width - 20;
    self.recievedLabel.centerY = self.detailTextLabel.centerY;
    
    [self.statusLabel sizeToFit];
    self.statusLabel.right = self.recievedLabel.left - 4;
    self.statusLabel.centerY = self.recievedLabel.centerY;
}

@end
