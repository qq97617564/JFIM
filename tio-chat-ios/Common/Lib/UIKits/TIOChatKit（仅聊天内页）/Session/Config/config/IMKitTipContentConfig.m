//
//  CBNIMTipContentConfig.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitTipContentConfig.h"
#import "TIOChatKit.h"
#import "TMessageMaker.h"

#import "M80AttributedLabel.h"
#import "TIOMessage+RichTip.h"

@interface IMKitTipContentConfig ()
@property (strong, nonatomic) M80AttributedLabel *contentLabel;
@end

@implementation IMKitTipContentConfig

/// 计算气泡尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message
{
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:message];
    self.contentLabel.font = setting.font;
    
    if (message.messageType == TIOMessageTypeRichTip) {
        self.contentLabel.text = [NSString stringWithFormat:@"%@想邀请好友加入群聊,去确认",message.from];
        CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(cellWidth * 0.8, CGFLOAT_MAX)];
        return CGSizeMake(cellWidth, size.height+27);;
    } else {
        if (message.t_tipCode == 1000) {
            CGSize msgSize = [[TMessageMaker redpackageTipForMessage:message] boundingRectWithSize:CGSizeMake(cellWidth * 0.8, 500) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
            
            return CGSizeMake(cellWidth, msgSize.height+27);
        } else {
            if (message.t_linkString) {
                self.contentLabel.text = [message.text stringByAppendingFormat:@",%@",message.t_linkString];
                CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(cellWidth * 0.8, CGFLOAT_MAX)];
                return CGSizeMake(cellWidth, size.height+27);;
            } else {
                self.contentLabel.text = [message.text stringByAppendingFormat:@",%@",message.t_linkString];
                CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(cellWidth * 0.8, CGFLOAT_MAX)];
                
                return CGSizeMake(cellWidth, size.height+27);
            }
        }
    }
}

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message
{
    return @"IMKitMessageTipContentView";
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
