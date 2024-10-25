//
//  IMKitCardContentConfig.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitCardContentConfig.h"

@implementation IMKitCardContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    return CGSizeMake(210, 90);
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageCardContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return UIEdgeInsetsZero;
}

@end
