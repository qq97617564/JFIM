//
//  IMKitMessageVideoChatContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/1.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageVideoChatContentView.h"
#import "TIOChatKit.h"

#import "FrameAccessor.h"

#import "TIOKitTool.h"

@interface IMKitMessageVideoChatContentView ()
@property (weak,    nonatomic) UIImageView *imageView;
@property (strong,  nonatomic) UILabel *label;
@end

@implementation IMKitMessageVideoChatContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.label = [UILabel.alloc init];
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textColor = UIColor.blackColor;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.backgroundColor = UIColor.clearColor;
        [self addSubview:self.label];
        
        UIImageView *fileImage = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self addSubview:fileImage];
        self.imageView = fileImage;
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
    self.label.frame = labelFrame;
    
    if (self.messageModel.message.isOutgoingMsg) {
        self.imageView.image = self.messageModel.message.messageType == TIOMessageTypeVideoChat ? [UIImage imageNamed:@"vcmsg_self"] : [UIImage imageNamed:@"vc_audio_self"];
        self.imageView.right = self.width-14;
    } else {
        self.imageView.image = self.messageModel.message.messageType == TIOMessageTypeVideoChat ? [UIImage imageNamed:@"vcmsg_other"] : [UIImage imageNamed:@"vc_audio"];
        self.imageView.left = 16;
    }
    self.imageView.centerY = self.middleY;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    self.label.text = messageModel.message.text;
}

@end
