//
//  IMKitSuperLinkContentConfig.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/24.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "IMKitSuperLinkContentConfig.h"
#import "FrameAccessor.h"
#import "TIOChatKit.h"

@interface IMKitSuperLinkContentConfig ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@end

@implementation IMKitSuperLinkContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
//    [self.contentLabel im_setText:message.text];
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
//    self.contentLabel.font = setting.font;
    
    /// 气泡最大宽度
    CGFloat msgBubbleMaxWidth    = setting.bubbleMaxWidth;
    /// 气泡内容左边距
    CGFloat bubbleLeftToContent  = setting.contentInsets.left;
    /// 气泡内容右边距
    CGFloat contentRightToBubble = setting.contentInsets.right;
    /// 内容的最大宽度
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    NSString *title     = message.superlinkItem[@"title"];
    NSString *subtitle  = message.superlinkItem[@"subtitle"];
    
    CGFloat titleHeight = [title boundingRectWithSize:CGSizeMake(msgContentMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]} context:nil].size.height;
    if (titleHeight > 25) {
        titleHeight = 46;
    }
    
    /// 40 23 是距离icon和icon的宽度
    CGFloat subtitleHeight = [subtitle boundingRectWithSize:CGSizeMake(msgContentMaxWidth - 40 - 23, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:0x999999]} context:nil].size.height;
    if (subtitleHeight > 22) {
        subtitleHeight = 40;
    }
    
    setting.extDictionary = @{
        @"titleHeight" : [NSNumber numberWithFloat:titleHeight],
        @"subtitleHeight" : [NSNumber numberWithFloat:subtitleHeight]
    };
    
    
    return CGSizeMake(msgContentMaxWidth, titleHeight + 46);
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageSuperlinkContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

@end
