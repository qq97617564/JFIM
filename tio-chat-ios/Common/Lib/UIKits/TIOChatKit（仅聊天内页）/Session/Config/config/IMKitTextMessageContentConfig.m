//
//  IMTextMessageContentConfig.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitTextMessageContentConfig.h"
#import "TIOChatKit.h"
#import "M80AttributedLabel+IMKit.h"
#import "FrameAccessor.h"

@interface IMKitTextMessageContentConfig ()

@property (strong, nonatomic) M80AttributedLabel *contentLabel;

@end

@implementation IMKitTextMessageContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    [self.contentLabel im_setText:message.text];
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
    self.contentLabel.font = setting.font;
    
    CGFloat msgBubbleMaxWidth    = setting.bubbleMaxWidth;
    CGFloat bubbleLeftToContent  = setting.contentInsets.left;
    CGFloat contentRightToBubble = setting.contentInsets.right;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
    return size;
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageTextContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

#pragma mark - contentLabel

- (M80AttributedLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = UIColor.clearColor;
        _contentLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _contentLabel;
}

@end
