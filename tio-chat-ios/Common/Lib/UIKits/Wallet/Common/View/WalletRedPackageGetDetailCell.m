//
//  WalletDetailsCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletRedPackageGetDetailCell.h"
#import "FrameAccessor.h"

@interface WalletRedPackageGetDetailCell ()
@property (strong,  nonatomic) UILabel *luckyLabel;
@end

@implementation WalletRedPackageGetDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.bounds = CGRectMake(0, 0, 44, 44);
        
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x999999];
        
        self.moneyLabel = [UILabel.alloc initWithFrame:CGRectZero];
        self.moneyLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:16];
        self.moneyLabel.textColor = [UIColor colorWithHex:0x333333];
        [self.contentView addSubview:self.moneyLabel];
        
        self.luckyLabel = [UILabel.alloc init];
        self.luckyLabel.attributedText = ({
            NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
            
            NSTextAttachment *attatch = [NSTextAttachment.alloc init];
            attatch.image = [UIImage imageNamed:@"red_luck"];
            attatch.bounds = CGRectMake(0, -3, 16, 16);
            [aString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatch]];
            
            [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"人品爆发" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:0xF9AD55]}]];
            
            aString;
        });
        [self.luckyLabel sizeToFit];
        self.luckyLabel.hidden = YES;
        [self.contentView addSubview:self.luckyLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(16, (self.contentView.height-44)*0.5, 44, 44);
    
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    self.textLabel.left = 70;
    self.detailTextLabel.left = 70;
    
    [self.moneyLabel sizeToFit];
    self.moneyLabel.right = self.contentView.width - 16;
    self.moneyLabel.top = 8;
    
    self.luckyLabel.right = self.moneyLabel.right;
    self.luckyLabel.top = 34;
}

- (void)setIsLucky:(BOOL)isLucky
{
    self.luckyLabel.hidden = !isLucky;
}

@end
