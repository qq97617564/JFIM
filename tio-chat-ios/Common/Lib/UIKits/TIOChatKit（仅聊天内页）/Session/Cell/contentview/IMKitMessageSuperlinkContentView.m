//
//  IMKitMessageSuperlinkContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/24.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "IMKitMessageSuperlinkContentView.h"
#import "ImportSDK.h"
#import "TIOChatKit.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface IMKitMessageSuperlinkContentView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UIImageView *icon;

@end

@implementation IMKitMessageSuperlinkContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.titleLabel = [UILabel.alloc init];
        self.titleLabel.textColor = [UIColor colorWithHex:0x333333];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        self.subtitleLabel = [UILabel.alloc init];
        self.subtitleLabel.textColor = [UIColor colorWithHex:0x999999];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14];
        self.subtitleLabel.numberOfLines = 2;
        [self addSubview:self.subtitleLabel];
        
        self.icon = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self addSubview:self.icon];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets contentInsets = self.messageModel.contentViewInsets;
    
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:self.messageModel.message];
    /// 气泡最大宽度
    CGFloat msgBubbleMaxWidth    = setting.bubbleMaxWidth;
    
    if (setting.extDictionary) {
        CGFloat titleHeight = [setting.extDictionary[@"titleHeight"] floatValue];
        CGFloat subtitleHeight = [setting.extDictionary[@"subtitleHeight"] floatValue];
        
        self.titleLabel.frame = CGRectMake(contentInsets.left, contentInsets.top, msgBubbleMaxWidth-contentInsets.left-contentInsets.right, titleHeight);

        self.subtitleLabel.frame = CGRectMake(contentInsets.left, self.titleLabel.bottom+5, msgBubbleMaxWidth-contentInsets.left-contentInsets.right - 40 - 23, subtitleHeight);
        
        self.icon.bottom = self.height - contentInsets.bottom;
        self.icon.right = self.width - contentInsets.right;
    }
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    TIOMessage * message = messageModel.message;
    
    self.titleLabel.text = message.superlinkItem[@"title"];
    self.subtitleLabel.text = message.superlinkItem[@"subtitle"];
    [self.icon tio_imageUrl:message.superlinkItem[@"img"] placeHolderImageName:@"" radius:2];
    
}

@end
