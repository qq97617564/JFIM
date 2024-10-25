//
//  IMKitMessageVideoContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageVideoContentView.h"
#import "TIOKitDependency.h"
#import "TIOChatKit.h"
#import "ImportSDK.h"
#import <UIImageView+WebCache.h>


@interface IMKitMessageVideoContentView ()
@property (nonatomic, weak) UIImageView *icon;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@end

@implementation IMKitMessageVideoContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.opaque = YES;
        _imageView  = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        UIImageView *icon = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"play_video"]];
        [icon sizeToFit];
        [self addSubview:icon];
        self.icon = icon;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.imageView.layer.mask = self.maskLayer;
    
    self.icon.center = self.middlePoint;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    TIOMessageAttachmnet *attachment = messageModel.message.attachmentObjects.firstObject;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:attachment.coverurl] placeholderImage:nil];
    
    
    // 计算裁剪圆角
    
    CGFloat tableViewWidth = self.superview.width;

    CGSize contentSize = [messageModel contentSize:tableViewWidth];

    UIBezierPath *maskPath = NULL;

    if (messageModel.message.isOutgoingMsg)
    {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, contentSize.width, contentSize.height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(14,14)];
    }
    else
    {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, contentSize.width, contentSize.height) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(14,14)];
    }

    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    //赋值
    maskLayer.path = maskPath.CGPath;
    self.maskLayer = maskLayer;
}

@end
