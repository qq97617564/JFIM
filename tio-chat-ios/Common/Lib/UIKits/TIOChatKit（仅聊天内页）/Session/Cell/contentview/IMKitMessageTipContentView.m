//
//  IMKitMessageTipContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageTipContentView.h"
#import "ImportSDK.h"
#import "TIOChatKit.h"
#import "FrameAccessor.h"
#import "TMessageMaker.h"
#import "M80AttributedLabel.h"
#import "TIOMessage+RichTip.h"

@interface IMKitMessageTipContentView () <M80AttributedLabelDelegate>

@end

@implementation IMKitMessageTipContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        UIView *msgBgView = [UIView.alloc initWithFrame:CGRectZero];
        msgBgView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        msgBgView.layer.cornerRadius = 10;
        msgBgView.layer.masksToBounds = YES;
        [self addSubview:msgBgView];
        self.msgBgView = msgBgView;
        
        M80AttributedLabel *msgLabel = [M80AttributedLabel.alloc init];
        msgLabel.delegate = self;
        msgLabel.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        msgLabel.textAlignment = kCTTextAlignmentCenter;
        [msgBgView addSubview:msgLabel];
        self.msgLabel = msgLabel;
        
        UILabel *timelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timelabel.font = [UIFont systemFontOfSize:14];
        timelabel.textColor = [UIColor colorWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:1.0];
        [self addSubview:timelabel];
        self.timeLabel = timelabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat tableViewWidth = self.superview.width;
    CGSize contentsize  =   [self.messageModel contentSize:tableViewWidth];
    
    [_timeLabel sizeToFit];
    _timeLabel.centerX = self.middleX;
    _timeLabel.top = 2;
    
    CGSize msgSize = [self.msgLabel sizeThatFits:CGSizeMake(tableViewWidth * 0.8, MAXFLOAT)];
    
    self.msgBgView.viewSize = CGSizeMake(msgSize.width+32, contentsize.height - 23);
    self.msgBgView.centerX = self.middleX;
    self.msgBgView.top = _timeLabel.bottom+4;
    
    self.msgLabel.viewSize = CGSizeMake(msgSize.width, msgSize.height+1);
    self.msgLabel.center = self.msgBgView.middlePoint;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:messageModel.message];
    
    TIOMessage * message = messageModel.message;
    self.msgLabel.font = setting.font;
    self.msgLabel.textColor = setting.textColor;
    
    if (message.messageType == TIOMessageTypeRichTip) {
        NSDictionary *apply = message.apply;
        NSString *status = apply[@"status"];
        NSString *text = [NSString stringWithFormat:@"%@想邀请好友加入群聊,去确认",message.from];
        if ([status isEqual:@(1)]) {
            text = [NSString stringWithFormat:@"%@想邀请好友加入群聊,已确认",message.from];
        }
        self.msgLabel.text = text;
        [self.msgLabel addCustomLink:[NSString stringWithFormat:@"13_%@",status] forRange:NSMakeRange(text.length - 3, 3) linkColor:[UIColor colorWithHex:0x4C94FF]];
    } else {
        if (message.t_tipCode == 1000) {
            self.msgLabel.attributedText = [TMessageMaker redpackageTipForMessage:message];
        } else {
            if (!message.t_linkString) {
                self.msgLabel.text = [TMessageMaker tipForMessage:message];
            } else {
                self.msgLabel.text = [message.text stringByAppendingFormat:@",%@",message.t_linkString];
                [self.msgLabel addCustomLink:message.t_selctorName forRange:NSMakeRange(self.msgLabel.text.length - message.t_linkString.length, message.t_linkString.length) linkColor:message.t_color?:[UIColor colorWithRed:76/255.f green:148/255.f blue:255/255.f alpha:1]];
            }
        }
    }
    
    self.timeLabel.text = [TIOKitTool showTime:message.timestamp showDetail:YES];
}

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData
{
    IMKitEvent *event = [IMKitEvent.alloc init];
    event.eventName = IMKitEventTouchUpInside;
    event.messageModel = self.messageModel;
    event.data = linkData;
    [self.delegate onTap:event];
}


@end
