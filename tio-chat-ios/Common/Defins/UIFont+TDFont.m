//
//  UIFont+TDFont.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIFont+TDFont.h"

@implementation UIFont (TDFont)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
}

#pragma clang diagnostic pop

@end
