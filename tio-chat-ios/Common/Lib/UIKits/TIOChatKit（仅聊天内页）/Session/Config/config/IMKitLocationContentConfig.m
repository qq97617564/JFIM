//
//  CBIMLocationContentConfig.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitLocationContentConfig.h"
#import "TIOChatKit.h"

@implementation IMKitLocationContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    return CGSizeZero;
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return NSStringFromClass([self class]);
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

@end
