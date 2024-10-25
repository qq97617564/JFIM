//
//  IMMessageContentView.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "IMKitMessageContentView.h"
#import "TIOChatKit.h"
#import "IMKitEvent.h"

@implementation IMKitMessageContentView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 60, 35)];
    
    if (self) {
        [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,35)];
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bubbleImageView.userInteractionEnabled = NO;
        [self addSubview:_bubbleImageView];
    }
    
    return self;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    _messageModel = messageModel;
    [_bubbleImageView setImage:[self chatBubbleImageForState:UIControlStateNormal outgoing:messageModel.message.isOutgoingMsg]];
    [_bubbleImageView setHighlightedImage:[self chatBubbleImageForState:UIControlStateHighlighted outgoing:messageModel.message.isOutgoingMsg]];
    [self setNeedsLayout];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    _bubbleImageView.frame = self.bounds;
}


- (void)updateProgress:(float)progress
{
    
}

- (void)onTouchDown:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onTap:)]) {
        IMKitEvent *event = [IMKitEvent.alloc init];
        event.eventName = IMKitEventTouchDown;
        event.messageModel = self.messageModel;
        [self.delegate onTap:event];
    }
}

- (void)onTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onTap:)]) {
        IMKitEvent *event = [IMKitEvent.alloc init];
        event.eventName = IMKitEventTouchUpInside;
        event.messageModel = self.messageModel;
        [self.delegate onTap:event];
    }
}

- (void)onTouchUpOutside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onTap:)]) {
        IMKitEvent *event = [IMKitEvent.alloc init];
        event.eventName = IMKitEventTouchUpOutside;
        event.messageModel = self.messageModel;
        [self.delegate onTap:event];
    }
}

- (void)longPress:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onLongTap:)]) {
        [self.delegate onLongTap:self.messageModel.message];
    }
}

#pragma mark - Private
- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
{
    
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:self.messageModel.message];
    if (state == UIControlStateNormal)
    {
        return [setting.normalBackgroundImage resizableImageWithCapInsets:setting.bubbleImageStretch resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        return [setting.highLightBackgroundImage resizableImageWithCapInsets:setting.bubbleImageStretch resizingMode:UIImageResizingModeStretch];
    }
}

@end
