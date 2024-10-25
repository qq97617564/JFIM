//
//  IMMessageCellConfig.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "IMKitCellLayoutConfig.h"
#import "IMKitMessageModel.h"
#import "IMKitSessionContentConfigFactory.h"

@implementation IMKitCellLayoutConfig

- (CGSize)contentSize:(IMKitMessageModel *)model cellWidth:(CGFloat)width
{
    id<IMSessionContentConfig>config = [IMKitSessionContentConfigFactory.sharedFacotry configBy:model.message];
    return [config contentSize:width message:model.message];
}

/// 需要构造的cellContent类名
- (NSString *)cellContent:(IMKitMessageModel *)model
{
    id<IMSessionContentConfig>config = [IMKitSessionContentConfigFactory.sharedFacotry configBy:model.message];
    return [config cellContent:model.message];
}

/// 左对齐的气泡，cell内容距离气泡的内间距
- (UIEdgeInsets)contentViewInsets:(IMKitMessageModel *)model
{
    id<IMSessionContentConfig>config = [IMKitSessionContentConfigFactory.sharedFacotry configBy:model.message];
    return [config contentViewInsets:model.message];
}

/// 左对齐的气泡，cell气泡距离整个cell的内间距
- (UIEdgeInsets)cellInsets:(IMKitMessageModel *)model
{
    if ([[self cellContent:model] isEqualToString:@"IMKitMessageTipContentView"]) {
        return UIEdgeInsetsMake(10, 0, 10, 0);
    }
    
    // 要不要显示昵称 气泡位置分别设置
    if ([self shouldShowNick:model])
    {
        return UIEdgeInsetsMake(31, 72, 12, 56);
    }
    else
    {
        return UIEdgeInsetsMake(31, 72, 12, 56);
    }
}

/// 左对齐的气泡，头像控件的 size
- (CGSize)avatarSize:(IMKitMessageModel *)model
{
    return CGSizeMake(44, 44);
}

/// 左对齐的气泡，头像控件的 origin 点
- (CGPoint)avatarMargin:(IMKitMessageModel *)model
{
    return CGPointMake(16, 12);
}

/// 左对齐的气泡，昵称控件的 origin 点
- (CGPoint)nickNameMargin:(IMKitMessageModel *)model
{
    return CGPointMake(72, 12);
}

/// 消息显示在左边
- (BOOL)shouldShowLeft:(IMKitMessageModel *)model
{
    return !model.message.isOutgoingMsg;
}

- (BOOL)shouldShowAvatar:(IMKitMessageModel *)model
{
    return [TIOChatKit.shareSDK.config setting:model.message].showAvatar;
}

- (BOOL)shouldShowNick:(IMKitMessageModel *)model
{
    if (model.message.messageType == TIOMessageTypeTip || model.message.messageType == TIOMessageTypeNotification || model.message.messageType == TIOMessageTypeRichTip) {
        return NO;
    }
    
    // 具体私聊或者群聊 可以再判断
    BOOL isTeam = model.message.session.sessionType == TIOSessionTypeTeam;
//    return isTeam; // 群聊显示昵称
    return (!model.message.isOutgoingMsg && isTeam); // 群聊 && 别人的消息 显示昵称
    
    return YES;
}

- (BOOL)shouldShowTime:(IMKitMessageModel *)model
{
    return [TIOChatKit.shareSDK.config setting:model.message].showTime;
}

- (BOOL)disableRetryButton:(nonnull IMKitMessageModel *)model {
    return YES;
}

- (BOOL)shouldShowUnread:(IMKitMessageModel *)model
{
    BOOL isTeam = model.message.session.sessionType == TIOSessionTypeTeam;
    
    if (isTeam) {
        return NO;
    } else {
        if (model.message.isOutgoingMsg) return YES;
        return model.message.messageType == TIOMessageTypeAudio;
    }
}

@end
