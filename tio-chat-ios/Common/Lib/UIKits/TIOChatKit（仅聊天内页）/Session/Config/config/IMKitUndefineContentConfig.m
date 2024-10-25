//
//  IMKitUndefineContentConfig.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitUndefineContentConfig.h"
#import "TIOChatKit.h"
#import "M80AttributedLabel+IMKit.h"
#import "FrameAccessor.h"

@interface IMKitUndefineContentConfig ()
@property (strong, nonatomic) UILabel *label;
@end

@implementation IMKitUndefineContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
//    return CGSizeMake(230, 46);
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
    
    CGFloat msgBubbleMaxWidth    = setting.bubbleMaxWidth;
    CGFloat bubbleLeftToContent  = setting.contentInsets.left;
    CGFloat contentRightToBubble = setting.contentInsets.right;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    
    CGSize size = [@"[暂不支持的消息类型] 请到PC查看" boundingRectWithSize:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:setting.font} context:nil].size;
    //[self.contentLabel sizeThatFits:CGSizeMake(230, CGFLOAT_MAX)];
    return CGSizeMake(size.width, size.height);
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageUndefineContentView";
}

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;
{
    return [[TIOChatKit.shareSDK config] setting:message].contentInsets;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [UILabel.alloc init];
        _label.font = [UIFont systemFontOfSize:16];
    }
    return _label;
}

@end
