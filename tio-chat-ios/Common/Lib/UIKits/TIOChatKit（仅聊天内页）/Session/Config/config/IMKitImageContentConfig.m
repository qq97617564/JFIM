//
//  CBIMImageContentConfig.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitImageContentConfig.h"
#import "TIOChatKit.h"

@implementation IMKitImageContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
    CGFloat bubbleWidth    = 160;
    CGFloat bubbleLeftToContent  = setting.contentInsets.left;
    CGFloat contentRightToBubble = setting.contentInsets.right;
    CGFloat imgWidth = (bubbleWidth - contentRightToBubble - bubbleLeftToContent);
    
    /// 气泡最大160
    /// 根据图片宽度计算图片高度
    CGFloat imgHeight = message.attachmentObjects.firstObject.coverheight * (imgWidth / message.attachmentObjects.firstObject.coverwidth);
    
    return CGSizeMake(imgWidth, imgHeight);
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageImageContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

@end
