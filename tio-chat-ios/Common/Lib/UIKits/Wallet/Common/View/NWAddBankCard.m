//
//  NWAddBankCard.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/3.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWAddBankCard.h"
#import "FrameAccessor.h"

@implementation NWAddBankCard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        
        self.layer.shadowColor = [UIColor colorWithRed:228/255.0 green:238/255.0 blue:252/255.0 alpha:1.0].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,3);
        self.layer.shadowRadius = 6;
        self.layer.shadowOpacity = 1;
        self.layer.cornerRadius = 4;
        
        UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 50, 50)];
        imageView.image = [UIImage imageNamed:@"buleadd"];
        imageView.centerX = self.middleX;
        [self addSubview:imageView];
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 90, 23)];
        label.centerX = self.middleX;
        label.text = @"添加银行卡";
        label.textColor = [UIColor colorWithHex:0x333333];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        imageView.top = (self.height - imageView.height - 16 - label.height) * 0.5;
        label.top = imageView.bottom + 16;
    }
    return self;
}

@end
