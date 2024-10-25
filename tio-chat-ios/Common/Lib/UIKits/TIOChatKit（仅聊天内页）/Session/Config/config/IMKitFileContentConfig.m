//
//  CBIMFileContentConfig.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitFileContentConfig.h"
#import "TIOChatKit.h"

@implementation IMKitFileContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{   // 文件气泡
    return CGSizeMake(190, 48);
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageFileContentView";
}

/// 气泡的内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

@end
