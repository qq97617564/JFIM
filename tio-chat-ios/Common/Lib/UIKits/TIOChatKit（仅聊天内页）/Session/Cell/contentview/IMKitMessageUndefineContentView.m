//
//  IMKitMessageUndefineContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageUndefineContentView.h"
#import "FrameAccessor.h"
#import "TIOChatKit.h"

@interface IMKitMessageUndefineContentView ()
@property (strong,  nonatomic) UILabel *label;
@end
@implementation IMKitMessageUndefineContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.label = [UILabel.alloc init];
        self.label.text = @"[暂不支持的消息类型] 请到PC查看";
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textColor = UIColor.blackColor;
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.numberOfLines = 2;
        [self addSubview:self.label];
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
}

@end
