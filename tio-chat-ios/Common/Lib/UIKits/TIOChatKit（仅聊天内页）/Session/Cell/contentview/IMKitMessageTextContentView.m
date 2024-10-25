//
//  IMKitMessageTextContentView.m
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import "IMKitMessageTextContentView.h"
#import "ImportSDK.h"
#import "TIOChatKit.h"

#import "M80AttributedLabel+IMKit.h"
#import "FrameAccessor.h"

@interface IMKitMessageTextContentView () <M80AttributedLabelDelegate>
@end

@implementation IMKitMessageTextContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        M80AttributedLabel *contentLabel = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
        contentLabel.backgroundColor = UIColor.clearColor;
        contentLabel.delegate = self;
        contentLabel.linkColor = [UIColor colorWithHex:0x2E52A3];
        contentLabel.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:contentLabel];
        self.contentLabel = contentLabel;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets contentInsets = self.messageModel.contentViewInsets;
    
    CGFloat tableViewWidth = self.superview.width;
    CGSize contentsize         = [self.messageModel contentSize:tableViewWidth];
    CGRect labelFrame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width, contentsize.height);
    self.contentLabel.frame = labelFrame;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:messageModel.message];
    TIOMessage * message = messageModel.message;
    
    self.contentLabel.textColor = setting.textColor;
    self.contentLabel.font = setting.font;
    
    [self.contentLabel im_setText:message.text];
//    [self.contentLabel im_setText:message.text];
}

- (void)onTouchDown:(id)sender
{
    
}

- (void)onTouchUpInside:(id)sender
{
    
}

- (void)onTouchUpOutside:(id)sender
{
    
}

- (void)m80AttributedLabel:(nonnull M80AttributedLabel *)label clickedOnLink:(nonnull id)linkData {
    //TODO:富文本超链接
    
    IMKitEvent *event = [IMKitEvent.alloc init];
    event.eventName = IMKitEventTouchUpInside;
    event.messageModel = self.messageModel;
    event.data = linkData;
    [self.delegate onTap:event];
}

@end
