//
//  IMKitMessageImageContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/13.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageImageContentView.h"
#import "TIOKitDependency.h"
#import "TIOChatKit.h"
#import "ImportSDK.h"
#import <UIImageView+WebCache.h>

@interface IMKitMessageImageContentView ()
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@end

@implementation IMKitMessageImageContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.opaque = YES;
        _imageView  = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
//    self.imageView.layer.mask = self.maskLayer;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    TIOMessageAttachmnet *attachment = messageModel.message.attachmentObjects.firstObject;
    
    self.imageView.yy_imageURL = [NSURL URLWithString:attachment.coverurl];
    
    
    // 计算裁剪圆角
    
//    CGFloat tableViewWidth = self.superview.width;
//
//    CGSize contentSize = [messageModel contentSize:tableViewWidth];
//
//    UIBezierPath *maskPath = NULL;
//
//    if (messageModel.message.isOutgoingMsg)
//    {
//        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, contentSize.width, contentSize.height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(14,14)];
//    }
//    else
//    {
//        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, contentSize.width, contentSize.height) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(14,14)];
//    }
//
//    //创建 layer
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
//    //赋值
//    maskLayer.path = maskPath.CGPath;
//    self.maskLayer = maskLayer;
}

@end
