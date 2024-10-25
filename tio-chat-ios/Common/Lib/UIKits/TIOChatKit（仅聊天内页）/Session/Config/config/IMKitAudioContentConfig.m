//
//  CBIMAudioContentConfig.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitAudioContentConfig.h"
#import "TIOChatKit.h"

@implementation IMKitAudioContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
    CGFloat bubbleWidth    = 160;
    CGFloat bubbleLeftToContent  = setting.contentInsets.left;
    CGFloat contentRightToBubble = setting.contentInsets.right;
    CGFloat maxWidth = (bubbleWidth - contentRightToBubble - bubbleLeftToContent);
    CGFloat minWidth = 80;
    
    CGFloat minSeconds = 10;
    CGFloat maxSeconds = 60;
    
    if (message.attachmentObjects.firstObject.seconds <= minSeconds) {
        return CGSizeMake(minWidth, 42);
    }
    
    NSTimeInterval seconds = message.attachmentObjects.firstObject.seconds;
    
    CGFloat w = minWidth + seconds * 1.f/(maxSeconds-minSeconds) * (maxWidth-minWidth);
    
    return CGSizeMake(w, 42);
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageAudioContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

@end
