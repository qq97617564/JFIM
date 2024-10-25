//
//  IMKitVideoChatContentConfig.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/1.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitVideoChatContentConfig.h"
#import "TIOChatKit.h"
#import "FrameAccessor.h"

@interface IMKitVideoChatContentConfig ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation IMKitVideoChatContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    NSString *msg = message.text;
    
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
    
    CGFloat msgBubbleMaxWidth    = setting.bubbleMaxWidth;
    CGFloat bubbleLeftToContent  = setting.contentInsets.left;
    CGFloat contentRightToBubble = setting.contentInsets.right;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    CGSize size = [msg boundingRectWithSize:CGSizeMake(msgContentMaxWidth, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:setting.font} context:nil].size;
    
    return size;
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageVideoChatContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

@end
