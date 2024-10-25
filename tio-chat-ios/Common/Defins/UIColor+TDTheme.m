//
//  UIColor+TDTheme.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "UIColor+TDTheme.h"


@implementation UIColor (TDTheme)

+ (UIColor *)colorWithHex:(UInt32)hex {
    return [UIColor colorWithHex:hex alpha:1.f];
}

+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    //hexString应该6到8个字符
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    //如果hexString 有@"0X"前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    
    //如果hexString 有@"#""前缀
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    //RGB转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //R
    NSString *rString = [cString substringWithRange:range];
    
    //G
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //B
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    //
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *)TDTheme_TabBarNormalColor
{
    return [UIColor colorWithHex:0xCDD0D3];
}

+ (UIColor *)TDTheme_TabBarSelectedColor
{
    return [UIColor colorWithHex:0x4C94FF];
}

+ (UIColor *)TDTheme_UnreadColor
{
    return [UIColor colorWithHex:0xFF754C];
}

+ (UIColor *)TDTheme_ModuleTitleColor
{
    return [UIColor colorWithHex:0x111111];
}

+ (UIColor *)TDTheme_SessionNickColor
{
    return [UIColor colorWithHex:0x111111];
}

+ (UIColor *)TDTheme_SessionMessageColor
{
    return [UIColor colorWithHex:0x909090];
}

@end
