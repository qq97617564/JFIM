//
//  TReviewInvitedUserHeader.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TReviewInvitationHeader.h"
#import "FrameAccessor.h"

@interface TReviewInvitationHeader()
/// 邀请理由的灰色背景
@property (weak,    nonatomic) UIView *msgBgView;

@end

@implementation TReviewInvitationHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *nicklabel = [UILabel.alloc init];
        nicklabel.textColor = [UIColor colorWithHex:0x333333];
        nicklabel.font = [UIFont systemFontOfSize:16];
        nicklabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nicklabel];
        self.nickLabel = nicklabel;
        
        UILabel *countLabel = [UILabel.alloc init];
        countLabel.textColor = [UIColor colorWithHex:0x333333];
        countLabel.font = [UIFont systemFontOfSize:18];
        countLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:countLabel];
        self.countLabel = countLabel;
        
        UIView *msgBgView = [UIView.alloc initWithFrame:CGRectZero];
        msgBgView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        msgBgView.layer.cornerRadius = 4;
        msgBgView.layer.masksToBounds = YES;
        [self addSubview:msgBgView];
        self.msgBgView = msgBgView;
        
        UILabel *msgLabel = [UILabel.alloc init];
        msgLabel.textColor = [UIColor colorWithHex:0x666666];
        msgLabel.font = [UIFont systemFontOfSize:14];
        msgLabel.textAlignment = NSTextAlignmentLeft;
        msgLabel.numberOfLines = 2;
        [self addSubview:msgLabel];
        self.applyMsgLabel = msgLabel;
        
        
        // layout
        self.imageView.centerX = self.middleX;
        self.imageView.top = 16;
        
        self.nickLabel.viewSize = CGSizeMake(self.width*0.7, 20);
        self.nickLabel.centerX = self.middleX;
        self.nickLabel.top = 65;
        
        self.countLabel.viewSize = CGSizeMake(self.width*0.7, 25);
        self.countLabel.centerX = self.middleX;
        self.countLabel.top = 108;
        
        self.msgBgView.viewSize = CGSizeMake(self.width - 32, 60);
        self.msgBgView.centerX = self.middleX;
        self.msgBgView.bottom = self.height;
        
        self.applyMsgLabel.viewSize = CGSizeMake(self.msgBgView.width - 24, 50);
        self.applyMsgLabel.center = self.msgBgView.center;
    }
    return self;
}

@end
