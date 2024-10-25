//
//  NWBankCard.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/3.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWBankCard.h"
#import "FrameAccessor.h"

@implementation NWBankCard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.shadowColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:0.45].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,3);
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 1;
        self.layer.cornerRadius = 4;
        
        UIImageView *bg = [UIImageView.alloc initWithFrame:self.bounds];
        [self.contentView addSubview:bg];
        self.bg = bg;
        
        UIImageView *icon = [UIImageView.alloc initWithFrame:CGRectMake(15, 16, 27, 27)];
        [self.contentView addSubview:icon];
        self.icon = icon;
        
        UIImageView *water = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 94, 67)];
        water.bottom = self.contentView.height;
        [self.contentView addSubview:water];
        self.watermark = water;
        
        UILabel *bankLabel = [UILabel.alloc initWithFrame:CGRectMake(50, 17, self.contentView.width - 100, 22)];
        bankLabel.textColor = [UIColor whiteColor];
        bankLabel.font = [UIFont systemFontOfSize:16];
        bankLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:bankLabel];
        self.nameLabel = bankLabel;
        
        CGFloat dotCenterY = 0;
        for (int i = 0; i < 12; i++) {
            UIView *dot = [UIView.alloc initWithFrame:CGRectMake(54 + 10 * i + i/4* 18, 67, 6, 6)];
            dot.backgroundColor = UIColor.whiteColor;
            dot.layer.cornerRadius = 3;
            dot.layer.masksToBounds = YES;
            [self.contentView addSubview:dot];
            
            dotCenterY = dot.centerY;
        }
        
        UILabel *noLabel = [UILabel.alloc initWithFrame:CGRectMake(220, 0, 70, 33)];
        noLabel.centerY = dotCenterY;
        noLabel.textColor = [UIColor whiteColor];
        noLabel.textAlignment = NSTextAlignmentLeft;
        noLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:30];
        [self.contentView addSubview:noLabel];
        self.cardNoLabel = noLabel;
    }
    return self;
}

@end
